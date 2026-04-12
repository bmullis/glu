import AppKit
import SwiftData
import Foundation

@MainActor
final class ClipboardMonitor: ObservableObject {
    private var timer: Timer?
    private var lastChangeCount: Int
    private let modelContext: ModelContext
    private let pollInterval: TimeInterval = 0.5
    private let maxEntries = 1000
    private let maxImageSize = 10 * 1024 * 1024 // 10MB

    /// Set to true briefly when PasteService writes to the pasteboard,
    /// so we skip re-capturing that item.
    var suppressNextCapture = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPasteboard()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkPasteboard() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        if suppressNextCapture {
            suppressNextCapture = false
            return
        }

        guard let items = pasteboard.pasteboardItems, let item = items.first else { return }

        // Skip concealed items (e.g. passwords from password managers)
        if item.types.contains(NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")) {
            return
        }

        let sourceApp = NSWorkspace.shared.frontmostApplication?.bundleIdentifier

        if let entry = captureEntry(from: item, sourceApp: sourceApp) {
            // Check for duplicate content
            if let existing = findDuplicate(for: entry) {
                existing.createdAt = Date()
            } else {
                modelContext.insert(entry)
                enforceHistoryLimit()
            }
            try? modelContext.save()
        }
    }

    private func captureEntry(from item: NSPasteboardItem, sourceApp: String?) -> ClipboardEntry? {
        let types = item.types

        // Try text first
        if types.contains(.string),
           let text = item.string(forType: .string),
           let data = text.data(using: .utf8) {

            // Detect if it's a URL
            if let url = URL(string: text), url.scheme != nil, (url.scheme == "http" || url.scheme == "https") {
                return ClipboardEntry(
                    content: data,
                    contentType: .url,
                    textPreview: text,
                    sourceAppBundleID: sourceApp,
                    size: Int64(data.count)
                )
            }

            return ClipboardEntry(
                content: data,
                contentType: .text,
                textPreview: String(text.prefix(500)),
                sourceAppBundleID: sourceApp,
                size: Int64(data.count)
            )
        }

        // Try image (PNG then TIFF)
        if let imageData = item.data(forType: .png) ?? item.data(forType: .tiff) {
            let finalData: Data
            if imageData.count > maxImageSize {
                finalData = generateThumbnail(from: imageData) ?? imageData
            } else {
                finalData = imageData
            }
            return ClipboardEntry(
                content: finalData,
                contentType: .image,
                textPreview: nil,
                sourceAppBundleID: sourceApp,
                size: Int64(finalData.count)
            )
        }

        // Try file URL
        if types.contains(NSPasteboard.PasteboardType("public.file-url")),
           let urlString = item.string(forType: NSPasteboard.PasteboardType("public.file-url")),
           let data = urlString.data(using: .utf8) {
            let filename = URL(string: urlString)?.lastPathComponent ?? urlString
            return ClipboardEntry(
                content: data,
                contentType: .file,
                textPreview: filename,
                sourceAppBundleID: sourceApp,
                size: Int64(data.count)
            )
        }

        return nil
    }

    private func findDuplicate(for entry: ClipboardEntry) -> ClipboardEntry? {
        let contentType = entry.contentType
        let descriptor = FetchDescriptor<ClipboardEntry>(
            predicate: #Predicate { $0.contentType == contentType },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        guard let results = try? modelContext.fetch(descriptor) else { return nil }
        return results.first { $0.content == entry.content }
    }

    private func enforceHistoryLimit() {
        let descriptor = FetchDescriptor<ClipboardEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        guard let all = try? modelContext.fetch(descriptor) else { return }
        if all.count > maxEntries {
            let excess = all.count - maxEntries
            for i in 0..<excess {
                modelContext.delete(all[i])
            }
        }
    }

    private func generateThumbnail(from imageData: Data) -> Data? {
        guard let image = NSImage(data: imageData) else { return nil }
        let maxDimension: CGFloat = 1024
        let size = image.size
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        let newSize = NSSize(width: size.width * scale, height: size.height * scale)

        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: NSRect(origin: .zero, size: size),
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()

        guard let tiffData = newImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }
        return pngData
    }
}
