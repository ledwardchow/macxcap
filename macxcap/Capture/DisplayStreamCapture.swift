import CoreGraphics
import CoreImage
import IOSurface

enum CaptureError: Error, LocalizedError {
    case streamCreationFailed
    case noImageFromSurface
    case noDestination
    case finalizeFailed

    var errorDescription: String? {
        switch self {
        case .streamCreationFailed: return "Could not create display stream."
        case .noImageFromSurface:   return "Could not convert display frame to image."
        case .noDestination:        return "Could not create output file on Desktop."
        case .finalizeFailed:       return "Could not write PNG to Desktop."
        }
    }
}

final class DisplayStreamCapture {
    // Captures a rect (in display-local CG point coordinates) from the given display.
    func capture(displayID: CGDirectDisplayID, sourceRect: CGRect) async throws -> CGImage {
        let pixelsWide = Int(CGDisplayPixelsWide(displayID))
        let displayWidth = Int(CGDisplayBounds(displayID).width)
        let scale = displayWidth > 0 ? pixelsWide / displayWidth : 2

        let outW = max(1, Int(sourceRect.width)  * scale)
        let outH = max(1, Int(sourceRect.height) * scale)

        let sourceRectDict = CGRectCreateDictionaryRepresentation(sourceRect)
        let props: [CFString: Any] = [
            CGDisplayStream.sourceRect: sourceRectDict,
            CGDisplayStream.queueDepth: 3,
            CGDisplayStream.showCursor: false,
        ]

        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false

            let stream = CGDisplayStream(
                dispatchQueueDisplay: displayID,
                outputWidth: outW,
                outputHeight: outH,
                pixelFormat: Int32(kCVPixelFormatType_32BGRA),
                properties: props as CFDictionary,
                queue: .global(qos: .userInitiated)
            ) { [weak self] status, _, surface, _ in
                guard !didResume else { return }
                guard status == .frameComplete, let surface else { return }
                didResume = true
                _ = self  // capture self to keep stream alive until first frame

                let ciImage = CIImage(ioSurface: surface)
                let ctx = CIContext(options: [.useSoftwareRenderer: false])
                if let cgImage = ctx.createCGImage(ciImage, from: ciImage.extent) {
                    continuation.resume(returning: cgImage)
                } else {
                    continuation.resume(throwing: CaptureError.noImageFromSurface)
                }
            }

            guard let stream else {
                continuation.resume(throwing: CaptureError.streamCreationFailed)
                return
            }
            stream.start()
        }
    }
}
