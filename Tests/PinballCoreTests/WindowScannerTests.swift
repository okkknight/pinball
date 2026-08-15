import CoreGraphics
import XCTest
@testable import PinballCore

final class WindowScannerTests: XCTestCase {
    func testNormalizeDropsEmptyWindowRects() {
        let normalized = WindowScanner.normalize(windowList: [])
        XCTAssertTrue(normalized.isEmpty)
    }
}
