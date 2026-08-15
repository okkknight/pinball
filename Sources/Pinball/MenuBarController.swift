import AppKit

@MainActor
final class MenuBarController {
    private let statusItem: NSStatusItem
    private let pauseItem: NSMenuItem

    var onTogglePause: (() -> Void)?
    var onResetBall: (() -> Void)?
    var onQuit: (() -> Void)?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        pauseItem = NSMenuItem(title: "Pause", action: #selector(togglePause), keyEquivalent: "")
        pauseItem.target = self

        let resetItem = NSMenuItem(title: "Reset Ball", action: #selector(resetBall), keyEquivalent: "")
        resetItem.target = self

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self

        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(pauseItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(resetItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.image = NSImage(
            systemSymbolName: "circle.grid.cross",
            accessibilityDescription: "Pinball"
        )
        statusItem.button?.image?.isTemplate = true
    }

    func updatePauseTitle(isPaused: Bool) {
        pauseItem.title = isPaused ? "Resume" : "Pause"
    }

    @objc private func togglePause() {
        onTogglePause?()
    }

    @objc private func resetBall() {
        onResetBall?()
    }

    @objc private func quit() {
        onQuit?()
    }
}
