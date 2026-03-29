import Foundation

/// Represents a vocabulary word loaded from bundled JSON.
/// Conforms to Codable for easy JSON decoding and Identifiable for SwiftUI lists.
public struct Word: Codable, Identifiable, Equatable, Hashable {
    /// Unique identifier for the word (comes from JSON)
    public let id: String
    public let word: String
    public let definition: String
    public let example: String
}
