import Foundation
import SwiftData

/// Intervals for the Leitner boxes (in days). Box 1 is index 0
private let leitnerIntervals: [Int] = [1, 2, 4, 7, 15]

/// A thin wrapper around SwiftData's ModelContext to manage SavedWord operations.
/// Keeps logic centralized and easy to unit test.
final class SavedWordStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Save / Unsave

    /// Returns true if the word is already saved.
    func isSaved(wordId: String) -> Bool {
        let descriptor = FetchDescriptor<SavedWord>(predicate: #Predicate { $0.wordId == wordId })
        let count = (try? context.fetchCount(descriptor)) ?? 0
        return count > 0
    }

    /// Saves the word if not present. Starts in box 1 and due now.
    func save(wordId: String) {
        guard !isSaved(wordId: wordId) else { return }
        let saved = SavedWord(wordId: wordId, leitnerBox: 1, nextReviewDate: Calendar.current.startOfDay(for: Date()))
        context.insert(saved)
        try? context.save()
    }

    /// Removes a saved word by id if present.
    func unsave(wordId: String) {
        let descriptor = FetchDescriptor<SavedWord>(predicate: #Predicate { $0.wordId == wordId })
        if let existing = try? context.fetch(descriptor).first {
            context.delete(existing)
            try? context.save()
        }
    }

    // MARK: - Fetch

    /// Returns all saved words ordered by most recently saved first.
    func fetchSavedWords() -> [SavedWord] {
        var descriptor = FetchDescriptor<SavedWord>()
        descriptor.sortBy = [ .init(\.savedAt, order: .reverse) ]
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Returns saved words that are due for review today or earlier, ordered by oldest due date first.
    func fetchDueWords(referenceDate: Date = Date()) -> [SavedWord] {
        let startOfDay = Calendar.current.startOfDay(for: referenceDate)
        var descriptor = FetchDescriptor<SavedWord>(predicate: #Predicate { $0.nextReviewDate <= startOfDay })
        descriptor.sortBy = [ .init(\.nextReviewDate, order: .forward) ]
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Review Updates (Leitner)

    /// Applies a review result to a saved word and schedules the next review date.
    /// - Parameters:
    ///   - wordId: The id of the word being reviewed.
    ///   - knewIt: If true, promote to next box (max 5). If false, reset to box 1.
    func updateAfterReview(wordId: String, knewIt: Bool, referenceDate: Date = Date()) {
        let descriptor = FetchDescriptor<SavedWord>(predicate: #Predicate { $0.wordId == wordId })
        guard let saved = try? context.fetch(descriptor).first else { return }
        let now = referenceDate
        if knewIt {
            // Promote to next box, capped at 5
            saved.leitnerBox = min(saved.leitnerBox + 1, 5)
        } else {
            // Reset to box 1 on failure
            saved.leitnerBox = 1
        }
        let boxIndex = max(saved.leitnerBox - 1, 0)
        let intervalDays = leitnerIntervals[boxIndex]
        if let next = Calendar.current.date(byAdding: .day, value: intervalDays, to: now) {
            saved.nextReviewDate = Calendar.current.startOfDay(for: next)
        } else {
            // Fallback: if calendar fails, at least move to tomorrow (start of day)
            let tomorrow = now.addingTimeInterval(24*60*60)
            saved.nextReviewDate = Calendar.current.startOfDay(for: tomorrow)
        }
        saved.lastReviewedAt = now
        try? context.save()
    }
}
