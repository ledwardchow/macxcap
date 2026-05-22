import CoreGraphics
import CoreVideo
import IOSurface

final class LiveStreamManager {
    private var stream: CGDisplayStream?
    var onFrame: ((IOSurface) -> Void)?

    func start(displayID: CGDirectDisplayID, sourceRect: CGRect) {
        stop()

        let pixelsWide  = Int(CGDisplayPixelsWide(displayID))
        let displayWidth = Int(CGDisplayBounds(displayID).width)
        let scale = displayWidth > 0 ? pixelsWide / displayWidth : 2

        let outW = max(1, Int(sourceRect.width)  * scale)
        let outH = max(1, Int(sourceRect.height) * scale)

        let props: [CFString: Any] = [
            CGDisplayStream.sourceRect: CGRectCreateDictionaryRepresentation(sourceRect),
            CGDisplayStream.queueDepth: 3,
            CGDisplayStream.showCursor: false,
        ]

        stream = CGDisplayStream(
            dispatchQueueDisplay: displayID,
            outputWidth: outW,
            outputHeight: outH,
            pixelFormat: Int32(kCVPixelFormatType_32BGRA),
            properties: props as CFDictionary,
            queue: .main
        ) { [weak self] status, _, surface, _ in
            guard status == .frameComplete, let surface else { return }
            self?.onFrame?(surface)
        }
        stream?.start()
    }

    func stop() {
        stream?.stop()
        stream = nil
    }

    deinit { stop() }
}
