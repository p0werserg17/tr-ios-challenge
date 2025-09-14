import Foundation

@MainActor
final class MovieListViewModel: ObservableObject {
    @Published var state: ViewState = .idle
    @Published var movies: [MovieSummary] = []

    // UI state
    @Published var searchText: String = ""
    @Published var sort: SortOption = .titleAZ
    @Published var layout: LayoutMode = .grid
    @Published var showFilters: Bool = false
    @Published var isFetchingRatings: Bool = false

    // Ratings cache for sorting by rating
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
//            print("📦 URLCache: \(diskKB) KB on disk, \(memKB) KB in memory")
        } catch {
        state = error.isOffline
                ? .error("You're offline. Check your connection.")
                : .error("Something went wrong. Please try again.")        }
    }

    // Call when user selects rating sort. Fetches ratings once and caches them.
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
            print("Ratings prefetch error:", error.localizedDescription)
        }
    }

    func isLiked(_ id: MovieID) -> Bool { likes.isLiked(id) }
    func toggleLike(_ id: MovieID) { likes.toggle(id) }

    // MARK: - Derived collection for the view

    var visibleMovies: [MovieSummary] {
        let filtered = filter(movies, by: searchText)
        return sortMovies(filtered, by: sort)
    }

    private func filter(_ list: [MovieSummary], by query: String) -> [MovieSummary] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return list }
        let q = query.lowercased()
        return list.filter { $0.title.lowercased().contains(q) || $0.year.contains(q) }
    }

    private func sortMovies(_ list: [MovieSummary], by option: SortOption) -> [MovieSummary] {
        switch option {
        case .titleAZ:
            return list.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleZA:
            return list.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .yearNewest:
            return list.sorted { ($0.yearInt) > ($1.yearInt) }
        case .yearOldest:
            return list.sorted { ($0.yearInt) < ($1.yearInt) }
        case .ratingHigh:
            return list.sorted {
                let r0 = ratingByID[$0.id] ?? -Double.greatestFiniteMagnitude
                let r1 = ratingByID[$1.id] ?? -Double.greatestFiniteMagnitude
                if r0 == r1 {
                    return $0.title < $1.title
                }
                return r0 > r1
            }
        }
    }
}

// Small helper to convert "2010" -> 2010 cleanly
private extension MovieSummary {
    var yearInt: Int { Int(year) ?? 0 }
}
