import XCTest
import SwiftUI
@testable import MovieBrowser

@MainActor
final class MovieDetailViewModelTests: XCTestCase {

    private struct MockService: MovieService {
        var detailsResult: Result<MovieDetails, Error>
        var recommendedResult: Result<[MovieSummary], Error>

        func fetchList() async throws -> [MovieSummary] {
            fatalError("not used")
        }

        func fetchDetails(id: MovieID) async throws -> MovieDetails {
            try detailsResult.get()
        }

        func fetchRecommended(id: MovieID) async throws -> [MovieSummary] {
            try recommendedResult.get()
        }
    }

    private func makeDetails(
        id: String = "1",
        title: String = "Inception",
        year: String = "2010",
        plot: String = "A very long plot that will exceed the truncation threshold for this view model so we can test expanding and collapsing behavior cleanly. Dream within a dream within a dream.",
        notes: String? = String(repeating: "Some production note. ", count: 10),
        poster: URL? = nil,
        rating: String? = "8.7"
    ) -> MovieDetails {
        MovieDetails(
            id: MovieID(raw: id),
            title: title,
            year: year,
            plot: plot,
            notes: notes,
            poster: poster,
            rating: rating
        )
    }


    private func makeSummaries() -> [MovieSummary] {
        [
            MovieSummary(id: MovieID(raw: "2"), title: "Interstellar", year: "2014", poster: nil),
            MovieSummary(id: MovieID(raw: "3"), title: "Dunkirk", year: "2017", poster: nil)
        ]
    }

    // MARK: - Tests

    func test_load_success_setsDetailsRecommended_andLoaded() async {
        let details = makeDetails()
        let recs = makeSummaries()
        let service = MockService(
            detailsResult: .success(details),
            recommendedResult: .success(recs)
        )
        let likes = LikeStore()
        let vm = MovieDetailViewModel(id: MovieID(raw: "1"), service: service, likes: likes)

        await vm.load()

        XCTAssertEqual(vm.state, .loaded)
        XCTAssertEqual(vm.details?.title, "Inception")
        XCTAssertEqual(vm.recommended.count, 2)
        XCTAssertEqual(vm.ratingText, "8.7")
        XCTAssertEqual(vm.titleText, "Inception")
        XCTAssertEqual(vm.yearText, "2010")
        XCTAssertTrue(vm.needsPlotExpand(), "Fixture plot should exceed threshold")
        XCTAssertTrue(vm.needsNotesExpand(), "Fixture notes should exceed threshold")
    }

    func test_load_offline_mapsToFriendlyError() async {
        let service = MockService(
            detailsResult: .failure(URLError(.notConnectedToInternet)),
            recommendedResult: .failure(URLError(.notConnectedToInternet))
        )
        let likes = LikeStore()
        let vm = MovieDetailViewModel(id: MovieID(raw: "1"), service: service, likes: likes)

        await vm.load()

        if case let .error(message) = vm.state {
            XCTAssertTrue(message.contains("offline") || message.contains("Offline") || message.contains("connection"))
        } else {
            XCTFail("Expected .error state for offline")
        }
    }

    func test_toggleCurrentLike_togglesBasedOnDetailsID() async {
        let details = makeDetails(id: "42", title: "Test Like")
        let service = MockService(
            detailsResult: .success(details),
            recommendedResult: .success([])
        )
        let likes = LikeStore()
        let vm = MovieDetailViewModel(id: MovieID(raw: "42"), service: service, likes: likes)

        await vm.load()


        XCTAssertFalse(vm.isCurrentLiked)


        vm.toggleCurrentLike()
        XCTAssertTrue(vm.isCurrentLiked)

        vm.toggleCurrentLike()
        XCTAssertFalse(vm.isCurrentLiked)
    }

    func test_truncationHelpers_plotAndNotes() async {
        let shortDetails = makeDetails(
            plot: "Short.",
            notes: "Note."
        )
        let service = MockService(
            detailsResult: .success(shortDetails),
            recommendedResult: .success([])
        )
        let likes = LikeStore()
        let vm = MovieDetailViewModel(id: MovieID(raw: "1"), service: service, likes: likes)

        await vm.load()

        XCTAssertFalse(vm.needsPlotExpand())
        XCTAssertEqual(vm.plotText(collapsed: true), vm.plotTextFull)

        XCTAssertFalse(vm.needsNotesExpand())
        XCTAssertEqual(vm.notesText(collapsed: true), shortDetails.notes)

        let longDetails = makeDetails(
            plot: String(repeating: "LongPlot ", count: 30),
            notes: String(repeating: "LongNotes ", count: 30)
        )
        let service2 = MockService(detailsResult: .success(longDetails), recommendedResult: .success([]))
        let vm2 = MovieDetailViewModel(id: MovieID(raw: "1"), service: service2, likes: likes)
        await vm2.load()

        XCTAssertTrue(vm2.needsPlotExpand())
        let collapsedPlot = vm2.plotText(collapsed: true)
        XCTAssertLessThan(collapsedPlot.count, vm2.plotTextFull.count)
        XCTAssertTrue(collapsedPlot.hasSuffix("…"))

        XCTAssertTrue(vm2.needsNotesExpand())
        let collapsedNotes = vm2.notesText(collapsed: true)
        XCTAssertLessThan(collapsedNotes.count, (vm2.notesTextFull ?? "").count)
        XCTAssertTrue(collapsedNotes.hasSuffix("…"))
    }

    func test_updateGradient_changesForLightScheme_whenPosterNil() async {
        let details = makeDetails(poster: nil)
        let service = MockService(detailsResult: .success(details), recommendedResult: .success([]))
        let likes = LikeStore()
        let vm = MovieDetailViewModel(id: MovieID(raw: "1"), service: service, likes: likes)

        await vm.load()
        let initial = vm.gradient

        await vm.updateGradient(for: .light)
        let afterLight = vm.gradient

        XCTAssertEqual(afterLight.count, 2)
        XCTAssertNotEqual(initial, afterLight, "Gradient should adapt to color scheme when no poster is available")
    }
}
