//
//  MovieDetailViewModel.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Movie Detail ViewModel
//

import Foundation
import Combine

// MARK: - Movie Detail View Model
/// ViewModel responsible for managing the movie detail screen state and business logic
@MainActor
class MovieDetailViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var movieDetails: MovieDetails?
    @Published var recommendedMovies: [Movie] = []
    @Published var detailsLoadingState: LoadingState = .idle
    @Published var recommendationsLoadingState: LoadingState = .idle
    @Published var isLiked: Bool = false

    // MARK: - Properties
    let movie: Movie

    // MARK: - Computed Properties
    /// Combined loading state for the entire screen
    var isLoadingAnyData: Bool {
        detailsLoadingState.isLoading || recommendationsLoadingState.isLoading
    }

    /// Whether we have successfully loaded the main movie details
    var hasMovieDetails: Bool {
        movieDetails != nil && detailsLoadingState == .loaded
    }

    /// Whether we have recommendations to show
    var hasRecommendations: Bool {
        !recommendedMovies.isEmpty && recommendationsLoadingState == .loaded
    }

    /// Error message to display to the user
    var errorMessage: String? {
        if case .failed(let error) = detailsLoadingState {
            return error.localizedDescription
        }
        return nil
    }

    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    private let likesService: LikesServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        movie: Movie,
        networkService: NetworkServiceProtocol,
        likesService: LikesServiceProtocol
    ) {
        self.movie = movie
        self.networkService = networkService
        self.likesService = likesService

        setupLikesObserver()

        // Start loading data asynchronously
        Task {
            await loadData()
        }
    }

    convenience init(movie: Movie) {
        let networkService = NetworkService()
        let likesService = LikesService.shared
        self.init(movie: movie, networkService: networkService, likesService: likesService)
    }

    // MARK: - Public Methods

    /// Loads both movie details and recommendations
    func loadData() async {
        async let detailsTask: Void = loadMovieDetails()
        async let recommendationsTask: Void = loadRecommendations()

        // Wait for both to complete
        await detailsTask
        await recommendationsTask
    }

    /// Loads detailed information for the movie
    func loadMovieDetails() async {
        guard !detailsLoadingState.isLoading else { return }

        detailsLoadingState = .loading

        do {
            let details = try await networkService.fetchMovieDetails(id: movie.id)
            movieDetails = details
            detailsLoadingState = .loaded

            // Preload the main movie image - disabled for now
            // if let pictureURL = details.pictureURL {
            //     Task {
            //         _ = await ImageCacheService.shared.loadImage(from: pictureURL)
            //     }
            // }

        } catch let error as NetworkError {
            movieDetails = nil
            detailsLoadingState = .failed(error)
        } catch {
            movieDetails = nil
            detailsLoadingState = .failed(.networkError(error.localizedDescription))
        }
    }

    /// Loads recommended movies for the current movie
    func loadRecommendations() async {
        guard !recommendationsLoadingState.isLoading else { return }

        recommendationsLoadingState = .loading

        do {
            let response = try await networkService.fetchRecommendedMovies(for: movie.id)
            recommendedMovies = response.movies
            recommendationsLoadingState = .loaded

            // Preload recommendation thumbnails
            preloadRecommendationThumbnails()

        } catch let error as NetworkError {
            recommendationsLoadingState = .failed(error)
        } catch {
            recommendationsLoadingState = .failed(.networkError(error.localizedDescription))
        }
    }

    /// Toggles the like status of the current movie
    func toggleLike() {
        likesService.toggleLike(for: movie.id)

        // Track the like action for analytics
        trackLikeAction()
    }

    /// Refreshes all data for the movie
    func refreshData() async {
        movieDetails = nil
        recommendedMovies = []
        detailsLoadingState = .idle
        recommendationsLoadingState = .idle

        await loadData()
    }

    /// Retries loading data after an error
    func retryLoading() async {
        await loadData()
    }

    // MARK: - Navigation Methods

    /// Creates a new MovieDetailViewModel for a recommended movie
    /// - Parameter recommendedMovie: The recommended movie to create a ViewModel for
    /// - Returns: A new MovieDetailViewModel instance
    func createViewModelForRecommendedMovie(_ recommendedMovie: Movie) -> MovieDetailViewModel {
        return MovieDetailViewModel(
            movie: recommendedMovie,
            networkService: networkService,
            likesService: likesService
        )
    }

    // MARK: - Private Methods

    /// Sets up observer for likes changes
    private func setupLikesObserver() {
        // Initial like state
        isLiked = likesService.isMovieLiked(movie.id)

        // Observe changes
        likesService.likedMoviesPublisher
            .map { [weak self] likedIds in
                guard let self = self else { return false }
                return likedIds.contains(self.movie.id)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLiked, on: self)
            .store(in: &cancellables)
    }

    /// Preloads recommendation thumbnail images
    private func preloadRecommendationThumbnails() {
        // Disabled for now - using SwiftUI's built-in AsyncImage
        // let thumbnailURLs = recommendedMovies.compactMap { $0.thumbnailURL }
        // ImageCacheService.shared.preloadImages(from: thumbnailURLs)
    }

    /// Tracks like/unlike actions for analytics
    private func trackLikeAction() {
        let action = isLiked ? "movie_unliked" : "movie_liked"
        trackEvent(action, parameters: [
            "movie_id": movie.id,
            "movie_name": movie.name
        ])
    }

    /// Generic analytics tracking method
    private func trackEvent(_ event: String, parameters: [String: Any] = [:]) {
        // In a production app, this would send events to analytics service
        #if DEBUG
        print("📊 \(event): \(parameters)")
        #endif
    }
}

