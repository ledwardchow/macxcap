import AppKit

final class MenuBarController {
    private var statusItem: NSStatusItem!

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "camera.viewfinder",
                                   accessibilityDescription: "macxcap")
            button.image?.isTemplate = true
        }

        let menu = NSMenu()

        let captureItem = NSMenuItem(title: "Capture Window…",
                                     action: #selector(captureWindow),
                                     keyEquivalent: "")
        captureItem.target = self
        menu.addItem(captureItem)

        let liveItem = NSMenuItem(title: "Live Capture Window…",
                                  action: #selector(liveCaptureWindow),
                                  keyEquivalent: "")
        liveItem.target = self
        menu.addItem(liveItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings…",
                                      action: #selector(openSettings),
                                      keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        menu.addItem(withTitle: "Quit macxcap",
                     action: #selector(NSApplication.terminate(_:)),
                     keyEquivalent: "q")

        statusItem.menu = menu
    }

    @objc private func captureWindow() {
        WindowPickerController.shared.show(mode: .screenshot)
    }

    @objc private func liveCaptureWindow() {
        WindowPickerController.shared.show(mode: .liveCapture)
    }

    @objc private func openSettings() {
        SettingsWindowController.shared.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
