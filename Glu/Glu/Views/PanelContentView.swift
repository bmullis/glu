import SwiftUI
import SwiftData

struct PanelContentView: View {
    @Query(sort: \ClipboardEntry.createdAt, order: .reverse) private var entries: [ClipboardEntry]
    @State private var searchText = ""
    @State private var selectedIndex: Int? = 0
    let modelContext: ModelContext
    let onSelect: (ClipboardEntry) -> Void
    let onNavigate: ((_ register: @escaping (_ direction: Int) -> Void, _ select: @escaping () -> Void) -> Void)?

    init(modelContext: ModelContext, onSelect: @escaping (ClipboardEntry) -> Void, onNavigate: ((_ register: @escaping (_ direction: Int) -> Void, _ select: @escaping () -> Void) -> Void)? = nil) {
        self.modelContext = modelContext
        self.onSelect = onSelect
        self.onNavigate = onNavigate
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
            searchBar
            Divider().opacity(0.3)
            if filteredEntries.isEmpty {
                emptyState
            } else {
                cardScroller
            }
        }
        .background(.ultraThinMaterial)
        .background(Color(nsColor: NSColor(white: 0.08, alpha: 0.6)))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
        .onAppear {
            onNavigate?(navigateSelection, selectCurrent)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.4))
                .font(.system(size: 13))
            TextField("Search clipboard history...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("Nothing copied yet")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.3))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var cardScroller: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 18) {
                    ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                        ClipboardCardView(
                            entry: entry,
                            isSelected: selectedIndex == index,
                            onSelect: { onSelect(entry) },
                            onDelete: { deleteEntry(entry) }
                        )
                        .id(index)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
            }
            .onChange(of: selectedIndex) { _, newIndex in
                if let idx = newIndex {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(idx, anchor: .center)
                    }
                }
            }
        }
    }

    private func navigateSelection(_ direction: Int) {
        let count = filteredEntries.count
        guard count > 0 else { return }
        if let current = selectedIndex {
            selectedIndex = max(0, min(count - 1, current + direction))
        } else {
            selectedIndex = direction > 0 ? 0 : count - 1
        }
    }

    private func selectCurrent() {
        guard let index = selectedIndex, index < filteredEntries.count else { return }
        onSelect(filteredEntries[index])
    }

    private func deleteEntry(_ entry: ClipboardEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }
}
