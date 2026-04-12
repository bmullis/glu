## ADDED Requirements

### Requirement: Persistent clipboard entry model
The system SHALL persist clipboard entries using SwiftData with the following fields: `id` (UUID), `content` (Data), `contentType` (enum: text, image, file, url), `textPreview` (optional String for searchability), `sourceAppBundleID` (optional String), `createdAt` (Date), and `size` (Int64, bytes).

#### Scenario: Entry persisted across restart
- **WHEN** the user copies text, quits the app, and relaunches
- **THEN** the previously copied entry SHALL appear in the clipboard history

### Requirement: History ordering
The system SHALL return clipboard entries ordered by `createdAt` descending (most recent first). When an existing item is re-pasted or re-copied, its `createdAt` timestamp SHALL be updated to promote it to the front of history.

#### Scenario: Multiple items copied in sequence
- **WHEN** the user copies "A", then "B", then "C"
- **THEN** the history SHALL display in order: C, B, A

#### Scenario: Re-pasted item promoted to front
- **WHEN** the user pastes item "A" from the history (which was at position 5)
- **THEN** item "A" SHALL move to position 1 in the history

### Requirement: History size limit
The system SHALL enforce a maximum history size of 1000 entries. When the limit is reached, the oldest entries SHALL be deleted to make room for new ones.

#### Scenario: History at capacity
- **WHEN** the history contains 1000 entries and the user copies new content
- **THEN** the oldest entry SHALL be removed and the new entry added

### Requirement: Image data size cap
The system SHALL NOT store image data exceeding 10MB. Images larger than 10MB SHALL be stored as a thumbnail preview only.

#### Scenario: Large screenshot copied
- **WHEN** the user copies a 15MB screenshot
- **THEN** the system SHALL generate and store a downscaled preview under 10MB

### Requirement: Clear history
The system SHALL provide a mechanism to delete all clipboard history entries.

#### Scenario: User clears history
- **WHEN** the user selects "Clear History" from the menu bar
- **THEN** all stored ClipboardEntry records SHALL be deleted

### Requirement: Delete individual entry
The system SHALL provide a mechanism to delete a single clipboard history entry.

#### Scenario: User deletes one entry
- **WHEN** the user right-clicks a clipboard card and selects "Delete"
- **THEN** that single ClipboardEntry SHALL be removed from storage and the panel SHALL update immediately
