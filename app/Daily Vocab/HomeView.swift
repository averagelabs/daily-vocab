import SwiftUI
import SwiftData

/// Home tab: shows Today's Word with definition, example, and Save/Unsave.
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isSaved: Bool = false

    /// Deterministic word for today based on day count since 1970
    private var todaysWord: Word? {
        WordService.shared.todaysWord()
    }

    var body: some View {
        Group {
            if let word = todaysWord {
                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Space.xl) {
                        DSCard {
                            VStack(alignment: .leading, spacing: DS.Space.m) {
                                Text(word.word)
                                    .dsHeading()

                                Text(word.definition)
                                    .dsBody()
                                    .foregroundStyle(DS.Color.textPrimary)

                                Spacer().frame(height: DS.Space.xl)

                                VStack(alignment: .leading, spacing: DS.Space.xs) {
                                    Text("Example")
                                        .font(DS.FontToken.body(weight: .semibold))
                                        .foregroundStyle(DS.Color.textPrimary)
                                    Text("\"\(word.example)\"")
                                        .font(DS.FontToken.body())
                                        .foregroundStyle(DS.Color.textSecondary)
                                }
                            }
                        }

                        Button {
                            toggleSave(for: word)
                        } label: {
                            Label(isSaved ? "Unsave" : "Save",
                                  systemImage: isSaved ? "bookmark.slash" : "bookmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        NavigationLink {
                            WordDetailView(word: word)
                        } label: {
                            Text("View details")
                                .font(DS.FontToken.body(weight: .semibold))
                        }
                        .tint(DS.Color.accent)
                    }
                    .padding(DS.Space.xl)
                }
                .background(DS.Color.background)
                .onAppear {
                    // Check saved state when the view appears
                    isSaved = SavedWordStore(context: modelContext).isSaved(wordId: word.id)
                }
            } else {
                ContentUnavailableView(
                    "No words available",
                    systemImage: "book.closed",
                    description: Text("Ensure words.json is included in the app bundle.")
                )
            }
        }
        .background(DS.Color.background)
        .navigationTitle("Today's Word")
    }

    /// Toggles the saved state using SwiftData via SavedWordStore
    private func toggleSave(for word: Word) {
        let store = SavedWordStore(context: modelContext)
        if isSaved {
            store.unsave(wordId: word.id)
            isSaved = false
        } else {
            store.save(wordId: word.id)
            isSaved = true
        }
    }
}

#Preview {
    NavigationStack { HomeView() }
}
