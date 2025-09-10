//
//  LikesService.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Local Persistence Layer
//

import Foundation
import Combine

// MARK: - Likes Service Protocol
/// Protocol defining the likes service interface for better testability
@MainActor
protocol LikesServiceProtocol: Sendable {
    func isMovieLiked(_ movieId: Int) -> Bool
    func toggleLike(for movieId: Int)
    func getLikedMovieIds() -> Set<Int>
    var likedMoviesPublisher: AnyPublisher<Set<Int>, Never> { get }
}

// MARK: - Likes Service Implementation
/// Service responsible for managing liked movies with local persistence
@MainActor
final class LikesService: LikesServiceProtocol, ObservableObject, @unchecked Sendable {

    // MARK: - Shared Instance
    static let shared = LikesService()

    // MARK: - Properties
    @Published private var likedMovieIds: Set<Int> = []
    private let userDefaults: UserDefaults
    private let likesKey = "MovieBrowser.LikedMovies"

    // MARK: - Publishers
    var likedMoviesPublisher: AnyPublisher<Set<Int>, Never> {
        $likedMovieIds.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadLikedMovies()
    }

    // MARK: - Public Methods

    /// Checks if a specific movie is liked
    /// - Parameter movieId: The ID of the movie to check
    /// - Returns: True if the movie is liked, false otherwise
    func isMovieLiked(_ movieId: Int) -> Bool {
        likedMovieIds.contains(movieId)
    }

    /// Toggles the like status of a movie
    /// - Parameter movieId: The ID of the movie to toggle
    func toggleLike(for movieId: Int) {
        if likedMovieIds.contains(movieId) {
            likedMovieIds.remove(movieId)
        } else {
            likedMovieIds.insert(movieId)
        }
        saveLikedMovies()

        // Add haptic feedback for better UX
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    /// Returns all liked movie IDs
    /// - Returns: Set containing all liked movie IDs
    func getLikedMovieIds() -> Set<Int> {
        likedMovieIds
    }

    /// Removes a specific movie from likes
    /// - Parameter movieId: The ID of the movie to unlike
    func unlikeMovie(_ movieId: Int) {
        if likedMovieIds.contains(movieId) {
            likedMovieIds.remove(movieId)
            saveLikedMovies()
        }
    }

    /// Likes a specific movie
    /// - Parameter movieId: The ID of the movie to like
    func likeMovie(_ movieId: Int) {
        if !likedMovieIds.contains(movieId) {
            likedMovieIds.insert(movieId)
            saveLikedMovies()
        }
    }

    /// Clears all liked movies
    func clearAllLikes() {
        likedMovieIds.removeAll()
        saveLikedMovies()
    }

    /// Gets the count of liked movies
    var likedMoviesCount: Int {
        likedMovieIds.count
    }

    // MARK: - Private Methods

    /// Loads liked movies from UserDefaults
    private func loadLikedMovies() {
        if let data = userDefaults.data(forKey: likesKey),
           let decodedIds = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            likedMovieIds = decodedIds
        }
    }

    /// Saves liked movies to UserDefaults
    private func saveLikedMovies() {
        if let data = try? JSONEncoder().encode(likedMovieIds) {
            userDefaults.set(data, forKey: likesKey)
        }
    }
}

// Note: MockLikesService is now located in MockServices.swift for better organization

// MARK: - UIKit Bridge for Haptic Feedback
#if canImport(UIKit)
import UIKit

/// Extension to provide haptic feedback functionality
extension LikesService {
    /// Provides haptic feedback for like actions
    private func provideLikeFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
}
#endif
