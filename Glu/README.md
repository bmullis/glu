# Glu

A free, open-source clipboard manager for macOS that provides a horizontally scrollable bottom panel with rich clipboard history, invoked by a global hotkey.

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15+ (for building)

## Build

```bash
# Generate Xcode project (requires xcodegen: brew install xcodegen)
make generate

# Build
make build

# Build and run
make run
```

Or open `Glu.xcodeproj` in Xcode and press Cmd+R.

### First Run

macOS Gatekeeper may block the app since it is not code-signed. To bypass:
- Right-click the app and select "Open", or
- Run `xattr -cr build/Build/Products/Debug/Glu.app` after building

## Permissions

Glu requires **Accessibility** permission to:
- Register the global hotkey (Cmd+Shift+V)
- Simulate paste keystrokes (Cmd+V) into the foreground app

On first launch, Glu will prompt you to grant access. You can also grant it manually:

**System Settings > Privacy & Security > Accessibility** > enable Glu

## Usage

- **Cmd+Shift+V** - Toggle the clipboard history panel
- **Left/Right arrows** - Navigate between clipboard cards
- **Enter** - Paste the selected card
- **Escape** - Dismiss the panel
- **Click** a card to paste it immediately
- **Right-click** a card to delete it
- **Search** - Type in the search bar to filter history

The menu bar icon provides access to:
- Clear History
- Launch at Login toggle
- About / Quit

## Supported Content Types

- Plain text
- URLs (http/https)
- Images (PNG, TIFF)
- File references

## Privacy

- All data is stored locally on your Mac using SwiftData (SQLite)
- Password manager entries marked as concealed are automatically skipped
- No network requests, no telemetry, no cloud sync
