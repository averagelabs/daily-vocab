import SwiftUI
import SwiftData

/// Review tab: presents flashcards for saved words that are due today.
struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var due: [SavedWord] = []
    @State private var showingBack = false

    /// Lookup words by id from bundled JSON.
    private var wordsById: [String: Word] {
        if WordService.shared.words.isEmpty {
            _ = try? WordService.shared.loadWords()
        }
        return Dictionary(uniqueKeysWithValues: WordService.shared.words.map { ($0.id, $0) })
    }

    private var currentSaved: SavedWord? { due.first }

    private var currentWord: Word? {
        guard let id = currentSaved?.wordId else { return nil }
        return wordsById[id]
    }

    var body: some View {
        Group {
            if let word = currentWord {
                VStack(spacing: DS.Space.xl) {
                    Text("\(due.count) left today")
                        .font(DS.FontToken.body(size: 14))
                        .foregroundStyle(DS.Color.textSecondary)

                    // Flashcard
                    DSCard {
                        VStack(alignment: .leading, spacing: DS.Space.m) {
                            if showingBack {
                                Text(word.definition)
                                    .font(DS.FontToken.body(size: 20))
                                    .foregroundStyle(DS.Color.textPrimary)

                                Spacer().frame(height: DS.Space.s)

                                VStack(alignment: .leading, spacing: DS.Space.xs) {
                                    Text("Example")
                                        .font(DS.FontToken.body(weight: .semibold))
                                        .foregroundStyle(DS.Color.textPrimary)

                                    Text("\"\(word.example)\"")
                                        .font(DS.FontToken.body())
                                        .foregroundStyle(DS.Color.textSecondary)
                                }

                                // Fill remaining height so card stays tall, while content stays top-aligned
                                Spacer(minLength: 0)
                            } else {
                                // Center the word without relying on the Text stretching the card
                                Spacer(minLength: 0)
                                Text(word.word)
                                    .dsHeading()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                Spacer(minLength: 0)
                            }
                        }
                        // Make the content area fill the card and keep back-side content pinned to top
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                     // Make the card itself take the available height so it doesn't shrink on the back
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        withAnimation(.spring) { showingBack.toggle() }
                    }

                    HStack(spacing: DS.Space.m) {
                        Button("Didn't know") { review(knewIt: false) }
                            .buttonStyle(SecondaryButtonStyle())

                        Button("Knew it") { review(knewIt: true) }
                            .buttonStyle(PrimaryButtonStyle())
                    }

                    Spacer(minLength: 0)
                }
                .padding(DS.Space.xl)
                .background(DS.Color.background)
                .navigationTitle("Review")
            } else {
                EmptyStateView(
                    illustrationName: "DS.Illustration.EmptyReview",
                    title: "Nothing to Review",
                    message: "You're all caught up for today.")
                .navigationTitle("Review")
            }
        }
        .onAppear(perform: loadDue)
    }

    private func loadDue() {
        let store = SavedWordStore(context: modelContext)
        due = store.fetchDueWords()
        showingBack = false
    }

    private func review(knewIt: Bool) {
        guard let saved = currentSaved else { return }
        let store = SavedWordStore(context: modelContext)
        store.updateAfterReview(wordId: saved.wordId, knewIt: knewIt)
        // Remove current card and reset
        if !due.isEmpty { due.removeFirst() }
        withAnimation(.easeInOut) {
            showingBack = false
        }
    }
}

#Preview {
    NavigationStack { ReviewView() }
}
