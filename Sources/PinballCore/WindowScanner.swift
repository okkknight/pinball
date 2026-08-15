import CoreGraphics
import Foundation

public struct WindowSnapshot: Hashable {
    public let ownerName: String
    public let windowName: String?
    public let windowNumber: Int
    public let bounds: CGRect

    public init(ownerName: String, windowName: String?, windowNumber: Int, bounds: CGRect) {
        self.ownerName = ownerName
        self.windowName = windowName
        self.windowNumber = windowNumber
        self.bounds = bounds
    }
}

public enum WindowScanner {
    public static func scanVisibleWindows(excludingOwners excludedOwners: Set<String> = []) -> [WindowSnapshot] {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        let windowInfo = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
        return normalize(windowList: windowInfo, excludingOwners: excludedOwners)
    }

    public static func normalize(
        windowList: [[String: Any]],
        excludingOwners excludedOwners: Set<String> = []
    ) -> [WindowSnapshot] {
        windowList.compactMap { rawWindow in
            guard
                let ownerName = rawWindow[kCGWindowOwnerName as String] as? String,
                !excludedOwners.contains(ownerName),
                let layer = Self.intValue(rawWindow[kCGWindowLayer as String]),
                layer == 0,
                let alpha = Self.cgFloatValue(rawWindow[kCGWindowAlpha as String]),
                alpha > 0,
                let windowNumber = Self.intValue(rawWindow[kCGWindowNumber as String]),
                let bounds = Self.rect(from: rawWindow[kCGWindowBounds as String])
            else {
                return nil
            }

            return WindowSnapshot(
                ownerName: ownerName,
                windowName: rawWindow[kCGWindowName as String] as? String,
                windowNumber: windowNumber,
                bounds: bounds
            )
        }
    }

    private static func rect(from value: Any?) -> CGRect? {
        guard
            let dictionary = value as? [String: Any],
            let x = cgFloatValue(dictionary["X"]),
            let y = cgFloatValue(dictionary["Y"]),
            let width = cgFloatValue(dictionary["Width"]),
            let height = cgFloatValue(dictionary["Height"])
        else {
            return nil
        }

        guard width > 0, height > 0 else {
            return nil
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private static func cgFloatValue(_ value: Any?) -> CGFloat? {
        switch value {
        case let number as NSNumber:
            return CGFloat(number.doubleValue)
        case let float as CGFloat:
            return float
        case let double as Double:
            return CGFloat(double)
        case let int as Int:
            return CGFloat(int)
        default:
            return nil
        }
    }

    private static func intValue(_ value: Any?) -> Int? {
        switch value {
        case let number as NSNumber:
            return number.intValue
        case let int as Int:
            return int
        default:
            return nil
        }
    }
}
