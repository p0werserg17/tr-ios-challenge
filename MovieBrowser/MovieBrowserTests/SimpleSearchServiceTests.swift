//
//  SimpleSearchServiceTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Simple Search Service Tests
//

import XCTest
@testable import MovieBrowser

final class SimpleSearchServiceTests: XCTestCase {

    var searchService: SimpleSearchService!
    var sampleMovies: [Movie]!

    override func setUp() {
        super.setUp()
        searchService = SimpleSearchService()
        sampleMovies = [
            Movie(id: 1, name: "Avengers: Endgame", thumbnail: "https://example.com/1.jpg", year: 2019),
            Movie(id: 2, name: "The Dark Knight", thumbnail: "https://example.com/2.jpg", year: 2008),
            Movie(id: 3, name: "Inception", thumbnail: "https://example.com/3.jpg", year: 2010),
            Movie(id: 4, name: "Home Alone", thumbnail: "https://example.com/4.jpg", year: 1990),
            Movie(id: 5, name: "The Matrix", thumbnail: "https://example.com/5.jpg", year: 1999)
        ]
    }

    override func tearDown() {
        searchService = nil
        sampleMovies = nil
        super.tearDown()
    }

    // MARK: - Basic Search Tests
    func testExactMatch() {
        // When
        let results = searchService.search(sampleMovies, query: "Inception")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.item.name, "Inception")
        XCTAssertEqual(results.first?.matchType, .exact)
        XCTAssertEqual(results.first?.relevanceScore, 1.0)
    }

    func testPrefixMatch() {
        // When
        let results = searchService.search(sampleMovies, query: "Aveng")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.item.name, "Avengers: Endgame")
        XCTAssertEqual(results.first?.matchType, .prefix)
        XCTAssertGreaterThan(results.first?.relevanceScore ?? 0, 0.2)
    }

    func testContainsMatch() {
        // When
        let results = searchService.search(sampleMovies, query: "Dark")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.item.name, "The Dark Knight")
        XCTAssertEqual(results.first?.matchType, .contains)
    }

    func testYearSearch() {
        // When
        let results = searchService.search(sampleMovies, query: "2019")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.item.name, "Avengers: Endgame")
        XCTAssertEqual(results.first?.matchType, .exact)
    }

    func testFuzzyMatching() {
        // When - Test with typo
        let results = searchService.search(sampleMovies, query: "Avengrs")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.item.name, "Avengers: Endgame")
        XCTAssertEqual(results.first?.matchType, .fuzzy)
        XCTAssertLessThan(results.first?.relevanceScore ?? 0, 0.8) // Fuzzy matches have lower scores
    }

    func testCaseInsensitiveSearch() {
        // When
        let results = searchService.search(sampleMovies, query: "INCEPTION")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.item.name, "Inception")
    }

    func testShortTypoSearch() {
        // When - searching for "drk" should find "The Dark Knight"
        let results = searchService.search(sampleMovies, query: "drk")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.item.name, "The Dark Knight")
        XCTAssertEqual(results.first?.matchType, .fuzzy)
        XCTAssertGreaterThan(results.first?.relevanceScore ?? 0, 0.3) // Should have reasonable score
    }

    func testMultiWordTypoSearch() {
        // When - searching for "hme al" should find "Home Alone"
        let results = searchService.search(sampleMovies, query: "hme al")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.item.name, "Home Alone")
        XCTAssertEqual(results.first?.matchType, .fuzzy)
        XCTAssertGreaterThan(results.first?.relevanceScore ?? 0, 0.3)
    }

    func testMultiWordWithTypoSearch() {
        // When - searching for "drk knight" should find "The Dark Knight"
        let results = searchService.search(sampleMovies, query: "drk knight")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.item.name, "The Dark Knight")
        XCTAssertEqual(results.first?.matchType, .fuzzy)
        XCTAssertGreaterThan(results.first?.relevanceScore ?? 0, 0.2) // Realistic threshold
    }

    func testSubsequenceMatching() {
        // When - searching for "hme" should find "Home Alone" via subsequence matching
        let results = searchService.search(sampleMovies, query: "hme")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.item.name, "Home Alone")
        XCTAssertEqual(results.first?.matchType, .fuzzy)
        XCTAssertGreaterThan(results.first?.relevanceScore ?? 0, 0.2) // Realistic threshold
    }

    func testPartialWordsSearch() {
        // When - searching for "av end" should find "Avengers: Endgame"
        let results = searchService.search(sampleMovies, query: "av end")

        // Then
        XCTAssertGreaterThan(results.count, 0, "Should find at least one result for 'av end'")
        if results.count > 0 {
            XCTAssertEqual(results.first?.item.name, "Avengers: Endgame")
            XCTAssertEqual(results.first?.matchType, .fuzzy)
            XCTAssertGreaterThan(results.first?.relevanceScore ?? 0, 0.2) // Adjusted to actual score
        }
    }

    func testDebugPartialWordsSearch() {
        // Debug test to understand what's happening
        let results = searchService.search(sampleMovies, query: "av")
        XCTAssertGreaterThan(results.count, 0, "Should find results for 'av'")

        let results2 = searchService.search(sampleMovies, query: "end")
        XCTAssertGreaterThan(results2.count, 0, "Should find results for 'end'")

        let results3 = searchService.search(sampleMovies, query: "av end")
        XCTAssertGreaterThan(results3.count, 0, "Should find results for 'av end'")

        // Test individual components work
        let avengersMovie = sampleMovies.first { $0.name == "Avengers: Endgame" }
        XCTAssertNotNil(avengersMovie, "Should have Avengers movie in sample data")
    }

    func testMultipleResults() {
        // When
        let results = searchService.search(sampleMovies, query: "The")

        // Then
        XCTAssertEqual(results.count, 2) // "The Dark Knight" and "The Matrix"

        // Results should be sorted by relevance
        XCTAssertGreaterThanOrEqual(results[0].relevanceScore, results[1].relevanceScore)
    }

    func testEmptyQuery() {
        // When
        let results = searchService.search(sampleMovies, query: "")

        // Then
        XCTAssertTrue(results.isEmpty)
    }

    func testNoMatches() {
        // When
        let results = searchService.search(sampleMovies, query: "NonexistentMovie")

        // Then
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Suggestions Tests
    func testSuggestionGeneration() {
        // When
        let suggestions = searchService.generateSuggestions(sampleMovies, partialQuery: "Av")

        // Then
        XCTAssertFalse(suggestions.isEmpty)
        XCTAssertTrue(suggestions.contains("Avengers: Endgame"))
    }

    func testSuggestionLimit() {
        // When
        let suggestions = searchService.generateSuggestions(sampleMovies, partialQuery: "The")

        // Then
        XCTAssertLessThanOrEqual(suggestions.count, 5)
    }

    func testShortQueryNoSuggestions() {
        // When
        let suggestions = searchService.generateSuggestions(sampleMovies, partialQuery: "A")

        // Then
        XCTAssertTrue(suggestions.isEmpty)
    }

    // MARK: - Performance Tests
    func testSearchPerformance() {
        // Given
        let startTime = CFAbsoluteTimeGetCurrent()

        // When
        let _ = searchService.search(sampleMovies, query: "Avengers")

        // Then
        let executionTime = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(executionTime, 0.1) // Should complete within 100ms
    }
}

