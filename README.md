# macxcap

Menu bar app for macOS that captures any window to a PNG on your Desktop, including any windows that are "protected" with sharingType.NSWindowSharingNone. For example, Windows App when the VDI has "Screen Capture Protection" enabled. 

## Usage

Press **⌃⌥1** to open the window picker, click a window, and the screenshot saves to `~/Desktop/macxcap_<timestamp>.png`. Finder reveals it automatically.

Change the shortcut anytime via the menu bar icon → **Settings…**

For windows that have sharingType.NSWindowSharingNone set, the preview in the overlay will be blank, but the captured PNG will still contain the window's content.

## Requirements

- macOS 13 Ventura or later
- Screen Recording permission (prompted on first launch)

## Build

```sh
xcodegen generate
open macxcap.xcodeproj
```

Run the **macxcap** scheme. No Dock icon — look for the camera viewfinder in your menu bar.
