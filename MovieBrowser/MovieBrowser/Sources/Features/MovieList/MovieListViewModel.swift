import Foundation
import SwiftUI

@MainActor
final class MovieListViewModel: ObservableObject {
    @Published var state: ViewState = .idle
    @Published var movies: [MovieSummary] = []

    @Published var searchText: String = ""
    @Published var sort: SortOption = .titleAZ
    @Published var layout: LayoutMode = .grid
    @Published var showFilters: Bool = false
    @Published var isFetchingRatings: Bool = false

    private(set) var ratingByID: [MovieID: Double] = [:]

    private let service: MovieService
    private let likes: LikesProviding

    init(service: MovieService, likes: LikesProviding) {
        self.service = service
        self.likes = likes
    }

    func loadIfNeeded() async {
        guard movies.isEmpty else { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let list = try await service.fetchList()
            movies = list
            state = list.isEmpty ? .empty : .loaded
        } catch {
            state = error.isOffline
                ? .error("You're offline. Check your connection.")
                : .error("Something went wrong. Please try again.")
        }
    }

    func refreshRespectingSort() async {
        await load()
        if sort == .ratingHigh { await ensureRatings() }
    }

    func retryAfterError() async {
        await refreshRespectingSort()
    }

    func onFiltersApplied() async {
        if sort == .ratingHigh { await ensureRatings() }
    }

    func toggleLayout() {
        layout = (layout == .grid ? .list : .grid)
    }

    var layoutIconName: String {
        layout == .grid ? "list.bullet" : "square.grid.2x2"
    }

    func ensureRatings() async {
        guard ratingByID.isEmpty else { return }
        isFetchingRatings = true
        defer { isFetchingRatings = false }

        do {
            let ids = movies.map(\.id)
            try await withThrowingTaskGroup(of: (MovieID, Double?).self) { group in
                for id in ids {
                    group.addTask {
                        let details = try await self.service.fetchDetails(id: id)
                        let rating = details.rating.flatMap(Double.init)
                        return (id, rating)
                    }
                }
                for try await (id, rating) in group {
                    if let r = rating { ratingByID[id] = r }
                }
            }
        } catch {
            // non-fatal
        }
    }

    func isLiked(_ id: MovieID) -> Bool { likes.isLiked(id) }
    func toggleLike(_ id: MovieID) { likes.toggle(id) }

    var visibleMovies: [MovieSummary] {
        sortMovies(filter(movies, by: searchText), by: sort)
    }

    private func filter(_ list: [MovieSummary], by query: String) -> [MovieSummary] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return list }
        let q = trimmed.lowercased()
        return list.filter { $0.title.lowercased().contains(q) || $0.year.contains(q) }
    }

    private func sortMovies(_ list: [MovieSummary], by option: SortOption) -> [MovieSummary] {
        switch option {
        case .titleAZ:
            return list.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleZA:
            return list.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .yearNewest:
            return list.sorted { $0.yearInt > $1.yearInt }
        case .yearOldest:
            return list.sorted { $0.yearInt < $1.yearInt }
        case .ratingHigh:
            return list.sorted {
                let r0 = ratingByID[$0.id] ?? -.greatestFiniteMagnitude
                let r1 = ratingByID[$1.id] ?? -.greatestFiniteMagnitude
                return r0 == r1 ? ($0.title < $1.title) : (r0 > r1)
            }
        }
    }
}

private extension MovieSummary {
    var yearInt: Int { Int(year) ?? 0 }
}
