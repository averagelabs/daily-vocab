import Foundation
import SwiftData

/// A persisted record representing a user-saved vocabulary word and its spaced-repetition state.
/// Uses SwiftData's @Model to persist locally (no backend).
@Model
final class SavedWord {
    /// Foreign key to `Word.id` from bundled JSON
    var wordId: String
    /// When the user saved this word
    var savedAt: Date
    /// Leitner box level (1...5). Higher = longer interval.
    var leitnerBox: Int
    /// The next date this word should appear for review
    var nextReviewDate: Date
    /// The last time the user reviewed this word (if any)
    var lastReviewedAt: Date?

    /// Designated initializer with sensible defaults for MVP
    init(wordId: String,
         savedAt: Date = Date(),
         leitnerBox: Int = 1,
         nextReviewDate: Date? = nil,
         lastReviewedAt: Date? = nil) {
        self.wordId = wordId
        self.savedAt = savedAt
        self.leitnerBox = leitnerBox
        // Default to due today (start of day) so it shows up in Review
        let todayStart = Calendar.current.startOfDay(for: Date())
        self.nextReviewDate = nextReviewDate ?? todayStart
        self.lastReviewedAt = lastReviewedAt
    }
}
