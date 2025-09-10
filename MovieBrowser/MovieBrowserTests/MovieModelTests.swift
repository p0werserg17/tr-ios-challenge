//
//  MovieModelTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  Unit tests for Movie data models
//

import XCTest
@testable import MovieBrowser

final class MovieModelTests: XCTestCase {

    // MARK: - Movie Tests
    func testMovieInitialization() {
        // Given
        let movie = Movie(
            id: 1,
            name: "Test Movie",
            thumbnail: "https://example.com/test.jpg",
            year: 2023
        )

        // Then
        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.name, "Test Movie")
        XCTAssertEqual(movie.thumbnail, "https://example.com/test.jpg")
        XCTAssertEqual(movie.year, 2023)
    }

    func testMovieThumbnailURL() {
        // Given
        let validMovie = Movie(id: 1, name: "Test", thumbnail: "https://example.com/test.jpg", year: 2023)
        let invalidMovie = Movie(id: 2, name: "Test", thumbnail: "", year: 2023)

        // Then
        XCTAssertNotNil(validMovie.thumbnailURL)
        XCTAssertEqual(validMovie.thumbnailURL?.absoluteString, "https://example.com/test.jpg")
        XCTAssertNil(invalidMovie.thumbnailURL)
    }

    func testMovieYearString() {
        // Given
        let movie = Movie(id: 1, name: "Test", thumbnail: "https://example.com/test.jpg", year: 2023)

        // Then
        XCTAssertEqual(movie.yearString, "2023")
    }

    func testMovieEquality() {
        // Given
        let movie1 = Movie(id: 1, name: "Test", thumbnail: "https://example.com/test.jpg", year: 2023)
        let movie2 = Movie(id: 1, name: "Test", thumbnail: "https://example.com/test.jpg", year: 2023)
        let movie3 = Movie(id: 2, name: "Different", thumbnail: "https://example.com/different.jpg", year: 2024)

        // Then
        XCTAssertEqual(movie1, movie2)
        XCTAssertNotEqual(movie1, movie3)
    }

    func testMovieHashable() {
        // Given
        let movie1 = Movie(id: 1, name: "Test", thumbnail: "https://example.com/test.jpg", year: 2023)
        let movie2 = Movie(id: 1, name: "Test", thumbnail: "https://example.com/test.jpg", year: 2023)
        let movie3 = Movie(id: 2, name: "Different", thumbnail: "https://example.com/different.jpg", year: 2024)

        // When
        let set = Set([movie1, movie2, movie3])

        // Then
        XCTAssertEqual(set.count, 2) // movie1 and movie2 should be considered the same
    }

    func testMovieSampleData() {
        // Then
        XCTAssertFalse(Movie.sampleMovies.isEmpty)
        XCTAssertEqual(Movie.sampleMovies.count, 5)
        XCTAssertEqual(Movie.sampleMovie.id, Movie.sampleMovies[0].id)

        // Verify sample movies have required properties
        for movie in Movie.sampleMovies {
            XCTAssertGreaterThan(movie.id, 0)
            XCTAssertFalse(movie.name.isEmpty)
            XCTAssertFalse(movie.thumbnail.isEmpty)
            XCTAssertGreaterThan(movie.year, 1900)
        }
    }

    // MARK: - MovieDetails Tests
    func testMovieDetailsInitialization() {
        // Given
        let details = MovieDetails(
            id: 1,
            name: "Test Movie",
            description: "Test description",
            notes: "Test notes",
            rating: 8.5,
            picture: "https://example.com/picture.jpg",
            releaseDate: 1640995200 // Jan 1, 2022
        )

        // Then
        XCTAssertEqual(details.id, 1)
        XCTAssertEqual(details.name, "Test Movie")
        XCTAssertEqual(details.description, "Test description")
        XCTAssertEqual(details.notes, "Test notes")
        XCTAssertEqual(details.rating, 8.5)
        XCTAssertEqual(details.picture, "https://example.com/picture.jpg")
        XCTAssertEqual(details.releaseDate, 1640995200)
    }

    func testMovieDetailsPictureURL() {
        // Given
        let validDetails = MovieDetails(
            id: 1, name: "Test", description: "Desc", notes: "Notes",
            rating: 8.0, picture: "https://example.com/picture.jpg", releaseDate: 0
        )
        let invalidDetails = MovieDetails(
            id: 1, name: "Test", description: "Desc", notes: "Notes",
            rating: 8.0, picture: "", releaseDate: 0
        )

        // Then
        XCTAssertNotNil(validDetails.pictureURL)
        XCTAssertEqual(validDetails.pictureURL?.absoluteString, "https://example.com/picture.jpg")
        XCTAssertNil(invalidDetails.pictureURL)
    }

    func testMovieDetailsFormattedReleaseDate() {
        // Given - Jan 1, 2022 timestamp
        let details = MovieDetails(
            id: 1, name: "Test", description: "Desc", notes: "Notes",
            rating: 8.0, picture: "https://example.com/picture.jpg", releaseDate: 1640995200
        )

        // Then
        let formattedDate = details.formattedReleaseDate
        XCTAssertFalse(formattedDate.isEmpty)
        // Should contain year 2021 or 2022 (depending on timezone)
        XCTAssertTrue(formattedDate.contains("2021") || formattedDate.contains("2022"))
    }

    func testMovieDetailsFormattedRating() {
        // Given
        let details = MovieDetails(
            id: 1, name: "Test", description: "Desc", notes: "Notes",
            rating: 8.567, picture: "https://example.com/picture.jpg", releaseDate: 0
        )

        // Then
        XCTAssertEqual(details.formattedRating, "8.6")
    }

    func testMovieDetailsStarRating() {
        // Given
        let details = MovieDetails(
            id: 1, name: "Test", description: "Desc", notes: "Notes",
            rating: 8.0, picture: "https://example.com/picture.jpg", releaseDate: 0
        )

        // Then
        XCTAssertEqual(details.starRating, 4.0) // 8.0 / 2.0 = 4.0
    }

    func testMovieDetailsEquality() {
        // Given
        let details1 = MovieDetails(
            id: 1, name: "Test", description: "Desc", notes: "Notes",
            rating: 8.0, picture: "https://example.com/picture.jpg", releaseDate: 0
        )
        let details2 = MovieDetails(
            id: 1, name: "Test", description: "Desc", notes: "Notes",
            rating: 8.0, picture: "https://example.com/picture.jpg", releaseDate: 0
        )
        let details3 = MovieDetails(
            id: 2, name: "Different", description: "Different", notes: "Different",
            rating: 7.0, picture: "https://example.com/different.jpg", releaseDate: 1000
        )

        // Then
        XCTAssertEqual(details1, details2)
        XCTAssertNotEqual(details1, details3)
    }

    func testMovieDetailsSampleData() {
        // Given
        let sampleDetails = MovieDetails.sampleDetails

        // Then
        XCTAssertEqual(sampleDetails.id, 1)
        XCTAssertFalse(sampleDetails.name.isEmpty)
        XCTAssertFalse(sampleDetails.description.isEmpty)
        XCTAssertFalse(sampleDetails.notes.isEmpty)
        XCTAssertGreaterThan(sampleDetails.rating, 0)
        XCTAssertFalse(sampleDetails.picture.isEmpty)
        XCTAssertGreaterThan(sampleDetails.releaseDate, 0)
    }

    func testMovieSampleDataConsistency() {
        // Test that sample data is consistent and realistic
        for movie in Movie.sampleMovies {
            XCTAssertNotNil(movie.thumbnailURL, "Sample movie \(movie.name) should have valid thumbnail URL")
            XCTAssertTrue(movie.year >= 1900 && movie.year <= 2030, "Sample movie \(movie.name) should have realistic year")
            XCTAssertTrue(movie.name.count > 1, "Sample movie should have meaningful name")
        }

        // Test that sample movie has the same ID as the first movie in sampleMovies
        XCTAssertEqual(Movie.sampleMovie.id, Movie.sampleMovies[0].id, "sampleMovie should be the first movie in sampleMovies")
    }

    func testMovieDetailsEdgeCases() {
        // Test with zero/empty values
        let edgeCaseDetails = MovieDetails(
            id: 0,
            name: "",
            description: "",
            notes: "",
            rating: 0.0,
            picture: "",
            releaseDate: 0.0
        )

        XCTAssertEqual(edgeCaseDetails.id, 0)
        XCTAssertEqual(edgeCaseDetails.name, "")
        XCTAssertEqual(edgeCaseDetails.description, "")
        XCTAssertEqual(edgeCaseDetails.notes, "")
        XCTAssertEqual(edgeCaseDetails.rating, 0.0)
        XCTAssertEqual(edgeCaseDetails.picture, "")
        XCTAssertEqual(edgeCaseDetails.releaseDate, 0.0)
        XCTAssertNil(edgeCaseDetails.pictureURL)
        XCTAssertEqual(edgeCaseDetails.starRating, 0.0)
        XCTAssertEqual(edgeCaseDetails.formattedRating, "0.0")
    }

    // MARK: - Response Models Tests
    func testMovieListResponse() {
        // Given
        let movies = [
            Movie(id: 1, name: "Movie 1", thumbnail: "https://example.com/1.jpg", year: 2023),
            Movie(id: 2, name: "Movie 2", thumbnail: "https://example.com/2.jpg", year: 2024)
        ]
        let response = MovieListResponse(movies: movies)

        // Then
        XCTAssertEqual(response.movies.count, 2)
        XCTAssertEqual(response.movies[0].name, "Movie 1")
        XCTAssertEqual(response.movies[1].name, "Movie 2")
    }

    func testRecommendedMoviesResponse() {
        // Given
        let movies = [
            Movie(id: 1, name: "Recommended 1", thumbnail: "https://example.com/1.jpg", year: 2023)
        ]
        let response = RecommendedMoviesResponse(movies: movies)

        // Then
        XCTAssertEqual(response.movies.count, 1)
        XCTAssertEqual(response.movies[0].name, "Recommended 1")
    }

    // MARK: - JSON Decoding Tests
    func testMovieJSONDecoding() throws {
        // Given
        let json = """
        {
            "id": 1,
            "name": "Test Movie",
            "thumbnail": "https://example.com/test.jpg",
            "year": 2023
        }
        """
        let data = json.data(using: .utf8)!

        // When
        let movie = try JSONDecoder().decode(Movie.self, from: data)

        // Then
        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.name, "Test Movie")
        XCTAssertEqual(movie.thumbnail, "https://example.com/test.jpg")
        XCTAssertEqual(movie.year, 2023)
    }

    func testMovieDetailsJSONDecoding() throws {
        // Given - Note the capital letters in API response
        let json = """
        {
            "id": 1,
            "name": "Test Movie",
            "Description": "Test description",
            "Notes": "Test notes",
            "Rating": 8.5,
            "picture": "https://example.com/picture.jpg",
            "releaseDate": 1640995200
        }
        """
        let data = json.data(using: .utf8)!

        // When
        let details = try JSONDecoder().decode(MovieDetails.self, from: data)

        // Then
        XCTAssertEqual(details.id, 1)
        XCTAssertEqual(details.name, "Test Movie")
        XCTAssertEqual(details.description, "Test description")
        XCTAssertEqual(details.notes, "Test notes")
        XCTAssertEqual(details.rating, 8.5)
        XCTAssertEqual(details.picture, "https://example.com/picture.jpg")
        XCTAssertEqual(details.releaseDate, 1640995200)
    }
}
