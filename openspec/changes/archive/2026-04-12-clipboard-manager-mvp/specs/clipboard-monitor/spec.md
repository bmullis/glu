## ADDED Requirements

### Requirement: Pasteboard change detection
The system SHALL poll `NSPasteboard.general.changeCount` at 0.5-second intervals to detect new clipboard content.

#### Scenario: New text copied
- **WHEN** the user copies text in any application and the pasteboard changeCount increments
- **THEN** the system SHALL read the pasteboard contents and create a new ClipboardEntry in storage

#### Scenario: Duplicate content promotes to front
- **WHEN** the pasteboard changeCount increments but the content is identical to an existing stored entry
- **THEN** the system SHALL NOT create a duplicate entry and SHALL update the existing entry's `createdAt` timestamp to move it to the front of history

### Requirement: Multi-type content capture
The system SHALL capture clipboard content of the following types: plain text (`public.utf8-plain-text`), images (`public.png`, `public.tiff`), file URLs (`public.file-url`), and web URLs (`public.url`).

#### Scenario: Image copied from browser
- **WHEN** the user copies an image and the pasteboard contains `public.png` or `public.tiff` data
- **THEN** the system SHALL store the image data as a ClipboardEntry with contentType set to `image`

#### Scenario: File copied in Finder
- **WHEN** the user copies a file and the pasteboard contains `public.file-url`
- **THEN** the system SHALL store the file URL path (not the file contents) as a ClipboardEntry with contentType set to `file`

### Requirement: Concealed pasteboard item filtering
The system SHALL check for the `org.nspasteboard.ConcealedType` UTI on pasteboard items. Items marked as concealed (e.g., passwords from password managers) SHALL be silently skipped and not stored.

#### Scenario: Password copied from 1Password
- **WHEN** the user copies a password from a password manager and the pasteboard contains `org.nspasteboard.ConcealedType`
- **THEN** the system SHALL NOT create a ClipboardEntry for that item

### Requirement: Background operation
The clipboard monitor SHALL start automatically when the app launches and continue running while the app is active, regardless of whether the panel UI is visible.

#### Scenario: App launched
- **WHEN** the application starts
- **THEN** the clipboard monitor SHALL begin polling within 1 second of app launch

#### Scenario: Panel dismissed
- **WHEN** the user dismisses the panel UI
- **THEN** the clipboard monitor SHALL continue polling for new clipboard content
