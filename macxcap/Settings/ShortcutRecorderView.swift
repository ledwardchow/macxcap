import AppKit
import SwiftUI
import Carbon.HIToolbox

// MARK: - NSViewRepresentable wrapper

struct ShortcutRecorderView: NSViewRepresentable {
    @Binding var config: HotKeyConfig

    func makeNSView(context: Context) -> ShortcutRecorderNSView {
        let view = ShortcutRecorderNSView()
        view.onChange = { newConfig in
            config = newConfig
        }
        view.onRecordingStart = {
            HotKeyManager.shared.unregister()
        }
        view.onRecordingEnd = {
            HotKeyManager.shared.register()
        }
        return view
    }

    func updateNSView(_ nsView: ShortcutRecorderNSView, context: Context) {
        nsView.currentConfig = config
        if !nsView.isRecording {
            nsView.updateDisplay()
        }
    }
}

// MARK: - Custom NSView

final class ShortcutRecorderNSView: NSView {
    var currentConfig: HotKeyConfig = .load() {
        didSet { updateDisplay() }
    }
    var isRecording = false
    var onChange: ((HotKeyConfig) -> Void)?
    var onRecordingStart: (() -> Void)?
    var onRecordingEnd: (() -> Void)?

    private let label = NSTextField(labelWithString: "")

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true
        layer?.cornerRadius = 5
        layer?.borderWidth = 1

        label.translatesAutoresizingMaskIntoConstraints = false
        label.alignment = .center
        label.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .medium)
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        let click = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        addGestureRecognizer(click)

        updateDisplay()
    }

    @objc private func handleClick() {
        if isRecording {
            cancelRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        onRecordingStart?()
        window?.makeFirstResponder(self)
        updateDisplay()
    }

    private func cancelRecording() {
        isRecording = false
        onRecordingEnd?()
        updateDisplay()
    }

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard isRecording else { super.keyDown(with: event); return }

        if event.keyCode == UInt16(kVK_Escape) {
            cancelRecording()
            return
        }

        let mods = event.modifierFlags.intersection([.command, .option, .control, .shift])
        guard !mods.isEmpty else { return }

        let newConfig = HotKeyConfig(
            keyCode: UInt32(event.keyCode),
            modifiers: HotKeyConfig.carbonModifiers(from: mods)
        )
        isRecording = false
        onRecordingEnd?()
        onChange?(newConfig)
        updateDisplay()
    }

    func updateDisplay() {
        if isRecording {
            layer?.backgroundColor = NSColor.selectedControlColor.cgColor
            layer?.borderColor = NSColor.controlAccentColor.cgColor
            label.stringValue = "Type shortcut…"
            label.textColor = .labelColor
        } else {
            layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
            layer?.borderColor = NSColor.separatorColor.cgColor
            label.stringValue = currentConfig.displayString
            label.textColor = .labelColor
        }
    }

    override func resignFirstResponder() -> Bool {
        if isRecording { cancelRecording() }
        return super.resignFirstResponder()
    }
}
