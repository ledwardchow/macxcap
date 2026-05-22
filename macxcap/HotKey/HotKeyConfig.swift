import Carbon.HIToolbox
import AppKit

struct HotKeyConfig: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32

    static let `default` = HotKeyConfig(
        keyCode: UInt32(kVK_ANSI_1),
        modifiers: UInt32(controlKey | optionKey)
    )

    static let liveDefault = HotKeyConfig(
        keyCode: UInt32(kVK_ANSI_2),
        modifiers: UInt32(controlKey | optionKey)
    )

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var carbon: UInt32 = 0
        if flags.contains(.command) { carbon |= UInt32(cmdKey) }
        if flags.contains(.option)  { carbon |= UInt32(optionKey) }
        if flags.contains(.control) { carbon |= UInt32(controlKey) }
        if flags.contains(.shift)   { carbon |= UInt32(shiftKey) }
        return carbon
    }

    var displayString: String {
        var parts: [String] = []
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if modifiers & UInt32(optionKey)  != 0 { parts.append("⌥") }
        if modifiers & UInt32(shiftKey)   != 0 { parts.append("⇧") }
        if modifiers & UInt32(cmdKey)     != 0 { parts.append("⌘") }
        parts.append(keyCodeToGlyph(keyCode))
        return parts.joined()
    }

    private func keyCodeToGlyph(_ code: UInt32) -> String {
        let table: [UInt32: String] = [
            18: "1", 19: "2", 20: "3", 21: "4", 23: "5",
            22: "6", 26: "7", 28: "8", 25: "9", 29: "0",
            0: "A", 11: "B", 8: "C", 2: "D", 14: "E",
            3: "F", 5: "G", 4: "H", 34: "I", 38: "J",
            40: "K", 37: "L", 46: "M", 45: "N", 31: "O",
            35: "P", 12: "Q", 15: "R", 1: "S", 17: "T",
            32: "U", 9: "V", 13: "W", 7: "X", 16: "Y", 6: "Z",
            36: "↩", 48: "⇥", 49: "Space", 51: "⌫", 53: "⎋",
            123: "←", 124: "→", 125: "↓", 126: "↑",
        ]
        return table[code] ?? "?"
    }
}

extension HotKeyConfig {
    static let userDefaultsKey     = "hotKeyConfig"
    static let liveUserDefaultsKey = "liveHotKeyConfig"

    static func load() -> HotKeyConfig {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let config = try? JSONDecoder().decode(HotKeyConfig.self, from: data)
        else { return .default }
        return config
    }

    static func loadLive() -> HotKeyConfig {
        guard let data = UserDefaults.standard.data(forKey: liveUserDefaultsKey),
              let config = try? JSONDecoder().decode(HotKeyConfig.self, from: data)
        else { return .liveDefault }
        return config
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: HotKeyConfig.userDefaultsKey)
        }
    }

    func saveLive() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: HotKeyConfig.liveUserDefaultsKey)
        }
    }
}
