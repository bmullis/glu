## Context

Glu is a greenfield macOS clipboard manager built in Swift/SwiftUI. There is no existing codebase. The target is macOS 14+ (Sonoma) to leverage SwiftData for persistence and modern SwiftUI APIs for the panel UI. The app runs as a menu bar agent (LSUIElement) with no dock icon, monitoring the system pasteboard in the background and presenting a floating panel on demand.

## Goals / Non-Goals

**Goals:**
- Deliver a functional clipboard manager that captures text, images, file references, and rich text
- Provide a polished bottom-panel UI with horizontal scrolling, invoked via global hotkey
- Persist history across app restarts using local SQLite storage
- Keep the project buildable from a fresh clone with `xcodebuild` or Xcode, no signing required

**Non-Goals:**
- iCloud sync or cross-device clipboard sharing
- iOS/iPadOS companion app
- App Store distribution, notarization, or code signing
- Plugin system or extensibility
- Pinboards, folders, or organizational features beyond chronological history
- Clipboard rules or app-specific exclusions beyond concealed item filtering
- Rich text (RTF) support -- user's workflow is code, markdown, and plain text

## Decisions

### 1. App lifecycle: Menu bar agent (NSApp + LSUIElement)

Use `LSUIElement = true` in Info.plist so the app lives in the menu bar only. SwiftUI's `MenuBarExtra` provides the menu bar icon. The floating panel is a separate `NSWindow` managed outside the normal SwiftUI window lifecycle.

**Why not a regular SwiftUI App with .windowStyle?** SwiftUI's window management doesn't support borderless, bottom-anchored, always-on-top panels well. We need precise control over window level, activation policy, and animation.

### 2. Panel window: NSPanel subclass via AppKit

The bottom panel is an `NSPanel` (subclass of `NSWindow`) configured as:
- `.nonactivatingPanel` style mask so the foreground app doesn't lose focus
- `.hudWindow` backing for translucency
- Window level set to `.floating`
- Anchored to the bottom of the active screen (`NSScreen.main`), full width
- Content is a hosted SwiftUI view via `NSHostingView`

**Why NSPanel over pure SwiftUI?** NSPanel with `.nonactivatingPanel` is the only way to show a floating UI without stealing focus from the app the user is working in. This is critical for a clipboard manager.

### 3. Global hotkey: HotKey Swift package

Use the [HotKey](https://github.com/soffes/HotKey) Swift package (MIT license). It wraps the Carbon Event API for registering global hotkeys. Registered hotkey: Cmd+Shift+V. This is simpler and more reliable than raw CGEvent taps, and doesn't require Accessibility permissions just for the hotkey itself.

**Alternative considered:** CGEvent tap. More powerful but requires Accessibility permissions upfront and more boilerplate. Since we only need a single hotkey, HotKey is sufficient.

### 4. Clipboard monitoring: NSPasteboard polling with Timer

Poll `NSPasteboard.general.changeCount` every 0.5 seconds. When the count changes, read the pasteboard contents and store them. This is the standard macOS approach since there is no notification API for pasteboard changes.

**Why 0.5s?** Balances responsiveness with CPU usage. The check is a single integer comparison when nothing has changed.

### 5. Persistence: SwiftData with SQLite

Use SwiftData (`@Model`) for the clipboard entry model. SwiftData provides:
- Automatic SQLite storage
- Simple querying and sorting
- Image data stored as `Data` blobs (with a reasonable size cap of ~10MB per entry)
- Content types: text, image, file, url (no rich text -- user's workflow is code/markdown/plain text)

**Alternative considered:** Raw SQLite via GRDB or similar. SwiftData is simpler for this use case and avoids an additional dependency.

### 6. Paste action: NSPasteboard write + CGEvent simulated Cmd+V

When the user selects a history item:
1. Write the item's content back to `NSPasteboard.general`
2. Dismiss the panel
3. Simulate Cmd+V keypress via `CGEvent` to paste into the foreground app

This requires Accessibility permissions. The app will prompt for them on first use.

### 7. Project structure: Xcode project with SPM dependencies

```
Glu/
  Glu.xcodeproj/
  Glu/
    GluApp.swift          # App entry point, menu bar setup
    Models/
      ClipboardEntry.swift  # SwiftData model
    Services/
      ClipboardMonitor.swift  # Pasteboard polling
      HotkeyManager.swift     # Global hotkey registration
      PasteService.swift      # Paste-back logic
    Views/
      PanelWindow.swift       # NSPanel setup
      PanelContentView.swift  # SwiftUI horizontal scroll view
      ClipboardCardView.swift # Individual history card
    Resources/
      Info.plist
      Assets.xcassets
  Package.swift (or via Xcode SPM)
```

## Risks / Trade-offs

- **[Accessibility permissions required]** The app needs Accessibility access for simulating paste keystrokes. Users must manually grant this in System Settings > Privacy & Security > Accessibility. There is no way to automate this grant.
  - Mitigation: Show a clear onboarding prompt directing users to the right settings pane.

- **[NSPasteboard polling misses rapid changes]** If a user copies twice within 0.5s, the intermediate value may be missed.
  - Mitigation: Acceptable for MVP. Could reduce interval or use `DistributedNotificationCenter` heuristics later.

- **[Large clipboard items (images, files)]** Storing large images as Data blobs could bloat the database.
  - Mitigation: Cap stored image data at 10MB. For file references, store the file URL rather than file contents.

- **[macOS 14+ requirement]** Limits compatibility to relatively recent macOS versions.
  - Mitigation: macOS 14 adoption is high. SwiftData is a significant simplification that justifies this floor.

- **[No code signing]** Without signing, macOS Gatekeeper will block the app on first run.
  - Mitigation: Users right-click > Open to bypass, or run `xattr -cr Glu.app` after building. Document this in README.
