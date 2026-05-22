# macxcap

Menu bar app for macOS that captures any window to a PNG on your Desktop/streams a window to another window, including any windows that are "protected" with sharingType.NSWindowSharingNone. For example, Windows App when the VDI has "Screen Capture Protection" enabled. 

## Usage

Press **⌃⌥1** to open the window picker, click a window, and the screenshot saves to `~/Desktop/macxcap_<timestamp>.png`. Finder reveals it automatically.
For windows that have sharingType.NSWindowSharingNone set, the preview in the overlay will be blank, but the captured PNG will still contain the window's content.

Press **⌃⌥2** to start a live video capture of a window (for example, if you want to share a window that has sharingType.NSWindowSharingNone set). It will open another window that captures the selected screen region. Make sure you have your source window put in a comfortable location on your screen, this will capture the screen area so if you move the window the video capture won't move with it!

Change the shortcut anytime via the menu bar icon → **Settings…**



## Requirements

- macOS 13 Ventura or later
- Screen Recording permission (prompted on first launch)

## Build

```sh
xcodegen generate
open macxcap.xcodeproj
```

Run the **macxcap** scheme. No Dock icon — look for the camera viewfinder in your menu bar.
