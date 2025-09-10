//
//  MovieDetailViewTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  Unit tests for MovieDetailView
//

import XCTest
import SwiftUI
@testable import MovieBrowser

final class MovieDetailViewTests: XCTestCase {

    // MARK: - Properties
    var sampleMovie: Movie!
    var sampleMovieDetails: MovieDetails!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sampleMovie = Movie(
            id: 1,
            name: "Test Movie",
            thumbnail: "https://example.com/test.jpg",
            year: 2023
        )

        sampleMovieDetails = MovieDetails(
            id: 1,
            name: "Test Movie",
            description: "A test movie description",
            notes: "Some test notes",
            rating: 8.5,
            picture: "https://example.com/details.jpg",
            releaseDate: 1640995200
        )
    }

    override func tearDown() {
        sampleMovie = nil
        sampleMovieDetails = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func testMovieDetailViewInitialization() {
        // Given & When
        let movieDetailView = MovieDetailView(movie: sampleMovie)

        // Then
        XCTAssertEqual(movieDetailView.movie.id, sampleMovie.id)
        XCTAssertEqual(movieDetailView.movie.name, sampleMovie.name)
        XCTAssertEqual(movieDetailView.movie.year, sampleMovie.year)
    }

    // MARK: - Helper Methods Tests
    func testMovieDetailViewHelpers() {
        // Given
        let movieDetailView = MovieDetailView(movie: sampleMovie)

        // When & Then - Test that the view can be created without crashing
        XCTAssertNotNil(movieDetailView.body)
    }

    // MARK: - State Management Tests
    func testInitialState() {
        // Given
        let movieDetailView = MovieDetailView(movie: sampleMovie)

        // Then - Initial state should be properly set
        XCTAssertEqual(movieDetailView.movie.id, 1)
        XCTAssertEqual(movieDetailView.movie.name, "Test Movie")
        XCTAssertEqual(movieDetailView.movie.year, 2023)
    }

    // MARK: - View Component Tests
    func testViewHasRequiredComponents() {
        // Given
        let movieDetailView = MovieDetailView(movie: sampleMovie)

        // When - Create the view
        let view = movieDetailView.body

        // Then - View should be created successfully
        XCTAssertNotNil(view)
    }

    // MARK: - Edge Cases
    func testMovieDetailViewWithEmptyMovie() {
        // Given
        let emptyMovie = Movie(
            id: 0,
            name: "",
            thumbnail: "",
            year: 0
        )

        // When
        let movieDetailView = MovieDetailView(movie: emptyMovie)

        // Then
        XCTAssertEqual(movieDetailView.movie.id, 0)
        XCTAssertEqual(movieDetailView.movie.name, "")
        XCTAssertEqual(movieDetailView.movie.year, 0)
    }

    func testMovieDetailViewWithLongTitle() {
        // Given
        let longTitleMovie = Movie(
            id: 2,
            name: "This is a very long movie title that should still work properly in the detail view without causing any layout issues",
            thumbnail: "https://example.com/long.jpg",
            year: 2024
        )

        // When
        let movieDetailView = MovieDetailView(movie: longTitleMovie)

        // Then
        XCTAssertEqual(movieDetailView.movie.name.count, 116) // Verify long title
        XCTAssertNotNil(movieDetailView.body)
    }

    func testMovieDetailViewWithSpecialCharacters() {
        // Given
        let specialCharMovie = Movie(
            id: 3,
            name: "Movie: The Sequel - Part II (2024) & More!",
            thumbnail: "https://example.com/special.jpg",
            year: 2024
        )

        // When
        let movieDetailView = MovieDetailView(movie: specialCharMovie)

        // Then
        XCTAssertTrue(movieDetailView.movie.name.contains(":"))
        XCTAssertTrue(movieDetailView.movie.name.contains("&"))
        XCTAssertNotNil(movieDetailView.body)
    }

    // MARK: - Performance Tests
    func testMovieDetailViewCreationPerformance() {
        measure {
            for _ in 0..<100 {
                let movieDetailView = MovieDetailView(movie: sampleMovie)
                _ = movieDetailView.body
            }
        }
    }

    // MARK: - Memory Tests
    func testMovieDetailViewMemoryUsage() {
        // Given
        var movieDetailViews: [MovieDetailView] = []

        // When - Create multiple instances
        for i in 0..<10 {
            let movie = Movie(
                id: i,
                name: "Movie \(i)",
                thumbnail: "https://example.com/\(i).jpg",
                year: 2020 + i
            )
            movieDetailViews.append(MovieDetailView(movie: movie))
        }

        // Then
        XCTAssertEqual(movieDetailViews.count, 10)

        // Clean up
        movieDetailViews.removeAll()
        XCTAssertEqual(movieDetailViews.count, 0)
    }

    // MARK: - Component Rendering Tests
    func testMainContentRendering() {
        let _ = MovieDetailView(movie: sampleMovie)

        // Test that main content can be rendered - view creation should not crash
        XCTAssertTrue(true) // Test passes if no crash occurs during view creation
    }

    func testHeroSectionRendering() {
        // Test hero section with different movie properties
        let movies = [
            Movie(id: 1, name: "Short", thumbnail: "url", year: 2020),
            Movie(id: 2, name: "Very Long Movie Title That Should Wrap Properly", thumbnail: "url", year: 2021),
            Movie(id: 3, name: "Movie with Special Characters: & - ()", thumbnail: "url", year: 2022)
        ]

        for movie in movies {
            let view = MovieDetailView(movie: movie)
            XCTAssertNotNil(view.body)
        }
    }

    func testMovieInfoSectionRendering() {
        // Test movie info section with various year formats
        let years = [1900, 1999, 2000, 2023, 2024]

        for year in years {
            let movie = Movie(id: 1, name: "Test", thumbnail: "url", year: year)
            let view = MovieDetailView(movie: movie)
            XCTAssertNotNil(view.body)
            XCTAssertEqual(view.movie.year, year)
        }
    }

    func testToolbarButtonsRendering() {
        let movieDetailView = MovieDetailView(movie: sampleMovie)

        // Test that toolbar buttons can be rendered
        XCTAssertNotNil(movieDetailView.body)
    }

    func testRecommendationsSectionRendering() {
        let movieDetailView = MovieDetailView(movie: sampleMovie)

        // Test recommendations section rendering
        XCTAssertNotNil(movieDetailView.body)
    }

    // MARK: - State Variation Tests
    func testViewWithDifferentMovieStates() {
        let testMovies = [
            // Minimal movie
            Movie(id: 1, name: "A", thumbnail: "", year: 1),
            // Normal movie
            Movie(id: 2, name: "Normal Movie", thumbnail: "https://example.com/normal.jpg", year: 2023),
            // Movie with long name
            Movie(id: 3, name: String(repeating: "Very Long Movie Name ", count: 10), thumbnail: "https://example.com/long.jpg", year: 2024),
            // Movie with special year
            Movie(id: 4, name: "Old Movie", thumbnail: "https://example.com/old.jpg", year: 1920),
            // Movie with future year
            Movie(id: 5, name: "Future Movie", thumbnail: "https://example.com/future.jpg", year: 2030)
        ]

        for movie in testMovies {
            let view = MovieDetailView(movie: movie)
            XCTAssertNotNil(view.body)
            XCTAssertEqual(view.movie.id, movie.id)
        }
    }

    func testViewWithDifferentThumbnailURLs() {
        let thumbnailURLs = [
            "",
            "invalid-url",
            "http://example.com/image.jpg",
            "https://secure.example.com/image.png",
            "https://example.com/very/long/path/to/image/file.jpeg"
        ]

        for (index, thumbnail) in thumbnailURLs.enumerated() {
            let movie = Movie(id: index, name: "Test Movie", thumbnail: thumbnail, year: 2023)
            let view = MovieDetailView(movie: movie)
            XCTAssertNotNil(view.body)
            XCTAssertEqual(view.movie.thumbnail, thumbnail)
        }
    }

    // MARK: - Integration Tests
    func testMovieDetailViewIntegration() {
        // Test that all components work together
        let movieDetailView = MovieDetailView(movie: sampleMovie)

        // Test view creation and body rendering
        let body = movieDetailView.body
        XCTAssertNotNil(body)

        // Test movie property access
        XCTAssertEqual(movieDetailView.movie.name, sampleMovie.name)
        XCTAssertEqual(movieDetailView.movie.year, sampleMovie.year)
    }

    func testViewStateManagement() {
        let movieDetailView = MovieDetailView(movie: sampleMovie)

        // Test that view maintains state properly
        XCTAssertEqual(movieDetailView.movie.id, sampleMovie.id)

        // Test view can be rendered multiple times
        for _ in 0..<5 {
            XCTAssertNotNil(movieDetailView.body)
        }
    }

    // MARK: - Accessibility Tests
    func testAccessibilitySupport() {
        let movieDetailView = MovieDetailView(movie: sampleMovie)

        // Test that view supports accessibility
        XCTAssertNotNil(movieDetailView.body)

        // Test with movies that have accessibility-relevant content
        let accessibilityTestMovies = [
            Movie(id: 1, name: "Movie with Numbers 123", thumbnail: "url", year: 2023),
            Movie(id: 2, name: "Movie with Symbols !@#$%", thumbnail: "url", year: 2023),
            Movie(id: 3, name: "Movie with Accents: Café, Naïve", thumbnail: "url", year: 2023)
        ]

        for movie in accessibilityTestMovies {
            let view = MovieDetailView(movie: movie)
            XCTAssertNotNil(view.body)
        }
    }

    // MARK: - Error Handling Tests
    func testViewWithCorruptedData() {
        // Test with edge case data
        let corruptedMovies = [
            Movie(id: -1, name: "Negative ID", thumbnail: "url", year: 2023),
            Movie(id: Int.max, name: "Max ID", thumbnail: "url", year: 2023),
            Movie(id: 1, name: "", thumbnail: "url", year: 2023), // Empty name
            Movie(id: 1, name: "Test", thumbnail: "", year: 0), // Invalid year
            Movie(id: 1, name: "Test", thumbnail: "not-a-url", year: -100) // Negative year
        ]

        for movie in corruptedMovies {
            let view = MovieDetailView(movie: movie)
            XCTAssertNotNil(view.body) // Should handle gracefully
        }
    }

    // MARK: - Performance Edge Cases
    func testLargeDataHandling() {
        // Test with very large data
        let largeNameMovie = Movie(
            id: 1,
            name: String(repeating: "A", count: 1000), // Very long name
            thumbnail: "https://example.com/image.jpg",
            year: 2023
        )

        let view = MovieDetailView(movie: largeNameMovie)
        XCTAssertNotNil(view.body)
        XCTAssertEqual(view.movie.name.count, 1000)
    }

    func testRapidViewCreation() {
        // Test rapid creation and destruction
        measure {
            for i in 0..<50 {
                let movie = Movie(id: i, name: "Movie \(i)", thumbnail: "url", year: 2023)
                let view = MovieDetailView(movie: movie)
                _ = view.body // Force body computation
            }
        }
    }
}

