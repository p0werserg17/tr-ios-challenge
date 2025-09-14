import XCTest
@testable import MovieBrowser

@MainActor
final class MovieListViewModelTests: XCTestCase {

    private struct MockService: MovieService {
        let list: [MovieSummary]
        let detailsMap: [MovieID: MovieDetails]
        let shouldThrowOffline: Bool

        func fetchList() async throws -> [MovieSummary] {
            if shouldThrowOffline { throw URLError(.notConnectedToInternet) }
            return list
        }
        func fetchDetails(id: MovieID) async throws -> MovieDetails {
            if shouldThrowOffline { throw URLError(.notConnectedToInternet) }
            guard let d = detailsMap[id] else { fatalError("missing details") }
            return d
        }
        func fetchRecommended(id: MovieID) async throws -> [MovieSummary] {
            if shouldThrowOffline { throw URLError(.notConnectedToInternet) }
            return []
        }
    }

    private final class FakeLikes: LikesProviding {
        private var set = Set<MovieID>()
        func isLiked(_ id: MovieID) -> Bool { set.contains(id) }
        func toggle(_ id: MovieID) { if !set.insert(id).inserted { set.remove(id) } }
    }

    func test_load_transitions_to_loaded_when_list_nonempty() async {
        let list = [MovieSummary(id: .init(raw: "1"), title: "Test", year: "2020", poster: nil)]
        let vm = MovieListViewModel(
            service: MockService(list: list, detailsMap: [:], shouldThrowOffline: false),
            likes: FakeLikes()
        )

        await vm.load()

        XCTAssertEqual(vm.state, .loaded)
        XCTAssertEqual(vm.movies.count, 1)
    }

    func test_load_offline_sets_offline_message() async {
        let vm = MovieListViewModel(
            service: MockService(list: [], detailsMap: [:], shouldThrowOffline: true),
            likes: FakeLikes()
        )

        await vm.load()

        if case let .error(msg) = vm.state {
            XCTAssertTrue(msg.contains("offline") || msg.contains("Offline"), "Got: \(msg)")
        } else {
            XCTFail("Expected offline error state")
        }
    }

    func test_filter_and_sort_work_together() async {
        let list = [
            MovieSummary(id: .init(raw: "1"), title: "Zebra", year: "2010", poster: nil),
            MovieSummary(id: .init(raw: "2"), title: "alpha", year: "2014", poster: nil),
            MovieSummary(id: .init(raw: "3"), title: "Beta",  year: "2005", poster: nil),
        ]
        let vm = MovieListViewModel(
            service: MockService(list: list, detailsMap: [:], shouldThrowOffline: false),
            likes: FakeLikes()
        )
        await vm.load()

        vm.searchText = "a"
        vm.sort = .titleAZ

        let titles = vm.visibleMovies.map(\.title)
        XCTAssertEqual(titles, ["alpha", "Beta", "Zebra"])
    }

    func test_ensureRatings_then_sort_by_rating() async {
        let m1 = MovieSummary(id: .init(raw: "1"), title: "A", year: "2010", poster: nil)
        let m2 = MovieSummary(id: .init(raw: "2"), title: "B", year: "2010", poster: nil)

        let d1 = MovieDetails(id: m1.id, title: "A", year: "2010", plot: "p", notes: nil, poster: nil, rating: "7.5")
        let d2 = MovieDetails(id: m2.id, title: "B", year: "2010", plot: "p", notes: nil, poster: nil, rating: "8.1")

        let vm = MovieListViewModel(
            service: MockService(list: [m1, m2], detailsMap: [m1.id: d1, m2.id: d2], shouldThrowOffline: false),
            likes: FakeLikes()
        )
        await vm.load()

        vm.sort = .ratingHigh
        await vm.ensureRatings()

        let titles = vm.visibleMovies.map(\.title)
        XCTAssertEqual(titles, ["B", "A"])
    }
}
