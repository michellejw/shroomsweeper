import Foundation

struct ScoreEntry: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    let initials: String
    let seconds: Int
    let date: Date
}

@Observable
final class ScoreStore {
    private let key = "shroom_scores_v1"
    private let maxPerDifficulty = 5

    private(set) var scores: [Difficulty: [ScoreEntry]] = Difficulty.allCases.reduce(into: [:]) { $0[$1] = [] }

    init() {
        load()
    }

    func best(for difficulty: Difficulty) -> [ScoreEntry] {
        scores[difficulty] ?? []
    }

    /// Returns true if the given time would land in the top N for that difficulty.
    func qualifies(seconds: Int, for difficulty: Difficulty) -> Bool {
        let list = best(for: difficulty)
        if list.count < maxPerDifficulty { return true }
        return seconds < list.last!.seconds
    }

    /// Saves a score and returns the saved entry (sorted, trimmed).
    @discardableResult
    func save(initials: String, seconds: Int, for difficulty: Difficulty) -> ScoreEntry {
        let cleaned = sanitize(initials)
        let entry = ScoreEntry(initials: cleaned, seconds: seconds, date: Date())
        var list = best(for: difficulty)
        list.append(entry)
        list.sort { $0.seconds < $1.seconds }
        if list.count > maxPerDifficulty {
            list = Array(list.prefix(maxPerDifficulty))
        }
        scores[difficulty] = list
        persist()
        return entry
    }

    private func sanitize(_ raw: String) -> String {
        let upper = raw.uppercased().unicodeScalars.filter { CharacterSet.uppercaseLetters.contains($0) }
        let str = String(String.UnicodeScalarView(upper))
        if str.isEmpty { return "YOU" }
        return String(str.prefix(3))
    }

    // MARK: - Persistence

    private struct Stored: Codable {
        var forager: [ScoreEntry] = []
        var woodlander: [ScoreEntry] = []
        var mycologist: [ScoreEntry] = []
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        guard let stored = try? JSONDecoder().decode(Stored.self, from: data) else { return }
        scores[.forager] = stored.forager
        scores[.woodlander] = stored.woodlander
        scores[.mycologist] = stored.mycologist
    }

    private func persist() {
        let stored = Stored(
            forager: scores[.forager] ?? [],
            woodlander: scores[.woodlander] ?? [],
            mycologist: scores[.mycologist] ?? []
        )
        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
