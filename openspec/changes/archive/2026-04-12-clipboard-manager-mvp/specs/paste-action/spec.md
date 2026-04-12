## ADDED Requirements

### Requirement: Pasteboard write-back
When the user selects a clipboard history item, the system SHALL write that item's original content (with its original pasteboard type) back to `NSPasteboard.general`.

#### Scenario: Text item selected
- **WHEN** the user selects a text clipboard entry from the panel
- **THEN** the system SHALL write the text to the general pasteboard as `public.utf8-plain-text`

#### Scenario: Image item selected
- **WHEN** the user selects an image clipboard entry from the panel
- **THEN** the system SHALL write the image data to the general pasteboard with its original UTI type

### Requirement: Simulated paste keystroke
After writing content to the pasteboard, the system SHALL simulate a Cmd+V keystroke via CGEvent to paste the content into the foreground application.

#### Scenario: Paste into foreground app
- **WHEN** the system has written an item to the pasteboard and dismissed the panel
- **THEN** the system SHALL post a CGEvent simulating Cmd+V within 100ms of panel dismissal

### Requirement: Panel dismissal before paste
The panel SHALL be dismissed before the simulated paste keystroke is sent, ensuring the foreground application receives the paste event.

#### Scenario: Paste sequence order
- **WHEN** the user selects a history item
- **THEN** the system SHALL: (1) write to pasteboard, (2) dismiss panel, (3) wait for panel dismissal animation, (4) simulate Cmd+V

### Requirement: History promotion on paste
When a history item is pasted, its `createdAt` timestamp SHALL be updated to the current time so it moves to the front of the history.

#### Scenario: Pasted item moves to front
- **WHEN** the user selects and pastes a history item from position 10
- **THEN** that item SHALL appear at position 1 in the history on next panel open

### Requirement: Clipboard monitor suppression during paste
The clipboard monitor SHALL suppress capturing the item that was just written back to the pasteboard to avoid creating a duplicate entry.

#### Scenario: Paste-back does not create duplicate
- **WHEN** the system writes a history item back to the pasteboard for pasting
- **THEN** the clipboard monitor SHALL NOT create a new entry for that pasteboard change
