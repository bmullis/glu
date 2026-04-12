## 1. Project Setup

- [x] 1.1 Create Xcode project as macOS App (SwiftUI lifecycle, bundle ID: com.glu.clipboard)
- [x] 1.2 Configure Info.plist with LSUIElement = true and NSPasteboardUsageDescription
- [x] 1.3 Add HotKey Swift package dependency via SPM (https://github.com/soffes/HotKey)
- [x] 1.4 Create folder structure: Models/, Services/, Views/, Resources/
- [x] 1.5 Add build script or Makefile for CLI-based builds via xcodebuild
- [x] 1.6 Initialize git repo with .gitignore for Xcode/Swift

## 2. Data Model

- [x] 2.1 Create ClipboardEntry SwiftData model with fields: id, content, contentType, textPreview, sourceAppBundleID, createdAt, size
- [x] 2.2 Define ContentType enum (text, image, file, url)
- [x] 2.3 Configure SwiftData ModelContainer in the app entry point

## 3. Clipboard Monitor Service

- [x] 3.1 Implement ClipboardMonitor class with Timer-based NSPasteboard.general.changeCount polling (0.5s interval)
- [x] 3.2 Add content type detection logic for supported UTI types (plain text, PNG, TIFF, file URL, web URL)
- [x] 3.3 Implement duplicate detection that promotes existing entry to front (update createdAt timestamp)
- [x] 3.4 Add paste-back suppression flag to prevent re-capturing items written by PasteService
- [x] 3.5 Add concealed pasteboard item filtering (skip org.nspasteboard.ConcealedType)
- [x] 3.6 Implement 10MB image size cap with thumbnail generation for oversized images
- [x] 3.7 Enforce 1000-entry history limit with oldest-first deletion
- [x] 3.8 Capture sourceAppBundleID from NSWorkspace.shared.frontmostApplication at copy time

## 4. Global Hotkey

- [x] 4.1 Implement HotkeyManager using HotKey package to register Cmd+Shift+V globally
- [x] 4.2 Wire hotkey to toggle panel visibility (show/hide)
- [x] 4.3 Add Escape key handler to dismiss panel when visible
- [x] 4.4 Implement Accessibility permission check with onboarding dialog and System Settings deep link

## 5. Panel Window

- [x] 5.1 Create PanelWindow (NSPanel subclass) with nonactivatingPanel style, floating window level, anchored to bottom of active screen (NSScreen.main)
- [x] 5.2 Implement slide-up/slide-down animation (0.2s duration)
- [x] 5.3 Add PanelWindowController to manage show/hide lifecycle and screen positioning
- [x] 5.4 Implement click-outside dismissal (dismiss panel when user clicks outside it)

## 6. Panel UI (SwiftUI)

- [x] 6.1 Create PanelContentView with horizontal ScrollView of clipboard cards (~300pt wide each)
- [x] 6.2 Create ClipboardCardView with content-type-specific previews: 4-5 line text truncation (proportional font for prose, monospace for detected code), image thumbnails, file icons, URL display
- [x] 6.3 Implement code detection heuristic for font selection (indentation, braces, keywords like func/def/const/import)
- [x] 6.4 Implement card selection highlighting on click
- [x] 6.5 Add keyboard navigation (left/right arrow keys, Enter to select)
- [x] 6.6 Add right-click context menu on cards with "Delete" option
- [x] 6.7 Add search/filter bar with live filtering (text content, filenames, "image" keyword, source app)
- [x] 6.8 Add empty state placeholder ("Nothing copied yet")
- [x] 6.9 Host PanelContentView inside PanelWindow via NSHostingView

## 7. Paste Action

- [x] 7.1 Implement PasteService that writes selected entry content back to NSPasteboard.general with correct UTI type
- [x] 7.2 Add CGEvent-based Cmd+V simulation with proper timing (after panel dismissal animation completes)
- [x] 7.3 Wire card selection to full paste sequence: write pasteboard, dismiss panel, simulate Cmd+V
- [x] 7.4 Update pasted entry's createdAt timestamp to promote it to front of history

## 8. Menu Bar

- [x] 8.1 Set up MenuBarExtra with app icon and dropdown menu
- [x] 8.2 Add "Clear History" menu item wired to history deletion
- [x] 8.3 Add "Launch at Login" toggle using SMAppService.mainApp
- [x] 8.4 Add "Quit" menu item
- [x] 8.5 Add "About" or version info menu item

## 9. Polish & Documentation

- [x] 9.1 Add README with build instructions, permission setup, and usage guide
- [x] 9.2 Test full workflow: copy items, invoke hotkey, select and paste
- [x] 9.3 Handle edge cases: empty history state, monitor startup, permission denied state
