import SwiftUI
import SwiftData
import AppKit

@MainActor
final class PanelState: ObservableObject {
    @Published var selectedID: UUID?
    var entries: [ClipboardEntry] = []
    var onSelect: ((ClipboardEntry) -> Void)?

    func navigate(_ direction: Int) {
        guard !entries.isEmpty else { return }
        guard let currentID = selectedID,
              let currentIndex = entries.firstIndex(where: { $0.id == currentID }) else {
            selectedID = direction > 0 ? entries.first?.id : entries.last?.id
            return
        }
        let newIndex = max(0, min(entries.count - 1, currentIndex + direction))
        selectedID = entries[newIndex].id
    }

    func selectCurrent() {
        guard let id = selectedID,
              let entry = entries.first(where: { $0.id == id }) else { return }
        onSelect?(entry)
    }
}

struct PanelContentView: View {
    @Query(sort: \ClipboardEntry.createdAt, order: .reverse) private var entries: [ClipboardEntry]
    @State private var searchText = ""
    @ObservedObject var panelState: PanelState
    let modelContext: ModelContext
    var themeManager: ThemeManager

    init(modelContext: ModelContext, panelState: PanelState, themeManager: ThemeManager) {
        self.modelContext = modelContext
        self.panelState = panelState
        self.themeManager = themeManager
    }

    private var filteredEntries: [ClipboardEntry] {
        guard !searchText.isEmpty else { return entries }
        let query = searchText.lowercased()
        return entries.filter { entry in
            switch entry.contentType {
            case .text, .url:
                return entry.textPreview?.lowercased().contains(query) ?? false
            case .file:
                return entry.textPreview?.lowercased().contains(query) ?? false
            case .image:
                return "image".contains(query)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            if filteredEntries.isEmpty {
                emptyState
            } else {
                cardScroller
            }
        }
        .background(themeManager.primaryBackground)
        .onChange(of: filteredEntries.map(\.id)) { _, newIDs in
            panelState.entries = filteredEntries
            if panelState.selectedID == nil || !newIDs.contains(panelState.selectedID!) {
                panelState.selectedID = newIDs.first
            }
        }
        .onAppear {
            panelState.entries = filteredEntries
            panelState.selectedID = filteredEntries.first?.id
        }
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            searchBar
            themeToggle
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(themeManager.toolbarBackground)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.textSecondary)
                .font(.system(size: 13))
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search clipboard history...")
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.textSecondary)
                }
                TextField("", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(themeManager.textPrimary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(themeManager.searchBarBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .neuInset(theme: themeManager, cornerRadius: 10)
    }

    private var themeToggle: some View {
        Button(action: { themeManager.toggle() }) {
            Image(systemName: themeManager.mode.iconName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.textSecondary)
                .frame(width: 28, height: 28)
                .background(themeManager.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .neuExtruded(theme: themeManager, cornerRadius: 8, intensity: 0.5)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("Nothing copied yet")
                .font(.system(size: 14))
                .foregroundColor(themeManager.textTertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var cardScroller: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 18) {
                    ForEach(filteredEntries, id: \.id) { entry in
                        ClipboardCardView(
                            entry: entry,
                            isSelected: panelState.selectedID == entry.id,
                            themeManager: themeManager,
                            onSelect: { panelState.onSelect?(entry) },
                            onCopy: { copyEntry(entry) },
                            onDelete: { deleteEntry(entry) }
                        )
                        .id(entry.id)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
            }
            .onChange(of: panelState.selectedID) { _, newID in
                if let id = newID {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }

    private func copyEntry(_ entry: ClipboardEntry) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        switch entry.contentType {
        case .text, .url:
            if let text = String(data: entry.content, encoding: .utf8) {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            pasteboard.setData(entry.content, forType: .png)
        case .file:
            if let urlString = String(data: entry.content, encoding: .utf8) {
                pasteboard.setString(urlString, forType: NSPasteboard.PasteboardType("public.file-url"))
            }
        }
    }

    private func deleteEntry(_ entry: ClipboardEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }
}
