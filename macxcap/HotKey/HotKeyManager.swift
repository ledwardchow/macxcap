import Carbon.HIToolbox
import AppKit

final class HotKeyManager {
    static let shared = HotKeyManager()
    private init() {}

    private var screenshotRef: EventHotKeyRef?
    private var liveRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?

    // 'mxcp' signature; id 1 = screenshot, id 2 = live capture
    private let sig: OSType = 0x6D786370
    private var screenshotHotKeyID: EventHotKeyID { EventHotKeyID(signature: sig, id: 1) }
    private var liveHotKeyID:       EventHotKeyID { EventHotKeyID(signature: sig, id: 2) }

    var screenshotConfig: HotKeyConfig {
        get { HotKeyConfig.load() }
        set { newValue.save(); register() }
    }

    var liveCaptureConfig: HotKeyConfig {
        get { HotKeyConfig.loadLive() }
        set { newValue.saveLive(); register() }
    }

    func register() {
        unregister()
        installHandlerIfNeeded()

        let shot = screenshotConfig
        RegisterEventHotKey(shot.keyCode, shot.modifiers,
                            screenshotHotKeyID, GetApplicationEventTarget(), 0, &screenshotRef)

        let live = liveCaptureConfig
        RegisterEventHotKey(live.keyCode, live.modifiers,
                            liveHotKeyID, GetApplicationEventTarget(), 0, &liveRef)
    }

    func unregister() {
        if let ref = screenshotRef { UnregisterEventHotKey(ref); screenshotRef = nil }
        if let ref = liveRef       { UnregisterEventHotKey(ref); liveRef       = nil }
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
                GetEventParameter(event,
                                  EventParamName(kEventParamDirectObject),
                                  EventParamType(typeEventHotKeyID),
                                  nil,
                                  MemoryLayout<EventHotKeyID>.size,
                                  nil,
                                  &firedID)
                let mgr = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                guard firedID.signature == mgr.sig else { return OSStatus(eventNotHandledErr) }
                DispatchQueue.main.async {
                    switch firedID.id {
                    case 1: WindowPickerController.shared.show(mode: .screenshot)
                    case 2: WindowPickerController.shared.show(mode: .liveCapture)
                    default: break
                    }
                }
                return noErr
            },
            1, &eventType, selfPtr, &handlerRef
        )
    }
}
