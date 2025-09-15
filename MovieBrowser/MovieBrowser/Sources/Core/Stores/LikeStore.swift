import Foundation

final class LikeStore: ObservableObject {
    @Published private(set) var liked: Set<MovieID> = []
    private let key = "liked_movies"

    init() { load() }

    func toggle(_ id: MovieID) {
        if liked.contains(id) { liked.remove(id) } else { liked.insert(id) }
        save()
    }

    func isLiked(_ id: MovieID) -> Bool { liked.contains(id) }

    // MARK: - Persistence
    private func save() {
        let ids = liked.map { $0.raw }
        UserDefaults.standard.set(ids, forKey: key)
    }

    private func load() {
        let ids = (UserDefaults.standard.array(forKey: key) as? [String]) ?? []
        liked = Set(ids.map(MovieID.init(raw:)))
    }
}

// MARK: - Protocol conformance for DI
extension LikeStore: LikesProviding {}
