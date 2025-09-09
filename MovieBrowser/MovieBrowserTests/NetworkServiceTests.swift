//
//  NetworkServiceTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Network Service Tests
//

import XCTest
@testable import MovieBrowser

// MARK: - Network Service Tests
/// Comprehensive tests for the NetworkService class
final class NetworkServiceTests: XCTestCase {

    // MARK: - Properties
    var networkService: NetworkService!
    var mockURLSession: MockURLSession!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        networkService = NetworkService(session: mockURLSession)
    }

    override func tearDown() {
        networkService = nil
        mockURLSession = nil
        super.tearDown()
    }

    // MARK: - Movie List Tests
    @MainActor
    func testFetchMovieListSuccess() async throws {
        // Given
        let expectedMovies = [
            Movie(id: 1, name: "Test Movie", thumbnail: "https://example.com/1.jpg", year: 2023)
        ]
        let responseData = try JSONEncoder().encode(MovieListResponse(movies: expectedMovies))
        mockURLSession.mockData = responseData
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result = try await networkService.fetchMovieList()

        // Then
        XCTAssertEqual(result.movies.count, 1)
        XCTAssertEqual(result.movies.first?.name, "Test Movie")
        XCTAssertEqual(result.movies.first?.id, 1)
    }

    @MainActor
    func testFetchMovieListNetworkError() async {
        // Given
        mockURLSession.mockError = URLError(.notConnectedToInternet)

        // When & Then
        do {
            _ = try await networkService.fetchMovieList()
            XCTFail("Expected network error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noInternetConnection)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    @MainActor
    func testFetchMovieListServerError() async {
        // Given
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        mockURLSession.mockData = Data()

        // When & Then
        do {
            _ = try await networkService.fetchMovieList()
            XCTFail("Expected server error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .serverError(500))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    @MainActor
    func testFetchMovieListInvalidJSON() async {
        // Given
        mockURLSession.mockData = "Invalid JSON".data(using: .utf8)!
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When & Then
        do {
            _ = try await networkService.fetchMovieList()
            XCTFail("Expected decoding error")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Success - expected decoding error
            } else {
                XCTFail("Expected decoding error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Movie Details Tests
    @MainActor
    func testFetchMovieDetailsSuccess() async throws {
        // Given
        let expectedDetails = MovieDetails(
            id: 1,
            name: "Test Movie",
            description: "Test Description",
            notes: "Test Notes",
            rating: 8.5,
            picture: "https://example.com/1.jpg",
            releaseDate: 1556236800
        )
        let responseData = try JSONEncoder().encode(expectedDetails)
        mockURLSession.mockData = responseData
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result = try await networkService.fetchMovieDetails(id: 1)

        // Then
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.name, "Test Movie")
        XCTAssertEqual(result.description, "Test Description")
        XCTAssertEqual(result.rating, 8.5)
    }

    @MainActor
    func testFetchMovieDetailsNotFound() async {
        // Given
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        mockURLSession.mockData = Data()

        // When & Then
        do {
            _ = try await networkService.fetchMovieDetails(id: 999)
            XCTFail("Expected server error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .serverError(404))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Recommended Movies Tests
    @MainActor
    func testFetchRecommendedMoviesSuccess() async throws {
        // Given
        let expectedMovies = [
            Movie(id: 2, name: "Recommended Movie", thumbnail: "https://example.com/2.jpg", year: 2022)
        ]
        let responseData = try JSONEncoder().encode(RecommendedMoviesResponse(movies: expectedMovies))
        mockURLSession.mockData = responseData
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result = try await networkService.fetchRecommendedMovies(for: 1)

        // Then
        XCTAssertEqual(result.movies.count, 1)
        XCTAssertEqual(result.movies.first?.name, "Recommended Movie")
        XCTAssertEqual(result.movies.first?.id, 2)
    }

    // MARK: - Cache Tests
    func testCacheClearing() {
        // Given
        let initialCacheInfo = networkService.cacheInfo

        // When
        networkService.clearCache()

        // Then
        // We can't directly test cache contents, but we can verify the method doesn't crash
        XCTAssertNotNil(networkService.cacheInfo)
    }
}

// MARK: - Mock URL Session
class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }

        let data = mockData ?? Data()
        let response = mockResponse ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        return (data, response)
    }
}

// MARK: - Network Error Tests
final class NetworkErrorTests: XCTestCase {

    func testNetworkErrorEquality() {
        // Test that NetworkError cases are properly equatable
        XCTAssertEqual(NetworkError.invalidURL, NetworkError.invalidURL)
        XCTAssertEqual(NetworkError.noData, NetworkError.noData)
        XCTAssertEqual(NetworkError.serverError(404), NetworkError.serverError(404))
        XCTAssertNotEqual(NetworkError.serverError(404), NetworkError.serverError(500))
    }

    func testNetworkErrorDescriptions() {
        // Test that error descriptions are user-friendly
        XCTAssertFalse(NetworkError.invalidURL.localizedDescription.isEmpty)
        XCTAssertFalse(NetworkError.noInternetConnection.localizedDescription.isEmpty)
        XCTAssertFalse(NetworkError.timeout.localizedDescription.isEmpty)

        // Test recovery suggestions
        XCTAssertNotNil(NetworkError.noInternetConnection.recoverySuggestion)
        XCTAssertNotNil(NetworkError.timeout.recoverySuggestion)
    }
}
