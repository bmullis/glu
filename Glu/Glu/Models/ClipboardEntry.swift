import Foundation
import SwiftData

enum ContentType: String, Codable {
    case text
    case image
    case file
    case url
}

@Model
final class ClipboardEntry {
    @Attribute(.unique) var id: UUID
    var content: Data
    var contentType: ContentType
    var textPreview: String?
    var sourceAppBundleID: String?
    var createdAt: Date
    var size: Int64

    init(
        content: Data,
        contentType: ContentType,
        textPreview: String? = nil,
        sourceAppBundleID: String? = nil,
        createdAt: Date = Date(),
        size: Int64 = 0
    ) {
        self.id = UUID()
        self.content = content
        self.contentType = contentType
        self.textPreview = textPreview
        self.sourceAppBundleID = sourceAppBundleID
        self.createdAt = createdAt
        self.size = size
    }
}
