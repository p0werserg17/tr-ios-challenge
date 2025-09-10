//
//  MovieListViewModelTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Movie List ViewModel Tests
//

import XCTest
@testable import MovieBrowser

// MARK: - Movie List ViewModel Tests
/// Comprehensive tests for the MovieListViewModel class
@MainActor
final class MovieListViewModelTests: XCTestCase {

    // MARK: - Properties
    var viewModel: MovieListViewModel!
    var mockNetworkService: MockNetworkService!
    var mockLikesService: MockLikesService!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockLikesService = MockLikesService()
        viewModel = MovieListViewModel(
            networkService: mockNetworkService,
            likesService: mockLikesService,
            searchService: SimpleSearchService()
        )
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        mockLikesService = nil
        super.tearDown()
    }

    // MARK: - Loading Tests
    @MainActor
    func testLoadMoviesSuccess() async {
        // Given
        let expectedMovies = Movie.sampleMovies
        mockNetworkService.shouldThrowError = false

        // When
        await viewModel.loadMovies()

        // Then
        XCTAssertEqual(viewModel.loadingState, .loaded)
        XCTAssertEqual(viewModel.movies.count, expectedMovies.count)
        XCTAssertEqual(viewModel.movies.first?.name, expectedMovies.first?.name)
    }

    @MainActor
    func testLoadMoviesError() async {
        // Given - Create a fresh viewModel for error testing
        mockNetworkService.shouldThrowError = true
        let errorViewModel = MovieListViewModel(
            networkService: mockNetworkService,
            likesService: mockLikesService,
            searchService: SimpleSearchService()
        )

        // Wait for any initial loading to complete
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        // When
        await errorViewModel.loadMovies()

        // Then
        XCTAssertEqual(errorViewModel.loadingState, .failed(.noInternetConnection))
        XCTAssertTrue(errorViewModel.canRetry)
    }

    @MainActor
    func testLoadingStateTransitions() async {
        // Given - Create a fresh viewModel that hasn't auto-loaded yet
        mockNetworkService.shouldThrowError = false

        // Create a new viewModel without auto-loading by setting movies first
        let freshViewModel = MovieListViewModel(
            networkService: mockNetworkService,
            likesService: mockLikesService,
            searchService: SimpleSearchService()
        )

        // Wait a moment for any auto-loading to complete
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        // Reset state for the test
        await freshViewModel.loadMovies() // This should transition properly

        // Then
        XCTAssertEqual(freshViewModel.loadingState, .loaded)
    }

    // MARK: - Search Tests
    func testSearchFiltering() async {
        // Given
        viewModel.movies = Movie.sampleMovies
        XCTAssertGreaterThan(viewModel.movies.count, 0, "Sample movies should not be empty")

        // When searching for "Avengers"
        viewModel.searchText = "Avengers"

        // Wait for debouncing to complete (300ms + buffer)
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms

        // Then
        let filteredMovies = viewModel.filteredMovies
        XCTAssertGreaterThan(filteredMovies.count, 0, "Should find matching movies")
        XCTAssertTrue(filteredMovies.allSatisfy { $0.name.localizedCaseInsensitiveContains("Avengers") }, "All results should match search term")
    }

    func testSearchByYear() async {
        // Given
        viewModel.movies = Movie.sampleMovies
        XCTAssertGreaterThan(viewModel.movies.count, 0, "Sample movies should not be empty")

        // When searching for "2019"
        viewModel.searchText = "2019"

        // Wait for debouncing to complete (300ms + buffer)
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms

        // Then
        let filteredMovies = viewModel.filteredMovies
        XCTAssertGreaterThan(filteredMovies.count, 0, "Should find movies from 2019")
        // Check if any 2019 movies exist in sample data first
        let has2019Movies = Movie.sampleMovies.contains { $0.year == 2019 }
        if has2019Movies {
            XCTAssertTrue(filteredMovies.allSatisfy { $0.year == 2019 }, "All filtered movies should be from 2019")
        } else {
            XCTFail("Sample movies should contain at least one movie from 2019")
        }
    }

    func testSearchCaseInsensitive() {
        // Given
        viewModel.movies = Movie.sampleMovies

        // When searching with different cases
        viewModel.searchText = "avengers"
        let result1 = viewModel.filteredMovies

        viewModel.searchText = "AVENGERS"
        let result2 = viewModel.filteredMovies

        viewModel.searchText = "Avengers"
        let result3 = viewModel.filteredMovies

        // Then
        XCTAssertEqual(result1.count, result2.count)
        XCTAssertEqual(result2.count, result3.count)
        XCTAssertEqual(result1.first?.name, result2.first?.name)
    }

    func testEmptySearch() {
        // Given
        viewModel.movies = Movie.sampleMovies
        viewModel.searchText = ""

        // When
        let filteredMovies = viewModel.filteredMovies

        // Then
        XCTAssertEqual(filteredMovies.count, viewModel.movies.count)
    }

    func testClearSearch() {
        // Given
        viewModel.searchText = "test"

        // When
        viewModel.clearSearch()

        // Then
        XCTAssertTrue(viewModel.searchText.isEmpty)
    }

    // MARK: - Likes Tests
    func testToggleLike() {
        // Given - Use a movie that's not pre-liked (movie ID 2)
        let movie = Movie(id: 2, name: "Test Movie", thumbnail: "https://example.com/test.jpg", year: 2023)
        viewModel.movies = [movie]

        // Initially not liked
        XCTAssertFalse(viewModel.isMovieLiked(movie))

        // When
        viewModel.toggleLike(for: movie)

        // Then
        XCTAssertTrue(mockLikesService.isMovieLiked(movie.id))
    }

    func testLikedMoviesCount() {
        // Given
        viewModel.movies = Movie.sampleMovies
        mockLikesService.toggleLike(for: 1) // Like first movie
        mockLikesService.toggleLike(for: 2) // Like second movie

        // When
        viewModel.likedMovieIds = mockLikesService.getLikedMovieIds()

        // Then
        XCTAssertEqual(viewModel.likedMoviesCount, 2)
        XCTAssertEqual(viewModel.likedMovies.count, 2)
    }

    // MARK: - Refresh Tests
    @MainActor
    func testRefreshMovies() async {
        // Given
        viewModel.movies = Movie.sampleMovies
        mockNetworkService.shouldThrowError = false

        // When
        await viewModel.refreshMovies()

        // Then
        XCTAssertEqual(viewModel.loadingState, .loaded)
        XCTAssertFalse(viewModel.movies.isEmpty)
    }

    @MainActor
    func testRetryLoading() async {
        // Given
        mockNetworkService.shouldThrowError = true
        await viewModel.loadMovies()
        XCTAssertEqual(viewModel.loadingState, .failed(.noInternetConnection))

        // When
        mockNetworkService.shouldThrowError = false
        await viewModel.retryLoading()

        // Then
        XCTAssertEqual(viewModel.loadingState, .loaded)
    }

    // MARK: - Error Handling Tests
    func testUserFriendlyErrorMessages() {
        // Test different error scenarios
        viewModel.loadingState = .failed(.noInternetConnection)
        XCTAssertNotNil(viewModel.userFriendlyErrorMessage)
        XCTAssertTrue(viewModel.userFriendlyErrorMessage!.contains("internet"))

        viewModel.loadingState = .failed(.serverError(500))
        XCTAssertNotNil(viewModel.userFriendlyErrorMessage)
        XCTAssertTrue(viewModel.userFriendlyErrorMessage!.contains("server"))

        viewModel.loadingState = .failed(.timeout)
        XCTAssertNotNil(viewModel.userFriendlyErrorMessage)
        XCTAssertTrue(viewModel.userFriendlyErrorMessage!.contains("long"))
    }

    // MARK: - Sorting Tests
    func testMoviesSortedByYear() {
        // Given
        viewModel.movies = Movie.sampleMovies

        // When
        let sortedMovies = viewModel.filteredMovies

        // Then - should be sorted by year (newest first)
        for i in 0..<(sortedMovies.count - 1) {
            XCTAssertGreaterThanOrEqual(sortedMovies[i].year, sortedMovies[i + 1].year)
        }
    }

    @MainActor
    func testConvenienceInitializer() {
        // Test the convenience initializer
        let convenienceViewModel = MovieListViewModel()
        XCTAssertNotNil(convenienceViewModel)
        XCTAssertEqual(convenienceViewModel.movies.count, 0)
        XCTAssertEqual(convenienceViewModel.loadingState, .idle)
        XCTAssertEqual(convenienceViewModel.searchText, "")
    }

    @MainActor
    func testLikedMoviesComputed() {
        // Given
        viewModel.movies = Movie.sampleMovies
        // MockLikesService starts with movies 1 and 3 liked, but we need to sync the viewModel
        viewModel.likedMovieIds = mockLikesService.getLikedMovieIds()

        // When
        let likedMovies = viewModel.likedMovies

        // Then
        XCTAssertEqual(likedMovies.count, 2)
        XCTAssertTrue(likedMovies.contains { $0.id == 1 })
        XCTAssertTrue(likedMovies.contains { $0.id == 3 })
    }

}

// MARK: - Loading State Tests
final class LoadingStateTests: XCTestCase {

    func testLoadingStateEquality() {
        XCTAssertEqual(LoadingState.idle, LoadingState.idle)
        XCTAssertEqual(LoadingState.loading, LoadingState.loading)
        XCTAssertEqual(LoadingState.loaded, LoadingState.loaded)
        XCTAssertEqual(LoadingState.failed(.noData), LoadingState.failed(.noData))
        XCTAssertNotEqual(LoadingState.failed(.noData), LoadingState.failed(.timeout))
    }

    func testIsLoadingProperty() {
        XCTAssertFalse(LoadingState.idle.isLoading)
        XCTAssertTrue(LoadingState.loading.isLoading)
        XCTAssertFalse(LoadingState.loaded.isLoading)
        XCTAssertFalse(LoadingState.failed(.noData).isLoading)
    }

    func testErrorProperty() {
        XCTAssertNil(LoadingState.idle.error)
        XCTAssertNil(LoadingState.loading.error)
        XCTAssertNil(LoadingState.loaded.error)
        XCTAssertEqual(LoadingState.failed(.noData).error, .noData)
    }
}
