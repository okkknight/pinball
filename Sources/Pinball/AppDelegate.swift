import AppKit
import CoreGraphics
import Foundation
import os

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let physics = PhysicsConfig.default
    private let appName = "Pinball"
    private let logger = Logger(subsystem: "com.linpeiwen.Pinball", category: "lifecycle")

    private var overlayWindowController: OverlayWindowController?
    private var launcherWindowController: LauncherWindowController?
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.info("Pinball didFinishLaunching")
        NSApp.setActivationPolicy(.regular)

        let screen = NSScreen.main ?? NSScreen.screens.first
        guard let screen else {
            NSApp.terminate(nil)
            return
        }

        let overlay = OverlayWindowController(screen: screen, config: physics)
        let launcher = LauncherWindowController(screen: screen, config: physics)
        let menuBar = MenuBarController()

        overlayWindowController = overlay
        launcherWindowController = launcher
        menuBarController = menuBar

        overlay.scene.obstacleRectsProvider = { [weak self] in
            guard let self else { return [] }
            return WindowScanner.scanVisibleWindows(excludingOwners: [self.appName]).map(\.bounds)
        }

        overlay.scene.pauseSimulation(false)
        overlay.scene.configure(
            worldOrigin: screen.frame.origin,
            worldBounds: screen.frame
        )
        overlay.scene.setObstacleRects(
            WindowScanner.scanVisibleWindows(excludingOwners: [appName]).map(\.bounds)
        )

        launcher.onLaunch = { [weak self] launchVector in
            self?.launchBall(launchVector)
        }

        menuBar.onTogglePause = { [weak self] in
            self?.togglePause()
        }
        menuBar.onResetBall = { [weak self] in
            self?.resetBall()
        }
        menuBar.onQuit = { [weak self] in
            self?.quit()
        }

        overlay.showWindow(self)
        launcher.showWindow(self)
        resetBall()
        menuBar.updatePauseTitle(isPaused: false)

        logger.info("Pinball windows shown")
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func launchBall(_ launchVector: CGVector) {
        guard let launcherWindowController else { return }
        overlayWindowController?.scene.launchBall(
            from: launcherWindowController.launchPointInScreenCoordinates,
            velocity: launchVector
        )
        menuBarController?.updatePauseTitle(isPaused: false)
    }

    private func resetBall() {
        guard let launcherWindowController else { return }
        overlayWindowController?.scene.resetBall(at: launcherWindowController.launchPointInScreenCoordinates)
    }

    private func togglePause() {
        guard let menuBarController else { return }
        let newPausedState = !(overlayWindowController?.scene.isSimulationPaused ?? false)
        overlayWindowController?.scene.pauseSimulation(newPausedState)
        menuBarController.updatePauseTitle(isPaused: newPausedState)
    }

    private func quit() {
        NSApp.terminate(nil)
    }
}
