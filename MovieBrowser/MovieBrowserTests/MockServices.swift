//
//  MockServices.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Mock Services for Testing
//

import Foundation
import Combine
@testable import MovieBrowser

// MARK: - Mock Network Service
@MainActor
final class MockNetworkService: NetworkServiceProtocol, @unchecked Sendable {

    // MARK: - Mock Properties
    var shouldThrowError = false
    var mockError: NetworkError = .noInternetConnection
    var movieListResponse: MovieListResponse?
    var movieDetailsResponse: MovieDetails?
    var recommendedMoviesResponse: RecommendedMoviesResponse?

    // MARK: - NetworkServiceProtocol Implementation
    func fetchMovieList() async throws -> MovieListResponse {
        if shouldThrowError {
            throw mockError
        }

        return movieListResponse ?? MovieListResponse(movies: Movie.sampleMovies)
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        if shouldThrowError {
            throw mockError
        }

        return movieDetailsResponse ?? MovieDetails.sampleDetails
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> RecommendedMoviesResponse {
        if shouldThrowError {
            throw mockError
        }

        return recommendedMoviesResponse ?? RecommendedMoviesResponse(movies: Movie.sampleMovies)
    }
}

// MARK: - Mock Likes Service
@MainActor
final class MockLikesService: LikesServiceProtocol, @unchecked Sendable {

    // MARK: - Mock Properties
    var likedMovieIds: Set<Int> = [1, 3] // Pre-populate with test data
    private let likedMoviesSubject = CurrentValueSubject<Set<Int>, Never>([1, 3])

    // MARK: - LikesServiceProtocol Implementation
    func isMovieLiked(_ movieId: Int) -> Bool {
        return likedMovieIds.contains(movieId)
    }

    func toggleLike(for movieId: Int) {
        if likedMovieIds.contains(movieId) {
            likedMovieIds.remove(movieId)
        } else {
            likedMovieIds.insert(movieId)
        }
        likedMoviesSubject.send(likedMovieIds)
    }

    func getLikedMovieIds() -> Set<Int> {
        return likedMovieIds
    }

    var likedMoviesPublisher: AnyPublisher<Set<Int>, Never> {
        likedMoviesSubject.eraseToAnyPublisher()
    }
}

// MARK: - Mock Simple Search Service
@MainActor
final class MockSimpleSearchService: SimpleSearchServiceProtocol, @unchecked Sendable {

    // MARK: - Mock Properties
    nonisolated(unsafe) var mockSearchResults: [SimpleSearchResult<Movie>] = []
    nonisolated(unsafe) var mockSuggestions: [String] = []
    nonisolated(unsafe) var searchCallCount = 0
    nonisolated(unsafe) var suggestionsCallCount = 0
    nonisolated(unsafe) var lastSearchQuery = ""
    nonisolated(unsafe) var lastSuggestionsQuery = ""

    // MARK: - SimpleSearchServiceProtocol Implementation
    nonisolated func search<T: SimpleSearchable>(_ items: [T], query: String) -> [SimpleSearchResult<T>] {
        searchCallCount += 1
        lastSearchQuery = query
        return mockSearchResults as? [SimpleSearchResult<T>] ?? []
    }

    nonisolated func generateSuggestions<T: SimpleSearchable>(_ items: [T], partialQuery: String) -> [String] {
        suggestionsCallCount += 1
        lastSuggestionsQuery = partialQuery
        return mockSuggestions
    }

    // MARK: - Test Helpers
    func reset() {
        searchCallCount = 0
        suggestionsCallCount = 0
        lastSearchQuery = ""
        lastSuggestionsQuery = ""
        mockSearchResults = []
        mockSuggestions = []
    }
}

// MARK: - Sample Data Extensions
extension Movie {
    static var sampleMovies: [Movie] {
        return [
            Movie(id: 1, name: "Avengers: Endgame", thumbnail: "https://example.com/1.jpg", year: 2019),
            Movie(id: 2, name: "The Dark Knight", thumbnail: "https://example.com/2.jpg", year: 2008),
            Movie(id: 3, name: "Inception", thumbnail: "https://example.com/3.jpg", year: 2010),
            Movie(id: 4, name: "Home Alone", thumbnail: "https://example.com/4.jpg", year: 1990),
            Movie(id: 5, name: "The Matrix", thumbnail: "https://example.com/5.jpg", year: 1999)
        ]
    }
}

extension MovieDetails {
    static var sampleDetails: MovieDetails {
        return MovieDetails(
            id: 1,
            name: "Avengers: Endgame",
            description: "The grave course of events set in motion by Thanos that wiped out half the universe and fractured the Avengers ranks compels the remaining Avengers to take one final stand in Marvel Studios' grand conclusion to twenty-two films, \"Avengers: Endgame.\"",
            notes: "After the devastating events of Avengers: Infinity War, the universe is in ruins due to the efforts of the Mad Titan, Thanos. With the help of remaining allies, the Avengers must assemble once more in order to undo Thanos' actions and restore order to the universe once and for all, no matter what consequences may be in store.",
            rating: 8.4,
            picture: "https://example.com/details/1.jpg",
            releaseDate: 1556150400 // April 25, 2019
        )
    }
}
