import SwiftUI

struct SettingsView: View {
    @State private var screenshotConfig  = HotKeyConfig.load()
    @State private var liveCaptureConfig = HotKeyConfig.loadLive()

    var body: some View {
        Form {
            Section {
                shortcutRow(label: "Screenshot", config: $screenshotConfig)
            } header: {
                Text("Screenshot  (⌃⌥1 default)")
            }
            Section {
                shortcutRow(label: "Live capture", config: $liveCaptureConfig)
            } header: {
                Text("Live Capture  (⌃⌥2 default)")
            }
        }
        .formStyle(.grouped)
        .frame(width: 400)
        .padding(.vertical, 8)
        .onChange(of: screenshotConfig) { newConfig in
            newConfig.save()
            HotKeyManager.shared.screenshotConfig = newConfig
        }
        .onChange(of: liveCaptureConfig) { newConfig in
            newConfig.saveLive()
            HotKeyManager.shared.liveCaptureConfig = newConfig
        }
    }

    @ViewBuilder
    private func shortcutRow(label: String, config: Binding<HotKeyConfig>) -> some View {
        HStack {
            Text(label)
            Spacer()
            ShortcutRecorderView(config: config)
                .frame(width: 140, height: 26)
        }
    }
}
