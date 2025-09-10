//
//  FilterOptionsTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/10/25.
//

import XCTest
@testable import MovieBrowser

final class FilterOptionsTests: XCTestCase {

    // MARK: - SortOption Tests

    func testSortOptionRawValues() {
        XCTAssertEqual(SortOption.yearNewest.rawValue, "year_newest")
        XCTAssertEqual(SortOption.yearOldest.rawValue, "year_oldest")
        XCTAssertEqual(SortOption.nameAZ.rawValue, "name_az")
        XCTAssertEqual(SortOption.nameZA.rawValue, "name_za")
        XCTAssertEqual(SortOption.liked.rawValue, "liked_first")
    }

    func testSortOptionId() {
        XCTAssertEqual(SortOption.yearNewest.id, "year_newest")
        XCTAssertEqual(SortOption.yearOldest.id, "year_oldest")
        XCTAssertEqual(SortOption.nameAZ.id, "name_az")
        XCTAssertEqual(SortOption.nameZA.id, "name_za")
        XCTAssertEqual(SortOption.liked.id, "liked_first")
    }

    func testSortOptionDisplayName() {
        XCTAssertEqual(SortOption.yearNewest.displayName, "Newest First")
        XCTAssertEqual(SortOption.yearOldest.displayName, "Oldest First")
        XCTAssertEqual(SortOption.nameAZ.displayName, "A to Z")
        XCTAssertEqual(SortOption.nameZA.displayName, "Z to A")
        XCTAssertEqual(SortOption.liked.displayName, "Liked First")
    }

    func testSortOptionIcon() {
        XCTAssertEqual(SortOption.yearNewest.icon, "calendar.badge.minus")
        XCTAssertEqual(SortOption.yearOldest.icon, "calendar.badge.plus")
        XCTAssertEqual(SortOption.nameAZ.icon, "textformat.abc")
        XCTAssertEqual(SortOption.nameZA.icon, "textformat.abc")
        XCTAssertEqual(SortOption.liked.icon, "heart.fill")
    }

    func testSortOptionDescription() {
        XCTAssertEqual(SortOption.yearNewest.description, "Most recent movies first")
        XCTAssertEqual(SortOption.yearOldest.description, "Oldest movies first")
        XCTAssertEqual(SortOption.nameAZ.description, "Alphabetical order")
        XCTAssertEqual(SortOption.nameZA.description, "Reverse alphabetical")
        XCTAssertEqual(SortOption.liked.description, "Your favorites at the top")
    }

    func testSortOptionCaseIterable() {
        let allCases = SortOption.allCases
        XCTAssertEqual(allCases.count, 5)
        XCTAssertTrue(allCases.contains(.yearNewest))
        XCTAssertTrue(allCases.contains(.yearOldest))
        XCTAssertTrue(allCases.contains(.nameAZ))
        XCTAssertTrue(allCases.contains(.nameZA))
        XCTAssertTrue(allCases.contains(.liked))
    }

    // MARK: - FilterOptions Tests

    func testFilterOptionsInitialization() {
        let filterOptions = FilterOptions()

        XCTAssertTrue(filterOptions.selectedDecades.isEmpty)
        XCTAssertTrue(filterOptions.selectedGenres.isEmpty)
        XCTAssertEqual(filterOptions.minRating, 0.0)
        XCTAssertEqual(filterOptions.maxRating, 10.0)
        XCTAssertFalse(filterOptions.showLikedOnly)
        XCTAssertFalse(filterOptions.showUnlikedOnly)
    }

    func testFilterOptionsIsActiveWhenEmpty() {
        let filterOptions = FilterOptions()
        XCTAssertFalse(filterOptions.isActive)
    }

