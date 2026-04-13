import SwiftUI

struct ClipboardCardView: View {
    let entry: ClipboardEntry
    let isSelected: Bool
    var themeManager: ThemeManager
    let onSelect: () -> Void
    let onCopy: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            contentPreview
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Spacer(minLength: 4)

            Divider()
                .overlay(themeManager.divider)

            footer
                .padding(.top, 6)
        }
        .padding(12)
        .frame(width: 280, height: 280)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? themeManager.accent : themeManager.divider, lineWidth: isSelected ? 2.5 : 0.5)
        )
        .neuExtruded(theme: themeManager, cornerRadius: 12, intensity: isSelected ? 1.5 : 1.0)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isSelected)
        .onTapGesture { onSelect() }
        .contextMenu {
            Button("Copy") { onCopy() }
            Divider()
            Button("Delete", role: .destructive) { onDelete() }
        }
    }

    @ViewBuilder
    private var contentPreview: some View {
        switch entry.contentType {
        case .text:
            textPreview
        case .url:
            urlPreview
        case .image:
            imagePreview
        case .file:
            filePreview
        }
    }

    @ViewBuilder
    private var textPreview: some View {
        if let text = entry.textPreview {
            Text(text)
                .font(isCode(text) ? .system(size: 11, design: .monospaced) : .system(size: 12))
                .lineSpacing(2)
                .lineLimit(14)
                .foregroundColor(themeManager.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var urlPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "link")
                .font(.system(size: 14))
                .foregroundColor(themeManager.urlColor)
            Text(entry.textPreview ?? "URL")
                .font(.system(size: 11))
                .lineLimit(4)
                .foregroundColor(themeManager.urlColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var imagePreview: some View {
        if let nsImage = NSImage(data: entry.content) {
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 240)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            Image(systemName: "photo")
                .font(.system(size: 28))
                .foregroundColor(themeManager.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private var filePreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "doc.fill")
                .font(.system(size: 20))
                .foregroundColor(themeManager.fileIconColor)
            Text(entry.textPreview ?? "File")
                .font(.system(size: 11))
                .lineLimit(3)
                .foregroundColor(themeManager.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footer: some View {
        HStack {
            Text(entry.createdAt, style: .relative)
                .font(.system(size: 10))
                .foregroundColor(themeManager.textSecondary)
            Spacer()
            if let app = entry.sourceAppBundleID {
                Text(app.components(separatedBy: ".").last ?? app)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(themeManager.textSecondary)
            }
        }
    }

    private func isCode(_ text: String) -> Bool {
        let codeKeywords = [
            "func ", "def ", "const ", "import ", "class ", "struct ",
            "let ", "var ", "return ", "=>", "->", "fn ",
            "if ", "else ", "for ", "while ", "switch ",
            "public ", "private ", "static ", "enum ",
        ]
        let lines = text.components(separatedBy: .newlines)
        let hasIndentation = lines.filter({ $0.hasPrefix("  ") || $0.hasPrefix("\t") }).count >= 2
        let hasBraces = text.contains("{") && text.contains("}")
        let hasKeywords = codeKeywords.contains(where: { text.contains($0) })
        let hasSemicolons = text.contains(";")
        let hasAngleBrackets = text.contains("</") || text.contains("/>") || text.contains("<?")
        let hasXMLDecl = text.contains("<?xml") || text.contains("<!DOCTYPE")
        let hasCodePunctuation = text.contains("()") || text.contains("[];") || text.contains(" = ")

        let signals = [
            hasIndentation, hasBraces, hasKeywords, hasSemicolons,
            hasAngleBrackets, hasXMLDecl, hasCodePunctuation,
        ].filter { $0 }.count
        return signals >= 2
    }
}
