import AppKit
import Foundation
import os

@main
@MainActor
struct PinballMain {
    private static var retainedDelegate: AppDelegate?
    private static let logger = Logger(subsystem: "com.linpeiwen.Pinball", category: "lifecycle")

    static func main() {
        logger.info("PinballMain starting")
        let delegate = AppDelegate()
        retainedDelegate = delegate
        let application = NSApplication.shared
        application.setActivationPolicy(.regular)
        application.delegate = delegate
        logger.info("PinballMain entering run loop")
        application.run()
    }
}
