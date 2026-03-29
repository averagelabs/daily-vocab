import SwiftUI

struct WordDetailView: View {
    let word: Word

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.xl) {
                DSCard {
                    VStack(alignment: .leading, spacing: DS.Space.m) {
                        Text(word.word)
                            .dsHeading()

                        Text(word.definition)
                            .dsBody()
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
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(DS.Space.xl)
        }
        .background(DS.Color.background)
        .navigationTitle(word.word)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WordDetailView(word: Word(id: "w1", word: "brevity", definition: "concise and exact use of words in writing or speech.", example: "The speech was praised for its brevity."))
    }
}
