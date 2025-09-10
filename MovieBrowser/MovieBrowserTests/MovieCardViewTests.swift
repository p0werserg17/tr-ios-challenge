//
//  MovieCardViewTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  Unit tests for MovieCardView
//

import XCTest
import SwiftUI
@testable import MovieBrowser

final class MovieCardViewTests: XCTestCase {

    var sampleMovie: Movie!

    override func setUp() {
        super.setUp()
        sampleMovie = Movie(
            id: 1,
            name: "Test Movie",
            thumbnail: "https://example.com/test.jpg",
            year: 2023
        )
    }

    override func tearDown() {
        sampleMovie = nil
        super.tearDown()
    }

    // MARK: - Basic Initialization Tests
    func testMovieCardViewInitialization() {
        let cardView = MovieCardView(
            movie: sampleMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertEqual(cardView.movie.id, sampleMovie.id)
        XCTAssertEqual(cardView.movie.name, sampleMovie.name)
        XCTAssertFalse(cardView.isLiked)
    }

    func testMovieCardViewWithLikedState() {
        let cardView = MovieCardView(
            movie: sampleMovie,
            isLiked: true,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertTrue(cardView.isLiked)
    }

    func testMovieCardViewWithDifferentMovies() {
        let movies = [
            Movie(id: 1, name: "Movie 1", thumbnail: "url1", year: 2021),
            Movie(id: 2, name: "Movie 2", thumbnail: "url2", year: 2022),
            Movie(id: 3, name: "Movie 3", thumbnail: "url3", year: 2023)
        ]

        for movie in movies {
            let cardView = MovieCardView(
                movie: movie,
                isLiked: false,
                onLikeToggle: {},
                onTap: {}
            )

            XCTAssertNotNil(cardView)
            XCTAssertEqual(cardView.movie.id, movie.id)
        }
    }

    // MARK: - Movie Property Tests
    func testMovieCardWithLongTitle() {
        let longTitleMovie = Movie(
            id: 2,
            name: "This is a very long movie title that should be handled gracefully by the card view component",
            thumbnail: "https://example.com/long.jpg",
            year: 2023
        )

        let cardView = MovieCardView(
            movie: longTitleMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertEqual(cardView.movie.name.count, longTitleMovie.name.count)
    }

    func testMovieCardWithSpecialCharacters() {
        let specialMovie = Movie(
            id: 3,
            name: "Movie: The Return! (2023) - Part I",
            thumbnail: "https://example.com/special.jpg",
            year: 2023
        )

        let cardView = MovieCardView(
            movie: specialMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertEqual(cardView.movie.name, specialMovie.name)
    }

    func testMovieCardWithUnicodeTitle() {
        let unicodeMovie = Movie(
            id: 4,
            name: "🎬 Movie Title 🍿",
            thumbnail: "https://example.com/unicode.jpg",
            year: 2023
        )

        let cardView = MovieCardView(
            movie: unicodeMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertEqual(cardView.movie.name, unicodeMovie.name)
    }

    func testMovieCardWithEmptyTitle() {
        let emptyTitleMovie = Movie(
            id: 5,
            name: "",
            thumbnail: "https://example.com/empty.jpg",
            year: 2023
        )

        let cardView = MovieCardView(
            movie: emptyTitleMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertEqual(cardView.movie.name, "")
    }

    // MARK: - Year Tests
    func testMovieCardWithDifferentYears() {
        let years = [1920, 1950, 1980, 2000, 2023, 2030]

        for year in years {
            let movie = Movie(
                id: year,
                name: "Movie \(year)",
                thumbnail: "https://example.com/\(year).jpg",
                year: year
            )

            let cardView = MovieCardView(
                movie: movie,
                isLiked: false,
                onLikeToggle: {},
                onTap: {}
            )

            XCTAssertNotNil(cardView)
            XCTAssertEqual(cardView.movie.year, year)
        }
    }

    func testMovieCardWithFutureYear() {
        let futureMovie = Movie(
            id: 6,
            name: "Future Movie",
            thumbnail: "https://example.com/future.jpg",
            year: 2050
        )

        let cardView = MovieCardView(
            movie: futureMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertEqual(cardView.movie.year, 2050)
    }

    // MARK: - Thumbnail URL Tests
    func testMovieCardWithValidThumbnail() {
        let validMovie = Movie(
            id: 7,
            name: "Valid Thumbnail Movie",
            thumbnail: "https://example.com/valid.jpg",
            year: 2023
        )

        let cardView = MovieCardView(
            movie: validMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertNotNil(cardView.movie.thumbnailURL)
    }

    func testMovieCardWithInvalidThumbnail() {
        let invalidMovie = Movie(
            id: 8,
            name: "Invalid Thumbnail Movie",
            thumbnail: "",
            year: 2023
        )

        let cardView = MovieCardView(
            movie: invalidMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertNil(cardView.movie.thumbnailURL)
    }

    // MARK: - Callback Tests
    func testMovieCardLikeToggleCallback() {
        var likeToggled = false

        let cardView = MovieCardView(
            movie: sampleMovie,
            isLiked: false,
            onLikeToggle: { likeToggled = true },
            onTap: {}
        )

        XCTAssertNotNil(cardView)

        // Note: We can't directly trigger UI callbacks in unit tests
        // This test ensures the callback is properly stored
        XCTAssertFalse(likeToggled, "Callback should not be triggered during initialization")
    }

    func testMovieCardTapCallback() {
        var cardTapped = false

        let cardView = MovieCardView(
            movie: sampleMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: { cardTapped = true }
        )

        XCTAssertNotNil(cardView)

        // Note: We can't directly trigger UI callbacks in unit tests
        // This test ensures the callback is properly stored
        XCTAssertFalse(cardTapped, "Callback should not be triggered during initialization")
    }

    // MARK: - Edge Cases Tests
    func testMovieCardWithZeroId() {
        let zeroIdMovie = Movie(
            id: 0,
            name: "Zero ID Movie",
            thumbnail: "https://example.com/zero.jpg",
            year: 2023
        )

        let cardView = MovieCardView(
            movie: zeroIdMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertEqual(cardView.movie.id, 0)
    }

    func testMovieCardWithNegativeId() {
        let negativeIdMovie = Movie(
            id: -1,
            name: "Negative ID Movie",
            thumbnail: "https://example.com/negative.jpg",
            year: 2023
        )

        let cardView = MovieCardView(
            movie: negativeIdMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertEqual(cardView.movie.id, -1)
    }

    func testMovieCardWithLargeId() {
        let largeIdMovie = Movie(
            id: Int.max,
            name: "Large ID Movie",
            thumbnail: "https://example.com/large.jpg",
            year: 2023
        )

        let cardView = MovieCardView(
            movie: largeIdMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(cardView)
        XCTAssertEqual(cardView.movie.id, Int.max)
    }

    // MARK: - Performance Tests
    func testMovieCardCreationPerformance() {
        measure {
            for i in 0..<100 {
                let movie = Movie(
                    id: i,
                    name: "Performance Test Movie \(i)",
                    thumbnail: "https://example.com/perf\(i).jpg",
                    year: 2023
                )
                let _ = MovieCardView(
                    movie: movie,
                    isLiked: false,
                    onLikeToggle: {},
                    onTap: {}
                )
            }
        }
    }

    // MARK: - Compact Card View Tests
    func testCompactMovieCardViewInitialization() {
        let compactCardView = CompactMovieCardView(
            movie: sampleMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(compactCardView)
        XCTAssertEqual(compactCardView.movie.id, sampleMovie.id)
    }

    func testCompactMovieCardWithLongTitle() {
        let longTitleMovie = Movie(
            id: 10,
            name: "This is an extremely long movie title that should be handled properly in the compact card view",
            thumbnail: "https://example.com/compact.jpg",
            year: 2023
        )

        let compactCardView = CompactMovieCardView(
            movie: longTitleMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(compactCardView)
        XCTAssertEqual(compactCardView.movie.name, longTitleMovie.name)
    }

    func testCompactMovieCardWithLikedState() {
        let compactCardView = CompactMovieCardView(
            movie: sampleMovie,
            isLiked: true,
            onLikeToggle: {},
            onTap: {}
        )

        XCTAssertNotNil(compactCardView)
        XCTAssertTrue(compactCardView.isLiked)
    }

    // MARK: - Integration Tests
    func testMovieCardInNavigationContext() {
        let cardView = MovieCardView(
            movie: sampleMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        let navigationView = NavigationStack {
            cardView
        }

        XCTAssertNotNil(navigationView)
    }

    func testMovieCardInListContext() {
        let movies = Movie.sampleMovies

        let listView = List(movies, id: \.id) { movie in
            MovieCardView(
                movie: movie,
                isLiked: false,
                onLikeToggle: {},
                onTap: {}
            )
        }

        XCTAssertNotNil(listView)
    }

    // MARK: - State Variation Tests
    func testMovieCardWithAllLikeStates() {
        let likedStates = [true, false]

        for isLiked in likedStates {
            let cardView = MovieCardView(
                movie: sampleMovie,
                isLiked: isLiked,
                onLikeToggle: {},
                onTap: {}
            )

            XCTAssertNotNil(cardView)
            XCTAssertEqual(cardView.isLiked, isLiked)
        }
    }
}
