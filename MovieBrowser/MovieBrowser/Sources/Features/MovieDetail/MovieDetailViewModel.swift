import Foundation

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published var state: ViewState = .idle
    @Published var details: MovieDetails?
    @Published var recommended: [MovieSummary] = []

    private let service: MovieService
    private let likes: LikeStore
    private let id: MovieID

    init(id: MovieID, service: MovieService, likes: LikeStore) {
        self.id = id
        self.service = service
        self.likes = likes
    }

    func load() async {
        state = .loading
        do {
            async let d = service.fetchDetails(id: id)
            async let recs = service.fetchRecommended(id: id)
            let (details, recommended) = try await (d, recs)
            self.details = details
            self.recommended = recommended
            state = .loaded
        } catch {
            state = error.isOffline
            ? .error("You're offline. Check your connection.")
            : .error("Something went wrong. Please try again.")        }
    }

    func isLiked(_ id: MovieID) -> Bool { likes.isLiked(id) }
    func toggleLike(_ id: MovieID) { likes.toggle(id) }
}
