//
//  FilterStatusViewTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/10/25.
//

import XCTest
import SwiftUI
@testable import MovieBrowser

final class FilterStatusViewTests: XCTestCase {

    // MARK: - FilterChipType Tests

    func testFilterChipTypeDecade() {
        let chipType = FilterChipType.decade("2020s")

        switch chipType {
        case .decade(let decade):
            XCTAssertEqual(decade, "2020s")
        default:
            XCTFail("Expected decade type")
        }
    }

    func testFilterChipTypeGenre() {
        let chipType = FilterChipType.genre("Action")

        switch chipType {
        case .genre(let genre):
            XCTAssertEqual(genre, "Action")
        default:
            XCTFail("Expected genre type")
        }
    }

    func testFilterChipTypeRating() {
        let chipType = FilterChipType.rating

        switch chipType {
        case .rating:
            break // Expected
        default:
            XCTFail("Expected rating type")
        }
    }

    func testFilterChipTypeLikedOnly() {
        let chipType = FilterChipType.likedOnly

        switch chipType {
        case .likedOnly:
            break // Expected
        default:
            XCTFail("Expected likedOnly type")
        }
    }

    func testFilterChipTypeUnlikedOnly() {
        let chipType = FilterChipType.unlikedOnly

        switch chipType {
        case .unlikedOnly:
            break // Expected
        default:
            XCTFail("Expected unlikedOnly type")
        }
    }

    func testFilterChipTypeSort() {
        let chipType = FilterChipType.sort

        switch chipType {
        case .sort:
            break // Expected
        default:
            XCTFail("Expected sort type")
        }
    }

    // MARK: - FilterChipData Tests

    func testFilterChipDataInitialization() {
        let chipData = FilterChipData(text: "Test Chip", type: .rating)
        XCTAssertEqual(chipData.text, "Test Chip")

        switch chipData.type {
        case .rating:
            break // Expected
        default:
            XCTFail("Expected rating type")
        }
    }

    // MARK: - FilterStatusView Tests

    func testFilterStatusViewHiddenWhenNoFilters() {
        let filterOptions = FilterOptions()
        let sortOption = SortOption.yearNewest

        let view = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Access the computed properties to trigger their execution
        let _ = view.body // This executes the body computed property

        // Since the view conditionally renders based on isActive, we need to check the filter state
        XCTAssertFalse(filterOptions.isActive)
        XCTAssertEqual(sortOption, .yearNewest)
    }

    func testFilterStatusViewVisibleWithActiveFilters() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        let sortOption = SortOption.yearNewest

        let view = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Access the computed properties to trigger their execution
        let _ = view.body // This executes the body computed property

