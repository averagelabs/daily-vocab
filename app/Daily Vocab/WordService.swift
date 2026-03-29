import Foundation

/// A lightweight service that loads words from a bundled JSON file and caches them in memory.
/// - words.json must be included in the app target. The JSON is expected to be an array of objects matching `Word`.
/// - This service is intentionally simple and synchronous for MVP purposes.
final class WordService {
    static let shared = WordService()

    /// Cached words after first load.
    private(set) var words: [Word] = []

    private init() {}

    /// Loads and caches words from words.json in the main bundle. Subsequent calls return the cached array.
    /// - Throws: An error if the file is missing or decoding fails.
    @discardableResult
    func loadWords() throws -> [Word] {
        if !words.isEmpty { return words }
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json") else {
            throw NSError(domain: "WordService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing words.json in bundle"]) }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([Word].self, from: data)
        self.words = decoded
        return decoded
    }

    /// Returns a deterministic "today's word" index based on the day count since the Unix epoch.
    /// If the list is empty, returns nil.
    func todaysWord() -> Word? {
        do { _ = try loadWords() } catch { return nil }
        guard !words.isEmpty else { return nil }
        let secondsPerDay: TimeInterval = 24 * 60 * 60
        let daysSince1970 = Int(Date().timeIntervalSince1970 / secondsPerDay)
        let index = daysSince1970 % words.count
        return words[index]
    }
}
