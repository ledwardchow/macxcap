import SwiftUI

struct SettingsView: View {
    @State private var config = HotKeyConfig.load()

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Capture shortcut")
                    Spacer()
                    ShortcutRecorderView(config: $config)
                        .frame(width: 140, height: 26)
                }
            } header: {
                Text("Global Shortcut")
            } footer: {
                Text("Click the shortcut field, then press a new key combination.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 380)
        .padding(.vertical, 8)
        .onChange(of: config) { newConfig in
            newConfig.save()
            HotKeyManager.shared.config = newConfig
        }
    }
}
