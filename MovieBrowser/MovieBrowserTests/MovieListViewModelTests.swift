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
            likesService: mockLikesService
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
        // Given
        mockNetworkService.shouldThrowError = true
        mockNetworkService.errorToThrow = .noInternetConnection

        // When
        await viewModel.loadMovies()

        // Then
        XCTAssertEqual(viewModel.loadingState, .failed(.noInternetConnection))
        XCTAssertTrue(viewModel.movies.isEmpty)
        XCTAssertTrue(viewModel.canRetry)
    }

    @MainActor
    func testLoadingStateTransitions() async {
        // Given
        mockNetworkService.shouldThrowError = false

        // Initial state
        XCTAssertEqual(viewModel.loadingState, .idle)

        // When loading starts
        let loadingTask = Task {
            await viewModel.loadMovies()
        }

        // Brief delay to check loading state
        try? await Task.sleep(nanoseconds: 1_000_000) // 1ms

        await loadingTask.value

        // Then
        XCTAssertEqual(viewModel.loadingState, .loaded)
    }

    // MARK: - Search Tests
    func testSearchFiltering() {
        // Given
        viewModel.movies = Movie.sampleMovies

        // When searching for "Avengers"
        viewModel.searchText = "Avengers"

        // Then
        let filteredMovies = viewModel.filteredMovies
        XCTAssertEqual(filteredMovies.count, 1)
        XCTAssertEqual(filteredMovies.first?.name, "Avengers: Endgame")
    }

    func testSearchByYear() {
        // Given
        viewModel.movies = Movie.sampleMovies

        // When searching for "2019"
        viewModel.searchText = "2019"

        // Then
        let filteredMovies = viewModel.filteredMovies
        XCTAssertEqual(filteredMovies.count, 1)
        XCTAssertEqual(filteredMovies.first?.year, 2019)
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
        // Given
        let movie = Movie.sampleMovie
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
        XCTAssertEqual(viewModel.loadingState, .failed(.networkError("Mock error")))

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
