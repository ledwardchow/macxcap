import AppKit

final class LiveCaptureWindowController: NSWindowController, NSWindowDelegate {
    // Retained until the window is closed.
    private static var sessions: [LiveCaptureWindowController] = []

    private let streamManager = LiveStreamManager()
    private weak var liveView: LiveCaptureView?

    static func launch(info: WindowInfo) {
        let controller = LiveCaptureWindowController(info: info)
        sessions.append(controller)
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private init(info: WindowInfo) {
        let maxSize   = NSScreen.main?.visibleFrame.size ?? NSSize(width: 1440, height: 900)
        let w = min(info.bounds.width,  maxSize.width  * 0.8)
        let h = min(info.bounds.height, maxSize.height * 0.8)
        let contentRect = NSRect(x: 0, y: 0, width: w, height: h)

        let window = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        let label = [info.ownerName, info.title].filter { !$0.isEmpty }.joined(separator: " — ")
        window.title = "Live: \(label)"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentMinSize = NSSize(width: 200, height: 150)

        let view = LiveCaptureView(frame: contentRect)
        view.autoresizingMask = [.width, .height]
        window.contentView = view

        super.init(window: window)
        window.delegate = self
        liveView = view

        let displayBounds = CGDisplayBounds(info.displayID)
        let localRect = CGRect(
            x: info.bounds.origin.x - displayBounds.origin.x,
            y: info.bounds.origin.y - displayBounds.origin.y,
            width: info.bounds.width,
            height: info.bounds.height
        )

        streamManager.onFrame = { [weak self] surface in
            self?.liveView?.update(surface: surface)
        }
        streamManager.start(displayID: info.displayID, sourceRect: localRect)
    }

    required init?(coder: NSCoder) { fatalError() }

    func windowWillClose(_ notification: Notification) {
        streamManager.stop()
        LiveCaptureWindowController.sessions.removeAll { $0 === self }
    }
}
