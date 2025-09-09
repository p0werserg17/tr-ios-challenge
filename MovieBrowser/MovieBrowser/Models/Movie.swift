//
//  Movie.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Data Models
//

import Foundation

// MARK: - Movie List Response Model
/// Represents the response from the movie list API endpoint
struct MovieListResponse: Codable, Equatable {
    let movies: [Movie]
}

// MARK: - Movie Model
/// Core movie model representing a movie in the list
struct Movie: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let thumbnail: String
    let year: Int

    /// Computed property to get URL from thumbnail string
    var thumbnailURL: URL? {
        URL(string: thumbnail)
    }

    /// Formatted year as string for display
    var yearString: String {
        String(year)
    }
}

// MARK: - Movie Details Model
/// Detailed movie information from the details API endpoint
struct MovieDetails: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let description: String
    let notes: String
    let rating: Double
    let picture: String
    let releaseDate: TimeInterval

    /// Custom coding keys to handle API response format
    private enum CodingKeys: String, CodingKey {
        case id, name, picture, releaseDate
        case description = "Description"
        case notes = "Notes"
        case rating = "Rating"  // API uses capital R
    }

    /// Computed property to get URL from picture string
    var pictureURL: URL? {
        URL(string: picture)
    }

    /// Formatted release date for display
    var formattedReleaseDate: String {
        let date = Date(timeIntervalSince1970: releaseDate)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    /// Formatted rating with one decimal place
    var formattedRating: String {
        String(format: "%.1f", rating)
    }

    /// Star rating out of 5 (converting from 10-point scale)
    var starRating: Double {
        rating / 2.0
    }
}

// MARK: - Recommended Movies Response Model
/// Response from the recommended movies API endpoint
struct RecommendedMoviesResponse: Codable, Equatable {
    let movies: [Movie]
}

// MARK: - Movie Extensions for UI
extension Movie {
    /// Sample data for previews and testing
    static let sampleMovies: [Movie] = [
        Movie(
            id: 1,
            name: "Avengers: Endgame",
            thumbnail: "https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/1.jpg",
            year: 2019
        ),
        Movie(
            id: 2,
            name: "Home Alone",
            thumbnail: "https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/2.jpg",
            year: 1990
        ),
        Movie(
            id: 3,
            name: "Inception",
            thumbnail: "https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/3.jpg",
            year: 2010
        )
    ]

    /// Single sample movie for detail previews
    static let sampleMovie = sampleMovies[0]
}

extension MovieDetails {
    /// Sample movie details for previews and testing
    static let sampleDetails = MovieDetails(
        id: 1,
        name: "Avengers: Endgame",
        description: "After the devastating events of Avengers: Infinity War (2018), the universe is in ruins. With the help of remaining allies, the Avengers assemble once more in order to reverse Thanos' actions and restore balance to the universe.",
        notes: "After the devastating events of Avengers: Infinity War (2018), the universe is in ruins due to the efforts of the Mad Titan, Thanos. With the help of remaining allies, the Avengers must assemble once more in order to undo Thanos's actions and undo the chaos to the universe, no matter what consequences may be in store, and no matter who they face...",
        rating: 8.4,
        picture: "https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/details/1.jpg",
        releaseDate: 1556236800
    )
}
