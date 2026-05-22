import Carbon.HIToolbox
import AppKit

final class HotKeyManager {
    static let shared = HotKeyManager()
    private init() {}

    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?
    // 'mxcp' as a four-character code
    private let hotKeyID = EventHotKeyID(signature: 0x6D786370, id: 1)

    var config: HotKeyConfig {
        get { HotKeyConfig.load() }
        set {
            newValue.save()
            register()
        }
    }

    func register() {
        unregister()
        installHandlerIfNeeded()
        let cfg = config
        let status = RegisterEventHotKey(
            cfg.keyCode,
            cfg.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        if status != noErr {
            NSLog("macxcap: RegisterEventHotKey failed with status \(status)")
        }
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }

    private func installHandlerIfNeeded() {
        guard handlerRef == nil else { return }
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData -> OSStatus in
                guard let userData, let event else { return OSStatus(eventNotHandledErr) }
                var firedID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &firedID
                )
                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                if firedID.signature == manager.hotKeyID.signature,
                   firedID.id == manager.hotKeyID.id {
                    DispatchQueue.main.async {
                        WindowPickerController.shared.show()
                    }
                }
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            &handlerRef
        )
    }
}
