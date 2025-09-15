import Foundation

// Abstraction for like/favorite behavior to keep ViewModels testable and decoupled.
protocol LikesProviding {
    func isLiked(_ id: MovieID) -> Bool
    func toggle(_ id: MovieID)
}