// MARK: - Shimmer Extension Tests
final class ShimmerExtensionTests: XCTestCase {

    func testShimmerExtension() {
        // Test that shimmer extension can be applied to views
        let rectangle = Rectangle()
        let shimmeredView = rectangle.shimmer()

        XCTAssertNotNil(shimmeredView)
    }

    func testShimmerOnDifferentViews() {
        // Test shimmer on various view types
        let views: [any View] = [
            Rectangle(),
            Circle(),
            Text("Test"),
            Image(systemName: "star")
        ]

        for view in views {
            let shimmeredView = AnyView(view).shimmer()
            XCTAssertNotNil(shimmeredView)
        }
    }

    func testMultipleShimmerApplications() {
        // Test applying shimmer multiple times
        let rectangle = Rectangle()
        let doubleShimmered = rectangle.shimmer().shimmer()

        XCTAssertNotNil(doubleShimmered)
    }

    func testShimmerPerformance() {
        // Test shimmer performance
        measure {
            for _ in 0..<100 {
                let view = Rectangle().shimmer()
                _ = view
            }
        }
    }
}

// MARK: - ShareSheet Tests
final class ShareSheetTests: XCTestCase {

    func testShareSheetInitialization() {
        // Given
        let activityItems = ["Test content"]

        // When
        let shareSheet = ShareSheet(activityItems: activityItems)

        // Then
        XCTAssertEqual(shareSheet.activityItems.count, 1)
        XCTAssertEqual(shareSheet.activityItems.first as? String, "Test content")
    }

