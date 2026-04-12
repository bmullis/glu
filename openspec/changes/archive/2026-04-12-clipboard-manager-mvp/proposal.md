## Why

There is no free, open-source clipboard manager for macOS that replicates the polished experience of the Paste App -- a horizontally scrollable bottom panel showing rich clipboard history, invoked by a global hotkey. Existing alternatives are either paid, discontinued, or lack the specific UI pattern of a slide-up panel with visual previews. Glu fills this gap as a locally-built Swift app that can be cloned and run on any Mac without App Store distribution.

## What Changes

- New macOS menu bar application built in Swift/SwiftUI
- Global hotkey (Cmd+Shift+V) registers system-wide to toggle a floating bottom panel
- Continuous clipboard monitoring via NSPasteboard polling captures text, images, links, and files
- Clipboard history persisted locally in SQLite (via SwiftData) so history survives app restarts
- Bottom-anchored borderless window with horizontally scrollable cards showing content previews
- Click-to-paste: selecting a history item copies it to the active pasteboard and pastes it into the foreground app
- Menu bar icon with basic controls (quit, clear history, preferences)

## Capabilities

### New Capabilities
- `clipboard-monitor`: Background service that polls NSPasteboard for changes and stores new entries with content type metadata
- `history-storage`: SQLite-backed persistent storage for clipboard entries including text, image data, file references, and timestamps
- `hotkey-listener`: Global keyboard shortcut registration (Cmd+Shift+V) using the HotKey Swift package
- `panel-ui`: Bottom-anchored floating window with horizontally scrollable card-based clipboard history, supporting text/image/file previews
- `paste-action`: Mechanism to select a history item, place it on the pasteboard, and simulate paste into the foreground application

### Modified Capabilities

(none -- greenfield project)

## Impact

- **Dependencies**: Swift 5.9+, macOS 14+ (Sonoma) for SwiftData, SwiftUI
- **System permissions**: Accessibility access required for global hotkey and simulated paste events
- **Build tooling**: Xcode project with no code signing for local-only distribution; build script for CLI-based builds via xcodebuild
- **No server-side components**: All data stored locally on device
