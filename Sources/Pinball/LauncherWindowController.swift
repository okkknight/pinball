import AppKit
import CoreGraphics

@MainActor
final class LauncherWindowController: NSWindowController {
    private let launcherView: LauncherView
    private let config: PhysicsConfig

    var onLaunch: ((CGVector) -> Void)?

    init(screen: NSScreen, config: PhysicsConfig) {
        self.config = config
        let size = NSSize(width: 180, height: 180)
        let visibleFrame = screen.visibleFrame
        let origin = CGPoint(
            x: visibleFrame.minX + 18,
            y: visibleFrame.minY + 18
        )
        let windowFrame = CGRect(origin: origin, size: size)

        let window = LauncherWindow(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        launcherView = LauncherView(frame: NSRect(origin: .zero, size: size), config: config)

        window.contentView = launcherView
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]

        super.init(window: window)

        launcherView.onLaunchRequested = { [weak self] launchVector in
            self?.onLaunch?(launchVector)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func showWindow(_ sender: Any?) {
        window?.makeKeyAndOrderFront(sender)
    }

    var launchPointInScreenCoordinates: CGPoint {
        guard let window else { return .zero }
        let localBallCenter = launcherView.ballCenter
        let localRect = NSRect(origin: localBallCenter, size: .zero)
        return window.convertToScreen(localRect).origin
    }
}

final class LauncherWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}

@MainActor
final class LauncherView: NSView {
    var onLaunchRequested: ((CGVector) -> Void)?

    private let config: PhysicsConfig
    private var dragVector: CGVector = CGVector(dx: 0, dy: 0)
    private var isDragging = false

    init(frame frameRect: NSRect, config: PhysicsConfig) {
        self.config = config
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        self
    }

    override func mouseDown(with event: NSEvent) {
        isDragging = true
        dragVector = CGVector(dx: 0, dy: 0)
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard isDragging else { return }
        let location = convert(event.locationInWindow, from: nil)
        dragVector = vectorFromBallCenter(to: location).clamped(maxLength: 120)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard isDragging else { return }
        let launchVector = CGVector(dx: -dragVector.dx, dy: -dragVector.dy)
            * config.launchSpeedMultiplier
        onLaunchRequested?(launchVector.clamped(maxLength: config.maxSpeed))
        isDragging = false
        dragVector = CGVector(dx: 0, dy: 0)
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        let outerRect = bounds.insetBy(dx: 10, dy: 10)
        let background = NSBezierPath(roundedRect: outerRect, xRadius: 20, yRadius: 20)
        NSColor(calibratedWhite: 0.09, alpha: 0.78).setFill()
        background.fill()

        NSColor(calibratedWhite: 1.0, alpha: 0.11).setStroke()
        background.lineWidth = 1.25
        background.stroke()

        let center = ballCenter
        let guideEnd = CGPoint(x: center.x + dragVector.dx * 0.5, y: center.y + dragVector.dy * 0.5)

        if isDragging {
            let line = NSBezierPath()
            line.move(to: center)
            line.line(to: guideEnd)
            NSColor.systemPink.withAlphaComponent(0.7).setStroke()
            line.lineWidth = 2
            line.stroke()
        }

        let ballBounds = CGRect(
            x: center.x - config.ballRadius,
            y: center.y - config.ballRadius,
            width: config.ballRadius * 2,
            height: config.ballRadius * 2
        )
        let ball = NSBezierPath(ovalIn: ballBounds)
        NSColor.white.setFill()
        ball.fill()

        NSColor(calibratedWhite: 0.12, alpha: 0.85).setStroke()
        ball.lineWidth = 1
        ball.stroke()
    }

    var ballCenter: CGPoint {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let pulledCenter = CGPoint(x: center.x + dragVector.dx * 0.35, y: center.y + dragVector.dy * 0.35)
        let inset = config.ballRadius + 12
        let minX = inset
        let maxX = Swift.max(inset, bounds.width - inset)
        let minY = inset
        let maxY = Swift.max(inset, bounds.height - inset)
        return CGPoint(
            x: Swift.max(minX, Swift.min(maxX, pulledCenter.x)),
            y: Swift.max(minY, Swift.min(maxY, pulledCenter.y))
        )
    }

    private func vectorFromBallCenter(to point: CGPoint) -> CGVector {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        return CGVector(dx: point.x - center.x, dy: point.y - center.y)
    }
}
