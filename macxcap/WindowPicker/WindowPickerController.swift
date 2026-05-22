import AppKit
import SwiftUI

enum CaptureMode {
    case screenshot
    case liveCapture
}

final class WindowPickerController: NSWindowController {
    static let shared = WindowPickerController()

    private init() {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let panel = NSPanel(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)) + 1)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.animationBehavior = .none
        super.init(window: panel)
    }

    required init?(coder: NSCoder) { fatalError() }

    func show(mode: CaptureMode = .screenshot) {
        guard ScreenCaptureManager.shared.hasPermission else {
            ScreenCaptureManager.shared.requestPermissionAlert()
            return
        }

        let screen = NSScreen.main ?? NSScreen.screens[0]
        window?.setFrame(screen.frame, display: false)

        let pickerTitle = mode == .screenshot
            ? "Select a Window to Capture"
            : "Select a Window to Stream Live"

        let view = WindowPickerView(
            title: pickerTitle,
            onSelect: { [weak self] item in
                self?.dismiss()
                switch mode {
                case .screenshot:
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(250))
                        await ScreenCaptureManager.shared.captureAndSave(item)
                    }
                case .liveCapture:
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(150))
                        LiveCaptureWindowController.launch(info: item)
                    }
                }
            },
            onCancel: { [weak self] in
                self?.dismiss()
            }
        )

        window?.contentView = NSHostingView(rootView: view)
        showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKey()
    }

    private func dismiss() {
        close()
    }
}
