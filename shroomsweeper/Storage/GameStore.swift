import Foundation

@MainActor
final class GameStore {
    private static let key = "shroom_in_progress_game_v1"

    func load() -> GameSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: Self.key) else { return nil }
        return try? JSONDecoder().decode(GameSnapshot.self, from: data)
    }

    func save(_ snapshot: GameSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Self.key)
    }
}
