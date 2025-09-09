//
//  MovieListViewModel.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Movie List ViewModel
//

import Foundation
import Combine

// MARK: - Loading State
/// Represents different loading states for better UX
enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case failed(NetworkError)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var error: NetworkError? {
        if case .failed(let error) = self { return error }
        return nil
    }
}

// MARK: - Movie List View Model
/// ViewModel responsible for managing the movie list screen state and business logic
@MainActor
class MovieListViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var movies: [Movie] = []
    @Published var loadingState: LoadingState = .idle
    @Published var searchText: String = ""
    @Published var likedMovieIds: Set<Int> = []

    // MARK: - Computed Properties
    /// Filtered movies based on search text and sorted by year (newest first)
    var filteredMovies: [Movie] {
        let filtered = searchText.isEmpty ? movies : movies.filter { movie in
            movie.name.localizedCaseInsensitiveContains(searchText) ||
            movie.yearString.contains(searchText)
        }

        return filtered.sorted { $0.year > $1.year }
    }

    /// Movies that are currently liked
    var likedMovies: [Movie] {
        movies.filter { likedMovieIds.contains($0.id) }
    }

    /// Count of liked movies for display
    var likedMoviesCount: Int {
        likedMovieIds.count
    }

    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    private let likesService: LikesServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        networkService: NetworkServiceProtocol,
        likesService: LikesServiceProtocol
    ) {
        self.networkService = networkService
        self.likesService = likesService

        setupLikesObserver()
        loadMoviesIfNeeded()
    }

    convenience init() {
        let networkService = NetworkService()
        let likesService = LikesService.shared
        self.init(networkService: networkService, likesService: likesService)
    }

    // MARK: - Public Methods

    /// Loads the movie list from the API
    func loadMovies() async {
        guard !loadingState.isLoading else { return }

        loadingState = .loading

        do {
            let response = try await networkService.fetchMovieList()
            movies = response.movies
            loadingState = .loaded

            // Preload thumbnail images for better UX
            preloadThumbnails()

        } catch let error as NetworkError {
            loadingState = .failed(error)
        } catch {
            loadingState = .failed(.networkError(error.localizedDescription))
        }
    }

    /// Refreshes the movie list
    func refreshMovies() async {
        // Clear existing data for a fresh start
        movies = []
        await loadMovies()
    }

    /// Toggles the like status of a movie
    /// - Parameter movie: The movie to toggle like status for
    func toggleLike(for movie: Movie) {
        likesService.toggleLike(for: movie.id)
    }

    /// Checks if a movie is liked
    /// - Parameter movie: The movie to check
    /// - Returns: True if the movie is liked
    func isMovieLiked(_ movie: Movie) -> Bool {
        likesService.isMovieLiked(movie.id)
    }

    /// Clears the search text
    func clearSearch() {
        searchText = ""
    }

    /// Retries loading movies after an error
    func retryLoading() async {
        await loadMovies()
    }

    // MARK: - Private Methods

    /// Sets up observer for likes changes
    private func setupLikesObserver() {
        likesService.likedMoviesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.likedMovieIds, on: self)
            .store(in: &cancellables)
    }

    /// Loads movies only if not already loaded
    private func loadMoviesIfNeeded() {
        if movies.isEmpty && loadingState == .idle {
            Task {
                await loadMovies()
            }
        }
    }

    /// Preloads thumbnail images for better performance
    private func preloadThumbnails() {
        // Disabled for now - using SwiftUI's built-in AsyncImage
        // let thumbnailURLs = movies.compactMap { $0.thumbnailURL }
        // ImageCacheService.shared.preloadImages(from: thumbnailURLs)
    }
}

// MARK: - Search Functionality Extension
extension MovieListViewModel {
    /// Performs search with debouncing to avoid excessive API calls
    func performSearch() {
        // In a real app, this could trigger server-side search
        // For now, we're filtering locally
        objectWillChange.send()
    }

    /// Gets search suggestions based on current movies
    var searchSuggestions: [String] {
        let movieNames = movies.map { $0.name }
        let years = movies.map { $0.yearString }
        return Array(Set(movieNames + years)).sorted()
    }
}

// MARK: - Analytics Extension
extension MovieListViewModel {
    /// Tracks user interactions for analytics (placeholder for real implementation)
    private func trackEvent(_ event: String, parameters: [String: Any] = [:]) {
        // In a production app, this would send events to analytics service
        #if DEBUG
        print("📊 \(event): \(parameters)")
        #endif
    }

    /// Tracks movie view events
    func trackMovieViewed(_ movie: Movie) {
        trackEvent("movie_viewed", parameters: [
            "movie_id": movie.id,
            "movie_name": movie.name,
            "movie_year": movie.year
        ])
    }

    /// Tracks search events
    func trackSearchPerformed(_ query: String) {
        trackEvent("search_performed", parameters: [
            "query": query,
            "results_count": filteredMovies.count
        ])
    }
}

// MARK: - Error Recovery Extension
extension MovieListViewModel {
    /// Provides user-friendly error messages
    var userFriendlyErrorMessage: String? {
        guard case .failed(let error) = loadingState else { return nil }

        switch error {
        case .noInternetConnection:
            return "Please check your internet connection and try again."
        case .serverError(let code) where code >= 500:
            return "Our servers are experiencing issues. Please try again later."
        case .timeout:
            return "The request took too long. Please try again."
        default:
            return "Something went wrong. Please try again."
        }
    }

    /// Determines if retry is available
    var canRetry: Bool {
        if case .failed = loadingState {
            return true
        }
        return false
    }
}