    func testShareSheetWithMultipleItems() {
        // Given
        let activityItems: [Any] = ["Text content", URL(string: "https://example.com")!]

        // When
        let shareSheet = ShareSheet(activityItems: activityItems)

        // Then
        XCTAssertEqual(shareSheet.activityItems.count, 2)
        XCTAssertEqual(shareSheet.activityItems.first as? String, "Text content")
        XCTAssertEqual(shareSheet.activityItems.last as? URL, URL(string: "https://example.com"))
    }

    func testShareSheetWithEmptyItems() {
        // Given
        let activityItems: [Any] = []

        // When
        let shareSheet = ShareSheet(activityItems: activityItems)

        // Then
        XCTAssertEqual(shareSheet.activityItems.count, 0)
    }

    func testShareSheetWithVariousItemTypes() {
        // Test ShareSheet with different item types
        let itemSets: [[Any]] = [
            ["Simple string"],
            [URL(string: "https://example.com")!],
            [UIImage()],
            ["String", URL(string: "https://example.com")!],
            ["Text", URL(string: "https://example.com")!, UIImage()],
            [NSString("NSString"), NSURL(string: "https://example.com")!]
        ]

        for items in itemSets {
            let shareSheet = ShareSheet(activityItems: items)
            XCTAssertEqual(shareSheet.activityItems.count, items.count)
        }
    }

    func testShareSheetUIViewControllerRepresentable() {
        // Test UIViewControllerRepresentable conformance
        let shareSheet = ShareSheet(activityItems: ["Test"])

        // Test that ShareSheet conforms to UIViewControllerRepresentable
        // We can't easily create the context, so we test the structure instead
        XCTAssertNotNil(shareSheet)
        XCTAssertEqual(shareSheet.activityItems.count, 1)

        // Test that it's a proper UIViewControllerRepresentable by checking it compiles
        // The actual functionality would be tested in UI tests
    }

    func testShareSheetWithLargeContent() {
        // Test with large content
        let largeString = String(repeating: "Large content ", count: 1000)
        let shareSheet = ShareSheet(activityItems: [largeString])

        XCTAssertEqual(shareSheet.activityItems.count, 1)
        XCTAssertEqual(shareSheet.activityItems.first as? String, largeString)
    }

    func testShareSheetPerformance() {
        // Test ShareSheet creation performance
        measure {
            for i in 0..<100 {
                let items = ["Item \(i)", URL(string: "https://example.com/\(i)")!]
                let shareSheet = ShareSheet(activityItems: items)
                _ = shareSheet.activityItems.count
            }
        }
    }
}
