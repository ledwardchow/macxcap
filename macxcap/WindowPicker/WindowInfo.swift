import AppKit
import CoreGraphics

struct WindowInfo: Identifiable {
    let id: CGWindowID
    let ownerName: String
    let title: String
    let bounds: CGRect
    let displayID: CGDirectDisplayID
    var thumbnail: NSImage?
}

func displayContaining(_ bounds: CGRect) -> CGDirectDisplayID {
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    var displayCount: UInt32 = 0
    CGGetDisplaysWithPoint(center, 1, nil, &displayCount)
    if displayCount == 0 { return CGMainDisplayID() }
    var displayID: CGDirectDisplayID = 0
    CGGetDisplaysWithPoint(center, 1, &displayID, &displayCount)
    return displayID
}