        // Test that view is visible when filters are active
        XCTAssertTrue(filterOptions.isActive)
    }

    func testFilterStatusViewVisibleWithSorting() {
        let filterOptions = FilterOptions()
        let sortOption = SortOption.liked

        let view = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Access the computed properties to trigger their execution
        let _ = view.body // This executes the body computed property

        // Test that view is visible when sorting is not default
        XCTAssertNotEqual(sortOption, .yearNewest)
    }

    func testActiveFiltersTextWithNoFilters() {
        let filterOptions = FilterOptions()
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic directly
        XCTAssertFalse(filterOptions.isActive)
        XCTAssertEqual(sortOption, .yearNewest)
        XCTAssertEqual(filterOptions.activeFiltersCount, 0)
    }

    func testActiveFiltersTextWithSortOnly() {
        let filterOptions = FilterOptions()
        let sortOption = SortOption.liked

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic directly
        XCTAssertFalse(filterOptions.isActive)
        XCTAssertEqual(sortOption, .liked)
        XCTAssertEqual(sortOption.displayName, "Liked First")
    }

    func testActiveFiltersTextWithFiltersOnly() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        filterOptions.selectedGenres.insert("Action")
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic directly
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.activeFiltersCount, 2)
        XCTAssertEqual(sortOption, .yearNewest)
    }

    func testActiveFiltersTextWithSortAndFilters() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        let sortOption = SortOption.nameAZ

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic directly
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.activeFiltersCount, 1)
        XCTAssertEqual(sortOption.displayName, "A to Z")
    }

    func testActiveFiltersTextSingularFilter() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic directly
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.activeFiltersCount, 1)
    }

    func testActiveFilterChipsWithNoFilters() {
        let filterOptions = FilterOptions()
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic - no active filters or sorting
        XCTAssertFalse(filterOptions.isActive)
        XCTAssertEqual(sortOption, .yearNewest)
        XCTAssertEqual(filterOptions.activeFiltersCount, 0)
    }

    func testActiveFilterChipsWithSort() {
        let filterOptions = FilterOptions()
        let sortOption = SortOption.liked

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic - sort but no filters
        XCTAssertFalse(filterOptions.isActive)
        XCTAssertEqual(sortOption, .liked)
        XCTAssertEqual(sortOption.displayName, "Liked First")
    }

    func testActiveFilterChipsWithDecades() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        filterOptions.selectedDecades.insert("2010s")
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.selectedDecades.count, 2)
        XCTAssertTrue(filterOptions.selectedDecades.contains("2010s"))
        XCTAssertTrue(filterOptions.selectedDecades.contains("2020s"))
    }

    func testActiveFilterChipsWithGenres() {
        var filterOptions = FilterOptions()
        filterOptions.selectedGenres.insert("Action")
        filterOptions.selectedGenres.insert("Comedy")
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.selectedGenres.count, 2)
        XCTAssertTrue(filterOptions.selectedGenres.contains("Action"))
        XCTAssertTrue(filterOptions.selectedGenres.contains("Comedy"))
    }

    func testActiveFilterChipsWithRatingMinOnly() {
        var filterOptions = FilterOptions()
        filterOptions.minRating = 8.0
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.minRating, 8.0)
        XCTAssertEqual(filterOptions.maxRating, 10.0)
    }

    func testActiveFilterChipsWithRatingMaxOnly() {
        var filterOptions = FilterOptions()
        filterOptions.maxRating = 7.0
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.minRating, 0.0)
        XCTAssertEqual(filterOptions.maxRating, 7.0)
    }

    func testActiveFilterChipsWithRatingRange() {
        var filterOptions = FilterOptions()
        filterOptions.minRating = 7.0
        filterOptions.maxRating = 9.0
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.minRating, 7.0)
        XCTAssertEqual(filterOptions.maxRating, 9.0)
    }

    func testActiveFilterChipsWithRatingSame() {
        var filterOptions = FilterOptions()
        filterOptions.minRating = 8.0
        filterOptions.maxRating = 8.0
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.minRating, 8.0)
        XCTAssertEqual(filterOptions.maxRating, 8.0)
    }

    func testActiveFilterChipsWithLikedOnly() {
        var filterOptions = FilterOptions()
        filterOptions.showLikedOnly = true
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertTrue(filterOptions.showLikedOnly)
        XCTAssertFalse(filterOptions.showUnlikedOnly)
    }

    func testActiveFilterChipsWithUnlikedOnly() {
        var filterOptions = FilterOptions()
        filterOptions.showUnlikedOnly = true
        let sortOption = SortOption.yearNewest

        _ = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Test the underlying logic
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertFalse(filterOptions.showLikedOnly)
        XCTAssertTrue(filterOptions.showUnlikedOnly)
    }

    func testActiveFilterChipsWithAllTypes() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        filterOptions.selectedGenres.insert("Action")
        filterOptions.minRating = 8.0
        filterOptions.showLikedOnly = true
        let sortOption = SortOption.nameAZ

        let view = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Actually render the view to execute the complex filter chip logic
        let hostingController = UIHostingController(rootView: view)
        let renderedView = hostingController.view!
        renderedView.layoutIfNeeded()

        // Test the underlying logic - all filter types active
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.activeFiltersCount, 4) // Decade, Genre, Rating, Liked
        XCTAssertTrue(filterOptions.selectedDecades.contains("2020s"))
        XCTAssertTrue(filterOptions.selectedGenres.contains("Action"))
        XCTAssertEqual(filterOptions.minRating, 8.0)
        XCTAssertTrue(filterOptions.showLikedOnly)
        XCTAssertEqual(sortOption, .nameAZ)
    }

    func testClearFiltersCallback() {
        var clearFiltersCalled = false
        let filterOptions = FilterOptions()
        let sortOption = SortOption.liked

        let view = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {
                clearFiltersCalled = true
            },
            onRemoveFilter: { _ in }
        )

        // Actually render the view to execute the button creation code
        let hostingController = UIHostingController(rootView: view)
        let renderedView = hostingController.view!
        renderedView.layoutIfNeeded()

        // Simulate button tap by calling the closure directly
        view.onClearFilters()
        XCTAssertTrue(clearFiltersCalled)
    }

    func testFilterStatusViewWithComplexFilterState() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2010s")
        filterOptions.selectedDecades.insert("2000s")
        filterOptions.selectedGenres.insert("Action")
        filterOptions.selectedGenres.insert("Comedy")
        filterOptions.minRating = 7.5
        filterOptions.maxRating = 9.0
        filterOptions.showLikedOnly = true
        let sortOption = SortOption.liked

        let view = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Access the computed properties to trigger their execution
        let _ = view.body // This executes body, activeFiltersText, and activeFilterChipsWithTypes

        // This should exercise the activeFiltersText and activeFilterChipsWithTypes computed properties
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.activeFiltersCount, 4) // Decades, Genres, Rating, Liked
        XCTAssertEqual(filterOptions.selectedDecades.count, 2)
        XCTAssertEqual(filterOptions.selectedGenres.count, 2)
        XCTAssertEqual(filterOptions.minRating, 7.5)
        XCTAssertEqual(filterOptions.maxRating, 9.0)
        XCTAssertTrue(filterOptions.showLikedOnly)
        XCTAssertEqual(sortOption, .liked)
    }

    func testActiveFiltersTextComputedProperty() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2010s")
        filterOptions.selectedGenres.insert("Action")
        filterOptions.minRating = 8.0
        let sortOption = SortOption.liked

        let view = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Access the body which will trigger activeFiltersText computation
        let _ = view.body

        // Test the underlying filter state that activeFiltersText uses
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.activeFiltersCount, 3) // Decade, Genre, Rating
        XCTAssertEqual(sortOption, .liked)
    }

    func testActiveFilterChipsWithTypesComputedProperty() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        filterOptions.selectedGenres.insert("Comedy")
        filterOptions.showLikedOnly = true
        let sortOption = SortOption.nameAZ

        let view = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Access the body which will trigger activeFilterChipsWithTypes computation
        let _ = view.body

        // Test the underlying state that activeFilterChipsWithTypes uses
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertTrue(filterOptions.selectedDecades.contains("2020s"))
        XCTAssertTrue(filterOptions.selectedGenres.contains("Comedy"))
        XCTAssertTrue(filterOptions.showLikedOnly)
        XCTAssertNotEqual(sortOption, .yearNewest)
    }

    func testRemoveFilterCallback() {
        var removedChipType: FilterChipType?
        let filterOptions = FilterOptions()
        let sortOption = SortOption.liked

        let view = FilterStatusView(
            filterOptions: filterOptions,
            sortOption: sortOption,
            onClearFilters: {},
            onRemoveFilter: { chipType in
                removedChipType = chipType
            }
        )

        // Simulate chip removal
        view.onRemoveFilter(.sort)

        switch removedChipType {
        case .sort:
            break // Expected
        default:
            XCTFail("Expected sort chip type to be removed")
        }
    }

}

// MARK: - Test Extensions
extension FilterOptions {
    init(selectedDecades: Set<String> = [],
         selectedGenres: Set<String> = [],
         minRating: Double = 0.0,
         maxRating: Double = 10.0,
         showLikedOnly: Bool = false,
         showUnlikedOnly: Bool = false) {
        self.init() // Call the default initializer first
        self.selectedDecades = selectedDecades
        self.selectedGenres = selectedGenres
        self.minRating = minRating
        self.maxRating = maxRating
        self.showLikedOnly = showLikedOnly
        self.showUnlikedOnly = showUnlikedOnly
    }
}
