import AppKit
import CoreGraphics

@MainActor
final class WindowPickerViewModel: ObservableObject {
    @Published var windows: [WindowInfo] = []
    @Published var isLoading = false

    func load() {
        isLoading = true
        windows = []

        guard let list = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else {
            isLoading = false
            return
        }

        let myPID = ProcessInfo.processInfo.processIdentifier

        var items: [WindowInfo] = []
        for dict in list {
            guard
                (dict[kCGWindowLayer as String] as? Int) == 0,
                (dict[kCGWindowOwnerPID as String] as? pid_t) != myPID,
                let wid = dict[kCGWindowNumber as String] as? CGWindowID,
                let boundsDict = dict[kCGWindowBounds as String] as? [String: CGFloat],
                let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary),
                bounds.width > 10, bounds.height > 10
            else { continue }

            let owner = dict[kCGWindowOwnerName as String] as? String ?? ""
            let title = dict[kCGWindowName as String] as? String ?? ""
            let display = displayContaining(bounds)

            var info = WindowInfo(id: wid, ownerName: owner, title: title,
                                  bounds: bounds, displayID: display)

            // Thumbnail via CGWindowListCreateImage (deprecated macOS 14, removed macOS 15)
            // For macOS 13-14 this is the correct approach
            let cgThumb = CGWindowListCreateImage(
                .null,
                .optionIncludingWindow,
                wid,
                [.boundsIgnoreFraming, .nominalResolution]
            )
            if let cgThumb {
                info.thumbnail = NSImage(cgImage: cgThumb, size: .zero)
            }

            items.append(info)
        }

        windows = items
        isLoading = false
    }
}
