//
//  NetworkService.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Network Layer
//

import Foundation

// MARK: - URLSession Protocol
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: - Network Errors
/// Comprehensive error types for network operations
enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case noData
    case decodingError(String)
    case networkError(String)
    case serverError(Int)
    case timeout
    case noInternetConnection

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .noData:
            return "No data received from server"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .timeout:
            return "Request timed out"
        case .noInternetConnection:
            return "No internet connection available"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection:
            return "Please check your internet connection and try again"
        case .timeout:
            return "Please try again"
        case .serverError:
            return "Please try again later"
        default:
            return "Please try again"
        }
    }
}

// MARK: - Network Service Protocol
/// Protocol defining the network service interface for better testability
protocol NetworkServiceProtocol: Sendable {
    func fetchMovieList() async throws -> MovieListResponse
    func fetchMovieDetails(id: Int) async throws -> MovieDetails
    func fetchRecommendedMovies(for movieId: Int) async throws -> RecommendedMoviesResponse
}

// MARK: - Network Service Implementation
/// Main network service handling all API communications
final class NetworkService: NetworkServiceProtocol, ObservableObject, @unchecked Sendable {

    // MARK: - Properties
    private let session: URLSessionProtocol
    private let baseURL = "https://raw.githubusercontent.com/p0werserg17/tr-ios-challenge/master/Instructions"
    private let cache = NSCache<NSString, NSData>()

    // MARK: - Initialization
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
        setupCache()
    }

    private func setupCache() {
        cache.countLimit = 100 // Limit number of cached responses
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB cache limit
    }

    // MARK: - Public API Methods

    /// Fetches the complete list of movies
    /// - Returns: MovieListResponse containing array of movies
    /// - Throws: NetworkError for various failure cases
    func fetchMovieList() async throws -> MovieListResponse {
        let endpoint = "/list.json"
        let url = try buildURL(endpoint: endpoint)

        return try await performRequest(url: url, responseType: MovieListResponse.self)
    }

    /// Fetches detailed information for a specific movie
    /// - Parameter id: The movie ID to fetch details for
    /// - Returns: MovieDetails object with comprehensive movie information
    /// - Throws: NetworkError for various failure cases
    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        let endpoint = "/details/\(id).json"
        let url = try buildURL(endpoint: endpoint)

        return try await performRequest(url: url, responseType: MovieDetails.self)
    }

    /// Fetches recommended movies for a specific movie
    /// - Parameter movieId: The movie ID to get recommendations for
    /// - Returns: RecommendedMoviesResponse containing recommended movies
    /// - Throws: NetworkError for various failure cases
    func fetchRecommendedMovies(for movieId: Int) async throws -> RecommendedMoviesResponse {
        let endpoint = "/details/recommended/\(movieId).json"
        let url = try buildURL(endpoint: endpoint)

        return try await performRequest(url: url, responseType: RecommendedMoviesResponse.self)
    }

    // MARK: - Private Helper Methods

    /// Builds a complete URL from the base URL and endpoint
    /// - Parameter endpoint: The API endpoint to append
    /// - Returns: Complete URL for the request
    /// - Throws: NetworkError.invalidURL if URL construction fails
    private func buildURL(endpoint: String) throws -> URL {
        let urlString = baseURL + endpoint
        #if DEBUG
        print("🌐 API URL: \(urlString)")
        #endif
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        return url
    }

    /// Performs a generic network request with caching support
    /// - Parameters:
    ///   - url: The URL to request
    ///   - responseType: The expected response type to decode to
    /// - Returns: Decoded response object
    /// - Throws: NetworkError for various failure cases
    private func performRequest<T: Codable>(url: URL, responseType: T.Type) async throws -> T {
        let cacheKey = NSString(string: url.absoluteString)

        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: cachedData as Data)
            } catch {
                // If cached data is corrupted, remove it and continue with network request
                cache.removeObject(forKey: cacheKey)
            }
        }

        // Configure request with timeout
        var request = URLRequest(url: url)
        request.timeoutInterval = 30.0
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError("Invalid response type")
            }

            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                break // Success
            case 400...499:
                throw NetworkError.serverError(httpResponse.statusCode)
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NetworkError.networkError("Unexpected status code: \(httpResponse.statusCode)")
            }

            // Validate data
            guard !data.isEmpty else {
                #if DEBUG
                print("🚨 No data received from: \(url)")
                #endif
                throw NetworkError.noData
            }

            // Log response data for debugging (only if needed)
            // #if DEBUG
            // if let jsonString = String(data: data, encoding: .utf8) {
            //     print("📥 Response data: \(jsonString.prefix(200))...")
            // }
            // #endif

            // Decode response
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(T.self, from: data)

                // Cache successful response
                cache.setObject(NSData(data: data), forKey: cacheKey)

                return decodedResponse
            } catch let decodingError {
                #if DEBUG
                print("🚨 Decoding error for \(T.self): \(decodingError)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 Raw JSON that failed: \(jsonString)")
                }
                #endif
                throw NetworkError.decodingError(decodingError.localizedDescription)
            }

        } catch let urlError as URLError {
            // Handle specific URLError cases
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternetConnection
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.networkError(urlError.localizedDescription)
            }
        } catch let networkError as NetworkError {
            // Re-throw our custom errors
            #if DEBUG
            print("🚨 Network Error: \(networkError)")
            #endif
            throw networkError
        } catch {
            // Handle any other unexpected errors
            #if DEBUG
            print("🚨 Unexpected Error: \(error)")
            #endif
            throw NetworkError.networkError(error.localizedDescription)
        }
    }

    // MARK: - Cache Management

    /// Clears all cached network responses
    func clearCache() {
        cache.removeAllObjects()
    }

    /// Gets current cache usage statistics
    var cacheInfo: (count: Int, totalCost: Int) {
        return (count: cache.countLimit, totalCost: cache.totalCostLimit)
    }
}

// MARK: - Mock Network Service for Testing
/// Mock implementation for unit testing and previews
@MainActor
final class MockNetworkServiceInFile: NetworkServiceProtocol, @unchecked Sendable {
    var shouldThrowError = false
    var errorToThrow: NetworkError = .networkError("Mock error")

    func fetchMovieList() async throws -> MovieListResponse {
        if shouldThrowError { throw errorToThrow }
        return MovieListResponse(movies: Movie.sampleMovies)
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        if shouldThrowError { throw errorToThrow }
        return MovieDetails.sampleDetails
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> RecommendedMoviesResponse {
        if shouldThrowError { throw errorToThrow }
        return RecommendedMoviesResponse(movies: Movie.sampleMovies)
    }
}