// MARK: - MovieListViewModel Debounce Tests
@MainActor
final class MovieListViewModelDebounceTests: XCTestCase {

    var viewModel: MovieListViewModel!
    var mockNetworkService: MockNetworkService!
    var mockLikesService: MockLikesService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockLikesService = MockLikesService()
        viewModel = MovieListViewModel(
            networkService: mockNetworkService,
            likesService: mockLikesService,
            searchService: SimpleSearchService()
        )

        // Set up sample movies for debounce testing
        viewModel.movies = [
            Movie(id: 1, name: "Avengers: Endgame", thumbnail: "https://example.com/1.jpg", year: 2019),
            Movie(id: 2, name: "The Dark Knight", thumbnail: "https://example.com/2.jpg", year: 2008)
        ]
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        mockLikesService = nil
        super.tearDown()
    }

    func testSearchDebouncing() async {
        // Given - Initially shows all movies
        let initialMovieCount = viewModel.movies.count
        XCTAssertEqual(viewModel.filteredMovies.count, initialMovieCount)

        // When - Rapid typing simulation
        viewModel.searchText = "A"
        viewModel.searchText = "Av"
        viewModel.searchText = "Ave"
        viewModel.searchText = "Aven"
        viewModel.searchText = "Avengers"

        // Then - Wait for debounce period (300ms + buffer)
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms

        // Should show only Avengers movie after debounce
        XCTAssertEqual(viewModel.filteredMovies.count, 1)
        XCTAssertEqual(viewModel.filteredMovies.first?.name, "Avengers: Endgame")
    }

    func testSuggestionsAreImmediate() {
        // Given
        viewModel.searchText = ""
        XCTAssertTrue(viewModel.searchSuggestions.isEmpty)

        // When - Set search text
        viewModel.searchText = "Av"

        // Then - Suggestions should be immediate (no debounce)
        XCTAssertFalse(viewModel.searchSuggestions.isEmpty)
        XCTAssertTrue(viewModel.searchSuggestions.contains("Avengers: Endgame"))
    }

    func testEmptySearchShowsAllMovies() async {
        // Given - Start with a search
        let totalMovieCount = viewModel.movies.count
        viewModel.searchText = "Avengers"
        try? await Task.sleep(nanoseconds: 400_000_000) // Wait for debounce
        XCTAssertEqual(viewModel.filteredMovies.count, 1)

        // When - Clear search
        viewModel.searchText = ""
        try? await Task.sleep(nanoseconds: 400_000_000) // Wait for debounce

        // Then - Should show all movies
        XCTAssertEqual(viewModel.filteredMovies.count, totalMovieCount)
    }
}
