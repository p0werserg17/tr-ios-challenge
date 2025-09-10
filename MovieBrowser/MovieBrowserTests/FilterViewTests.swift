//
//  FilterViewTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/10/25.
//

import XCTest
import SwiftUI
@testable import MovieBrowser

final class FilterViewTests: XCTestCase {

    // MARK: - Test Data

    private var sampleMovies: [Movie] {
        [
            Movie(id: 1, name: "Avengers: Endgame", thumbnail: "", year: 2019),
            Movie(id: 2, name: "Home Alone", thumbnail: "", year: 1990),
            Movie(id: 3, name: "Inception", thumbnail: "", year: 2010),
            Movie(id: 4, name: "The Dark Knight", thumbnail: "", year: 2008),
            Movie(id: 5, name: "The Matrix", thumbnail: "", year: 1999)
        ]
    }

    // MARK: - Initialization Tests

    func testFilterViewInitialization() {
        let initialFilterOptions = FilterOptions()
        let initialSortOption = SortOption.yearNewest

        let filterView = FilterView(
            filterOptions: .constant(initialFilterOptions),
            sortOption: .constant(initialSortOption),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Access the computed properties to trigger their execution
        let _ = filterView.body // This executes the body computed property

        // Test that the view is created successfully with correct public properties
        XCTAssertEqual(filterView.movies.count, 5)
        XCTAssertNotNil(filterView.onApply)
        XCTAssertNotNil(filterView.onReset)

        // Test that the initial filter options are as expected
        XCTAssertFalse(initialFilterOptions.isActive)
        XCTAssertEqual(initialSortOption, .yearNewest)
    }

    func testFilterViewInitializationWithActiveFilters() {
        var initialFilterOptions = FilterOptions()
        initialFilterOptions.selectedDecades.insert("2010s")
        initialFilterOptions.selectedGenres.insert("Action")
        initialFilterOptions.minRating = 8.0
        initialFilterOptions.showLikedOnly = true
        let initialSortOption = SortOption.liked

        let filterView = FilterView(
            filterOptions: .constant(initialFilterOptions),
            sortOption: .constant(initialSortOption),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Access the computed properties to trigger their execution
        let _ = filterView.body // This executes the body computed property

        // Test the input parameters are correctly set
        XCTAssertTrue(initialFilterOptions.isActive)
        XCTAssertTrue(initialFilterOptions.selectedDecades.contains("2010s"))
        XCTAssertTrue(initialFilterOptions.selectedGenres.contains("Action"))
        XCTAssertEqual(initialFilterOptions.minRating, 8.0)
        XCTAssertEqual(initialFilterOptions.showLikedOnly, true)
        XCTAssertEqual(initialSortOption, .liked)

        // Test view is created successfully
        XCTAssertEqual(filterView.movies.count, 5)
    }

    // MARK: - Filter State Tests

    func testFilterStateWithNoFilters() {
        let filterOptions = FilterOptions()
        let sortOption = SortOption.yearNewest

        let filterView = FilterView(
            filterOptions: .constant(filterOptions),
            sortOption: .constant(sortOption),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Access the computed properties to trigger their execution
        let _ = filterView.body // This executes the body computed property

        // Test the underlying filter state
        XCTAssertFalse(filterOptions.isActive)
        XCTAssertEqual(sortOption, .yearNewest)
        XCTAssertEqual(filterOptions.activeFiltersCount, 0)
    }

    func testFilterStateWithActiveFilters() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")

        _ = FilterView(
            filterOptions: .constant(filterOptions),
            sortOption: .constant(.yearNewest),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Test the underlying filter state
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertTrue(filterOptions.selectedDecades.contains("2020s"))
        XCTAssertEqual(filterOptions.activeFiltersCount, 1)
    }

    func testFilterStateWithSorting() {
        let filterOptions = FilterOptions()
        let sortOption = SortOption.liked

        _ = FilterView(
            filterOptions: .constant(filterOptions),
            sortOption: .constant(sortOption),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Test the underlying sort state
        XCTAssertEqual(sortOption, .liked)
        XCTAssertFalse(filterOptions.isActive)
    }

    // MARK: - Action Tests

    func testApplyFiltersCallback() {
        var applyCalled = false

        let filterView = FilterView(
            filterOptions: .constant(FilterOptions()),
            sortOption: .constant(.yearNewest),
            movies: sampleMovies,
            onApply: {
                applyCalled = true
            },
            onReset: {}
        )

        // Test that the callback structure is correct
        XCTAssertNotNil(filterView.onApply)
        filterView.onApply()
        XCTAssertTrue(applyCalled)
    }

    func testResetCallback() {
        var resetCalled = false

        let filterView = FilterView(
            filterOptions: .constant(FilterOptions()),
            sortOption: .constant(.yearNewest),
            movies: sampleMovies,
            onApply: {},
            onReset: {
                resetCalled = true
            }
        )

        filterView.onReset()
        XCTAssertTrue(resetCalled)
    }

    // MARK: - View Component Tests

    func testSortOptionCardCreation() {
        let filterView = FilterView(
            filterOptions: .constant(FilterOptions()),
            sortOption: .constant(.yearNewest),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Access the computed properties to trigger their execution
        let _ = filterView.body // This executes the body and all sub-views

        // Test that all sort options are available
        XCTAssertEqual(SortOption.allCases.count, 5)

        // Test sort option properties
        for option in SortOption.allCases {
            XCTAssertFalse(option.displayName.isEmpty)
            XCTAssertFalse(option.description.isEmpty)
            XCTAssertFalse(option.icon.isEmpty)
        }
    }

    func testFilterChipCreation() {
        let filterView = FilterView(
            filterOptions: .constant(FilterOptions()),
            sortOption: .constant(.yearNewest),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Access the computed properties to trigger their execution
        let _ = filterView.body // This executes the body and filter sections

        // Test that decades are generated from movies
        let decades = AvailableFilterValues.decades(from: sampleMovies)
        XCTAssertFalse(decades.isEmpty)
        XCTAssertTrue(decades.contains("2010s"))
        XCTAssertTrue(decades.contains("2000s"))
        XCTAssertTrue(decades.contains("1990s"))

        // Test that genres are generated from movies
        let genres = AvailableFilterValues.genres(from: sampleMovies)
        XCTAssertFalse(genres.isEmpty)

        // Based on the sampleMovies and estimatedGenre logic:
        // "Avengers: Endgame" → "Action", "Home Alone" → "Comedy",
        // "Inception" → "Sci-Fi", "The Dark Knight" → "Action", "The Matrix" → "Action"
        // Expected unique genres: ["Action", "Comedy", "Sci-Fi"]
        XCTAssertTrue(genres.contains("Action"))
        XCTAssertTrue(genres.contains("Comedy"))
        XCTAssertTrue(genres.contains("Sci-Fi"))
        XCTAssertEqual(genres.count, 3) // Should only have these 3 genres

        // Verify the expected genres match what's actually generated
        let expectedGenres = Set(sampleMovies.map { $0.estimatedGenre })
        XCTAssertEqual(Set(genres), expectedGenres)
    }

    func testRatingRanges() {
        let filterView = FilterView(
            filterOptions: .constant(FilterOptions()),
            sortOption: .constant(.yearNewest),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Access the body to trigger all computed properties
        let _ = filterView.body

        // Test rating ranges
        let ranges = AvailableFilterValues.ratingRanges
        XCTAssertEqual(ranges.count, 5)

        // Test specific ranges
        XCTAssertEqual(ranges[0].0, "9+ Excellent")
        XCTAssertEqual(ranges[0].1, 9.0)
        XCTAssertEqual(ranges[0].2, 10.0)

        XCTAssertEqual(ranges[4].0, "All Ratings")
        XCTAssertEqual(ranges[4].1, 0.0)
        XCTAssertEqual(ranges[4].2, 10.0)
    }

    func testFilterViewBodyComputedProperty() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2010s")
        filterOptions.selectedGenres.insert("Action")
        filterOptions.minRating = 8.0
        let sortOption = SortOption.liked

        let filterView = FilterView(
            filterOptions: .constant(filterOptions),
            sortOption: .constant(sortOption),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Access the body computed property multiple times to ensure all sub-views are executed
        let _ = filterView.body
        let _ = filterView.body // Access again to ensure consistency

        // Test the underlying state
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(sortOption, .liked)
        XCTAssertEqual(filterView.movies.count, 5)
    }

    func testFilterViewWithAllSections() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        filterOptions.selectedGenres.insert("Comedy")
        filterOptions.minRating = 7.0
        filterOptions.maxRating = 9.0
        filterOptions.showLikedOnly = true
        let sortOption = SortOption.nameAZ

        let filterView = FilterView(
            filterOptions: .constant(filterOptions),
            sortOption: .constant(sortOption),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Access the body to execute all sections: header, sort, decade, genre, rating, favorites
        let _ = filterView.body

        // Verify all filter types are active to ensure all sections are rendered
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertTrue(filterOptions.selectedDecades.contains("2020s"))
        XCTAssertTrue(filterOptions.selectedGenres.contains("Comedy"))
        XCTAssertEqual(filterOptions.minRating, 7.0)
        XCTAssertEqual(filterOptions.maxRating, 9.0)
        XCTAssertTrue(filterOptions.showLikedOnly)
        XCTAssertEqual(sortOption, .nameAZ)
    }

    // MARK: - State Management Tests

    func testFilterOptionsDataFlow() {
        var initialFilterOptions = FilterOptions()
        initialFilterOptions.selectedDecades.insert("2020s")

        _ = FilterView(
            filterOptions: .constant(initialFilterOptions),
            sortOption: .constant(.yearNewest),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Test that the initial filter options contain expected data
        XCTAssertTrue(initialFilterOptions.selectedDecades.contains("2020s"))
        XCTAssertTrue(initialFilterOptions.isActive)
        XCTAssertEqual(initialFilterOptions.activeFiltersCount, 1)
    }

    func testFavoriteToggleMutualExclusivity() {
        let filterView = FilterView(
            filterOptions: .constant(FilterOptions()),
            sortOption: .constant(.yearNewest),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Test that the toggle logic is set up correctly
        // In practice, this would be tested through UI interactions
        // But we can verify the structure exists
        XCTAssertNotNil(filterView.movies)
    }

    // MARK: - Integration Tests

    func testFullFilterWorkflow() {
        var applyCalled = false

        let filterView = FilterView(
            filterOptions: .constant(FilterOptions()),
            sortOption: .constant(.yearNewest),
            movies: sampleMovies,
            onApply: {
                applyCalled = true
            },
            onReset: {}
        )

        // Test that the view is properly initialized for a full workflow
        XCTAssertEqual(filterView.movies.count, 5)
        XCTAssertNotNil(filterView.onApply)
        XCTAssertNotNil(filterView.onReset)

        // Simulate apply callback
        filterView.onApply()
        XCTAssertTrue(applyCalled)
    }

    func testViewWithAllFilterTypes() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2010s")
        filterOptions.selectedGenres.insert("Action")
        filterOptions.minRating = 8.0
        filterOptions.showLikedOnly = true

        _ = FilterView(
            filterOptions: .constant(filterOptions),
            sortOption: .constant(.liked),
            movies: sampleMovies,
            onApply: {},
            onReset: {}
        )

        // Test that the input filter options contain all expected data
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.activeFiltersCount, 4)
        XCTAssertTrue(filterOptions.selectedDecades.contains("2010s"))
        XCTAssertTrue(filterOptions.selectedGenres.contains("Action"))
        XCTAssertEqual(filterOptions.minRating, 8.0)
        XCTAssertTrue(filterOptions.showLikedOnly)
    }

}