    func testFilterOptionsIsActiveWithDecades() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        XCTAssertTrue(filterOptions.isActive)
    }

    func testFilterOptionsIsActiveWithGenres() {
        var filterOptions = FilterOptions()
        filterOptions.selectedGenres.insert("Action")
        XCTAssertTrue(filterOptions.isActive)
    }

    func testFilterOptionsIsActiveWithMinRating() {
        var filterOptions = FilterOptions()
        filterOptions.minRating = 7.0
        XCTAssertTrue(filterOptions.isActive)
    }

    func testFilterOptionsIsActiveWithMaxRating() {
        var filterOptions = FilterOptions()
        filterOptions.maxRating = 8.0
        XCTAssertTrue(filterOptions.isActive)
    }

    func testFilterOptionsIsActiveWithShowLikedOnly() {
        var filterOptions = FilterOptions()
        filterOptions.showLikedOnly = true
        XCTAssertTrue(filterOptions.isActive)
    }

    func testFilterOptionsIsActiveWithShowUnlikedOnly() {
        var filterOptions = FilterOptions()
        filterOptions.showUnlikedOnly = true
        XCTAssertTrue(filterOptions.isActive)
    }

    func testFilterOptionsActiveFiltersCountEmpty() {
        let filterOptions = FilterOptions()
        XCTAssertEqual(filterOptions.activeFiltersCount, 0)
    }

    func testFilterOptionsActiveFiltersCountWithDecades() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        XCTAssertEqual(filterOptions.activeFiltersCount, 1)
    }

    func testFilterOptionsActiveFiltersCountWithGenres() {
        var filterOptions = FilterOptions()
        filterOptions.selectedGenres.insert("Action")
        XCTAssertEqual(filterOptions.activeFiltersCount, 1)
    }

    func testFilterOptionsActiveFiltersCountWithRating() {
        var filterOptions = FilterOptions()
        filterOptions.minRating = 7.0
        XCTAssertEqual(filterOptions.activeFiltersCount, 1)

        filterOptions.maxRating = 8.0
        XCTAssertEqual(filterOptions.activeFiltersCount, 1) // Still counts as one rating filter
    }

    func testFilterOptionsActiveFiltersCountWithLikedOnly() {
        var filterOptions = FilterOptions()
        filterOptions.showLikedOnly = true
        XCTAssertEqual(filterOptions.activeFiltersCount, 1)
    }

    func testFilterOptionsActiveFiltersCountWithUnlikedOnly() {
        var filterOptions = FilterOptions()
        filterOptions.showUnlikedOnly = true
        XCTAssertEqual(filterOptions.activeFiltersCount, 1)
    }

    func testFilterOptionsActiveFiltersCountMultiple() {
        var filterOptions = FilterOptions()
        filterOptions.selectedDecades.insert("2020s")
        filterOptions.selectedGenres.insert("Action")
        filterOptions.minRating = 7.0
        filterOptions.showLikedOnly = true
        XCTAssertEqual(filterOptions.activeFiltersCount, 4)
    }

    func testFilterOptionsReset() {
        var filterOptions = FilterOptions()

        // Set all properties
        filterOptions.selectedDecades.insert("2020s")
        filterOptions.selectedGenres.insert("Action")
        filterOptions.minRating = 7.0
        filterOptions.maxRating = 8.0
        filterOptions.showLikedOnly = true
        filterOptions.showUnlikedOnly = false

        // Verify they're set
        XCTAssertTrue(filterOptions.isActive)
        XCTAssertEqual(filterOptions.activeFiltersCount, 4)

        // Reset
        filterOptions.reset()

        // Verify reset
        XCTAssertTrue(filterOptions.selectedDecades.isEmpty)
        XCTAssertTrue(filterOptions.selectedGenres.isEmpty)
        XCTAssertEqual(filterOptions.minRating, 0.0)
        XCTAssertEqual(filterOptions.maxRating, 10.0)
        XCTAssertFalse(filterOptions.showLikedOnly)
        XCTAssertFalse(filterOptions.showUnlikedOnly)
        XCTAssertFalse(filterOptions.isActive)
        XCTAssertEqual(filterOptions.activeFiltersCount, 0)
    }

    func testFilterOptionsEquality() {
        let filterOptions1 = FilterOptions()
        let filterOptions2 = FilterOptions()
        XCTAssertEqual(filterOptions1, filterOptions2)

        var filterOptions3 = FilterOptions()
        filterOptions3.selectedDecades.insert("2020s")
        XCTAssertNotEqual(filterOptions1, filterOptions3)

        var filterOptions4 = FilterOptions()
        filterOptions4.selectedDecades.insert("2020s")
        XCTAssertEqual(filterOptions3, filterOptions4)
    }

    // MARK: - FilterCategory Tests

    func testFilterCategoryRawValues() {
        XCTAssertEqual(FilterCategory.decade.rawValue, "decade")
        XCTAssertEqual(FilterCategory.genre.rawValue, "genre")
        XCTAssertEqual(FilterCategory.rating.rawValue, "rating")
        XCTAssertEqual(FilterCategory.liked.rawValue, "liked")
    }

    func testFilterCategoryDisplayName() {
        XCTAssertEqual(FilterCategory.decade.displayName, "Decade")
        XCTAssertEqual(FilterCategory.genre.displayName, "Genre")
        XCTAssertEqual(FilterCategory.rating.displayName, "Rating")
        XCTAssertEqual(FilterCategory.liked.displayName, "Favorites")
    }

    func testFilterCategoryIcon() {
        XCTAssertEqual(FilterCategory.decade.icon, "calendar")
        XCTAssertEqual(FilterCategory.genre.icon, "theatermasks")
        XCTAssertEqual(FilterCategory.rating.icon, "star")
        XCTAssertEqual(FilterCategory.liked.icon, "heart")
    }

    func testFilterCategoryCaseIterable() {
        let allCases = FilterCategory.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.decade))
        XCTAssertTrue(allCases.contains(.genre))
        XCTAssertTrue(allCases.contains(.rating))
        XCTAssertTrue(allCases.contains(.liked))
    }

    // MARK: - Movie Extension Tests

    func testMovieDecade() {
        let movie2020 = Movie(id: 1, name: "Test Movie", thumbnail: "", year: 2023)
        XCTAssertEqual(movie2020.decade, "2020s")

        let movie2010 = Movie(id: 2, name: "Test Movie", thumbnail: "", year: 2015)
        XCTAssertEqual(movie2010.decade, "2010s")

        let movie2000 = Movie(id: 3, name: "Test Movie", thumbnail: "", year: 2009)
        XCTAssertEqual(movie2000.decade, "2000s")

        let movie1990 = Movie(id: 4, name: "Test Movie", thumbnail: "", year: 1995)
        XCTAssertEqual(movie1990.decade, "1990s")
    }

    func testMovieEstimatedGenreAction() {
        let avengers = Movie(id: 1, name: "Avengers: Endgame", thumbnail: "", year: 2019)
        XCTAssertEqual(avengers.estimatedGenre, "Action")

        let darkKnight = Movie(id: 2, name: "The Dark Knight", thumbnail: "", year: 2008)
        XCTAssertEqual(darkKnight.estimatedGenre, "Action")

        let matrix = Movie(id: 3, name: "The Matrix", thumbnail: "", year: 1999)
        XCTAssertEqual(matrix.estimatedGenre, "Action")
    }

    func testMovieEstimatedGenreSciFi() {
        let inception = Movie(id: 1, name: "Inception", thumbnail: "", year: 2010)
        XCTAssertEqual(inception.estimatedGenre, "Sci-Fi")
    }

    func testMovieEstimatedGenreComedy() {
        let homeAlone = Movie(id: 1, name: "Home Alone", thumbnail: "", year: 1990)
        XCTAssertEqual(homeAlone.estimatedGenre, "Comedy")
    }

    func testMovieEstimatedGenreDrama() {
        let unknownMovie = Movie(id: 1, name: "Unknown Movie", thumbnail: "", year: 2020)
        XCTAssertEqual(unknownMovie.estimatedGenre, "Drama")
    }

    func testMovieEstimatedRatingKnownMovies() {
        let avengers = Movie(id: 1, name: "Avengers: Endgame", thumbnail: "", year: 2019)
        XCTAssertEqual(avengers.estimatedRating, 8.4)

        let homeAlone = Movie(id: 2, name: "Home Alone", thumbnail: "", year: 1990)
        XCTAssertEqual(homeAlone.estimatedRating, 7.7)

        let inception = Movie(id: 3, name: "Inception", thumbnail: "", year: 2010)
        XCTAssertEqual(inception.estimatedRating, 8.8)

        let darkKnight = Movie(id: 4, name: "The Dark Knight", thumbnail: "", year: 2008)
        XCTAssertEqual(darkKnight.estimatedRating, 9.0)

        let matrix = Movie(id: 5, name: "The Matrix", thumbnail: "", year: 1999)
        XCTAssertEqual(matrix.estimatedRating, 8.7)
    }

    func testMovieEstimatedRatingUnknownMovie() {
        let unknownMovie = Movie(id: 999, name: "Unknown Movie", thumbnail: "", year: 2020)
        let rating = unknownMovie.estimatedRating
        XCTAssertGreaterThanOrEqual(rating, 6.0)
        XCTAssertLessThanOrEqual(rating, 9.5)
    }

    // MARK: - AvailableFilterValues Tests

    func testAvailableFilterValuesDecades() {
        let movies = [
            Movie(id: 1, name: "Movie 1", thumbnail: "", year: 2023),
            Movie(id: 2, name: "Movie 2", thumbnail: "", year: 2015),
            Movie(id: 3, name: "Movie 3", thumbnail: "", year: 2009),
            Movie(id: 4, name: "Movie 4", thumbnail: "", year: 2021)
        ]

        let decades = AvailableFilterValues.decades(from: movies)
        XCTAssertEqual(decades, ["2020s", "2010s", "2000s"]) // Newest first
    }

    func testAvailableFilterValuesGenres() {
        let movies = [
            Movie(id: 1, name: "Avengers: Endgame", thumbnail: "", year: 2019),
            Movie(id: 2, name: "Home Alone", thumbnail: "", year: 1990),
            Movie(id: 3, name: "Inception", thumbnail: "", year: 2010),
            Movie(id: 4, name: "Unknown Movie", thumbnail: "", year: 2020)
        ]

        let genres = AvailableFilterValues.genres(from: movies)
        XCTAssertEqual(Set(genres), Set(["Action", "Comedy", "Sci-Fi", "Drama"]))
        XCTAssertEqual(genres, genres.sorted()) // Should be sorted
    }

    func testAvailableFilterValuesRatingRanges() {
        let ranges = AvailableFilterValues.ratingRanges
        XCTAssertEqual(ranges.count, 5)

        XCTAssertEqual(ranges[0].0, "9+ Excellent")
        XCTAssertEqual(ranges[0].1, 9.0)
        XCTAssertEqual(ranges[0].2, 10.0)

        XCTAssertEqual(ranges[1].0, "8+ Great")
        XCTAssertEqual(ranges[1].1, 8.0)
        XCTAssertEqual(ranges[1].2, 10.0)

        XCTAssertEqual(ranges[2].0, "7+ Good")
        XCTAssertEqual(ranges[2].1, 7.0)
        XCTAssertEqual(ranges[2].2, 10.0)

        XCTAssertEqual(ranges[3].0, "6+ Fair")
        XCTAssertEqual(ranges[3].1, 6.0)
        XCTAssertEqual(ranges[3].2, 10.0)

        XCTAssertEqual(ranges[4].0, "All Ratings")
        XCTAssertEqual(ranges[4].1, 0.0)
        XCTAssertEqual(ranges[4].2, 10.0)
    }
}
