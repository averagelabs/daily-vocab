import WidgetKit
import SwiftUI

private struct WidgetWord: Decodable, Identifiable {
    let id: String
    let word: String
    let definition: String
    let example: String
}

private func loadWordsFromBundle() -> [WidgetWord] {
    guard let url = Bundle.main.url(forResource: "words", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let words = try? JSONDecoder().decode([WidgetWord].self, from: data) else {
        return []
    }
    return words
}

private func todaysWord(from words: [WidgetWord], date: Date) -> WidgetWord? {
    guard !words.isEmpty else { return nil }
    let secondsPerDay: TimeInterval = 24 * 60 * 60
    let daysSince1970 = Int(date.timeIntervalSince1970 / secondsPerDay)
    let index = daysSince1970 % words.count
    return words[index]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), word: "Daily Vocab", definition: "Word of the day")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let words = loadWordsFromBundle()
        let w = todaysWord(from: words, date: Date())
        completion(SimpleEntry(date: Date(),
                               word: w?.word ?? "Daily Vocab",
                               definition: w?.definition ?? "Add words.json to widget target."))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? now.addingTimeInterval(24*60*60)
        let words = loadWordsFromBundle()
        let w = todaysWord(from: words, date: now)
        let entry = SimpleEntry(date: now,
                                word: w?.word ?? "Daily Vocab",
                                definition: w?.definition ?? "Add words.json to widget target.")
        completion(Timeline(entries: [entry], policy: .after(startOfTomorrow)))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let word: String
    let definition: String
}

struct Daily_Vocab_WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(entry.word)
                .font(DS.FontToken.heading(size: 24, weight: .bold))
                .foregroundStyle(DS.Color.textPrimary)
                .lineLimit(1)
            Text(entry.definition)
                .font(DS.FontToken.body(size: 12))
                .foregroundStyle(DS.Color.textSecondary)
                .lineLimit(3)
        }
        .padding(DS.Space.m)
        .containerBackground(for: .widget) { DS.Color.card }
    }
}

struct Daily_Vocab_Widget: Widget {
    let kind: String = "Daily_Vocab_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Daily_Vocab_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Word")
        .description("Shows the Daily Vocab word and definition.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview("Light", as: .systemSmall, widget: {
    Daily_Vocab_Widget()
}, timeline: {
    SimpleEntry(date: .now, word: "brevity", definition: "concise and exact use of words in writing or speech.")
})
