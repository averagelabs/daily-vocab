import SwiftUI
import SwiftData

/// My Words tab: lists saved words with swipe-to-delete and detail navigation.
struct MyWordsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedWord.savedAt, order: .reverse) private var saved: [SavedWord]

    /// Build a fast lookup dictionary from bundled words keyed by id.
    private var wordsById: [String: Word] {
        if WordService.shared.words.isEmpty {
            _ = try? WordService.shared.loadWords()
        }
        return Dictionary(uniqueKeysWithValues: WordService.shared.words.map { ($0.id, $0) })
    }

    var body: some View {
        Group {
            if saved.isEmpty {
                EmptyStateView(
                    illustrationName: "DS.Illustration.EmptySaved",
                    title: "No saved words",
                    message: "Save words from Today's Word to see them here.")
            } else {
                List {
                    ForEach(saved) { savedWord in
                        if let word = wordsById[savedWord.wordId] {
                            NavigationLink {
                                WordDetailView(word: word)
                            } label: {
                                VStack(alignment: .leading, spacing: DS.Space.xs) {
                                    Text(word.word)
                                        .font(DS.FontToken.body(weight: .semibold))
                                        .foregroundStyle(DS.Color.textPrimary)
                                    Text(word.definition)
                                        .font(DS.FontToken.body(size: 14))
                                        .foregroundStyle(DS.Color.textSecondary)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, DS.Space.xs)
                            }
                        } else {
                            Text("Missing word: \(savedWord.wordId)")
                                .font(DS.FontToken.body(size: 14))
                                .foregroundStyle(DS.Color.textSecondary)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(DS.Color.background)
            }
        }
        .background(DS.Color.background)
        .navigationTitle("My Words")
    }

    /// Deletes saved words at the given offsets.
    private func delete(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(saved[index]) }
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack { MyWordsView() }
}
