import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

@MainActor
final class ScreenCaptureManager {
    static let shared = ScreenCaptureManager()
    private init() {}

    private(set) var hasPermission = false
    private let streamCapture = DisplayStreamCapture()

    func checkPermission() {
        if CGPreflightScreenCaptureAccess() {
            hasPermission = true
        } else {
            CGRequestScreenCaptureAccess()
            hasPermission = CGPreflightScreenCaptureAccess()
        }
    }

    func requestPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = "macxcap needs Screen Recording access to capture windows. " +
            "Please grant access in System Settings → Privacy & Security → Screen Recording, " +
            "then relaunch the app."
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(
                URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
            )
        }
    }

    func captureAndSave(_ info: WindowInfo) async {
        do {
            let displayBounds = CGDisplayBounds(info.displayID)
            let localRect = CGRect(
                x: info.bounds.origin.x - displayBounds.origin.x,
                y: info.bounds.origin.y - displayBounds.origin.y,
                width: info.bounds.width,
                height: info.bounds.height
            )
            let image = try await streamCapture.capture(
                displayID: info.displayID,
                sourceRect: localRect
            )
            try savePNG(image)
        } catch {
            showError(error)
        }
    }

    private func savePNG(_ image: CGImage) throws {
        let desktop = FileManager.default
            .urls(for: .desktopDirectory, in: .userDomainMask)[0]
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let url = desktop.appendingPathComponent("macxcap_\(fmt.string(from: Date())).png")

        guard let dest = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else { throw CaptureError.noDestination }

        CGImageDestinationAddImage(dest, image, nil)
        guard CGImageDestinationFinalize(dest) else { throw CaptureError.finalizeFailed }

        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func showError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Capture Failed"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.runModal()
    }
}
