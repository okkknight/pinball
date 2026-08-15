import AppKit
import SpriteKit

@MainActor
final class OverlayWindowController: NSWindowController {
    let scene: PinballScene

    init(screen: NSScreen, config: PhysicsConfig) {
        let frame = screen.frame
        let window = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        scene = PinballScene(size: frame.size, worldOrigin: frame.origin, config: config)

        let view = SKView(frame: NSRect(origin: .zero, size: frame.size))
        view.allowsTransparency = true
        view.ignoresSiblingOrder = true
        view.presentScene(scene)

        window.contentView = view
        window.level = .statusBar
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        window.orderOut(nil)

        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func showWindow(_ sender: Any?) {
        window?.orderFrontRegardless()
    }
}