// MARK: - Content Formatting Extension
extension MovieDetailViewModel {
    /// Formats the movie rating for display
    var formattedRating: String {
        guard let details = movieDetails else { return "N/A" }
        return "\(details.formattedRating)/10"
    }

    /// Gets star rating for UI display
    var starRating: Double {
        movieDetails?.starRating ?? 0.0
    }

    /// Formats the release date for display
    var formattedReleaseDate: String {
        movieDetails?.formattedReleaseDate ?? "Unknown"
    }

    /// Gets the main description text
    var movieDescription: String {
        movieDetails?.description ?? "No description available"
    }

    /// Gets the detailed notes text
    var movieNotes: String {
        movieDetails?.notes ?? ""
    }

    /// Determines if we should show the notes section
    var shouldShowNotes: Bool {
        guard let details = movieDetails else { return false }
        return !details.notes.isEmpty && details.notes != details.description
    }
}

// MARK: - Error Handling Extension
extension MovieDetailViewModel {
    /// User-friendly error message for details loading
    var detailsErrorMessage: String? {
        guard case .failed(let error) = detailsLoadingState else { return nil }

        switch error {
        case .noInternetConnection:
            return "Please check your internet connection and try again."
        case .serverError(let code) where code == 404:
            return "Movie details not found."
        case .serverError(let code) where code >= 500:
            return "Server error. Please try again later."
        case .timeout:
            return "Request timed out. Please try again."
        default:
            return "Failed to load movie details. Please try again."
        }
    }

    /// User-friendly error message for recommendations loading
    var recommendationsErrorMessage: String? {
        guard case .failed(let error) = recommendationsLoadingState else { return nil }

        switch error {
        case .noInternetConnection:
            return "Cannot load recommendations without internet."
        case .serverError(404):
            return "No recommendations found for this movie."
        default:
            return "Failed to load recommendations."
        }
    }

    /// Whether retry is available for details
    var canRetryDetails: Bool {
        if case .failed = detailsLoadingState {
            return true
        }
        return false
    }

    /// Whether retry is available for recommendations
    var canRetryRecommendations: Bool {
        if case .failed = recommendationsLoadingState {
            return true
        }
        return false
    }
}

// MARK: - Sharing Extension
extension MovieDetailViewModel {
    /// Creates a shareable text representation of the movie
    var shareableContent: String {
        var content = "Check out this movie: \(movie.name)"

        if let details = movieDetails {
            content += "\n\nRating: \(details.formattedRating)/10"
            content += "\nRelease Date: \(details.formattedReleaseDate)"
            content += "\n\n\(details.description)"
        }

        return content
    }

    /// Tracks sharing events
    func trackShareAction() {
        trackEvent("movie_shared", parameters: [
            "movie_id": movie.id,
            "movie_name": movie.name
        ])
    }
}
