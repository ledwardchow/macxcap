import AppKit
import IOSurface
import QuartzCore

final class LiveCaptureView: NSView {
    override var wantsLayer: Bool { get { true } set {} }

    override func makeBackingLayer() -> CALayer {
        let l = CALayer()
        l.contentsGravity = .resizeAspect
        l.backgroundColor = NSColor.black.cgColor
        return l
    }

    func update(surface: IOSurface) {
        layer?.contents = surface
    }
}
