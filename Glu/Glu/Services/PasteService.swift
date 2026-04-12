import AppKit
import SwiftData

@MainActor
final class PasteService {
    private let clipboardMonitor: ClipboardMonitor
    private let modelContext: ModelContext

    init(clipboardMonitor: ClipboardMonitor, modelContext: ModelContext) {
        self.clipboardMonitor = clipboardMonitor
        self.modelContext = modelContext
    }

    func paste(entry: ClipboardEntry) {
        writeToPasteboard(entry: entry)
        promoteEntry(entry)
    }

    func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true) // V key
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func writeToPasteboard(entry: ClipboardEntry) {
        clipboardMonitor.suppressNextCapture = true

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch entry.contentType {
        case .text:
            pasteboard.setData(entry.content, forType: .string)
        case .url:
            pasteboard.setData(entry.content, forType: .string)
            if let urlString = String(data: entry.content, encoding: .utf8),
               let url = URL(string: urlString) {
                pasteboard.setString(url.absoluteString, forType: .URL)
            }
        case .image:
            pasteboard.setData(entry.content, forType: .png)
        case .file:
            if let urlString = String(data: entry.content, encoding: .utf8) {
                pasteboard.setString(urlString, forType: NSPasteboard.PasteboardType("public.file-url"))
            }
        }
    }

    private func promoteEntry(_ entry: ClipboardEntry) {
        entry.createdAt = Date()
        try? modelContext.save()
    }
}
