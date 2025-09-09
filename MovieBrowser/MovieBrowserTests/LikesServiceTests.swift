//
//  LikesServiceTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Likes Service Tests
//

import XCTest
@testable import MovieBrowser

// MARK: - Likes Service Tests
/// Comprehensive tests for the LikesService class
@MainActor
final class LikesServiceTests: XCTestCase {

    // MARK: - Properties
    var likesService: LikesService!
    var mockUserDefaults: UserDefaults!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        // Use a test suite name to avoid conflicts with app data
        mockUserDefaults = UserDefaults(suiteName: "MovieBrowserTests")!
        mockUserDefaults.removePersistentDomain(forName: "MovieBrowserTests")
        likesService = LikesService(userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "MovieBrowserTests")
        likesService = nil
        mockUserDefaults = nil
        super.tearDown()
    }

    // MARK: - Basic Functionality Tests
    func testInitialState() {
        // Given & When - fresh service

        // Then
        XCTAssertEqual(likesService.likedMoviesCount, 0)
        XCTAssertTrue(likesService.getLikedMovieIds().isEmpty)
        XCTAssertFalse(likesService.isMovieLiked(1))
    }

    func testToggleLikeFromUnliked() {
        // Given
        let movieId = 1
        XCTAssertFalse(likesService.isMovieLiked(movieId))

        // When
        likesService.toggleLike(for: movieId)

        // Then
        XCTAssertTrue(likesService.isMovieLiked(movieId))
        XCTAssertEqual(likesService.likedMoviesCount, 1)
        XCTAssertTrue(likesService.getLikedMovieIds().contains(movieId))
    }

    func testToggleLikeFromLiked() {
        // Given
        let movieId = 1
        likesService.toggleLike(for: movieId) // Like it first
        XCTAssertTrue(likesService.isMovieLiked(movieId))

        // When
        likesService.toggleLike(for: movieId) // Unlike it

        // Then
        XCTAssertFalse(likesService.isMovieLiked(movieId))
        XCTAssertEqual(likesService.likedMoviesCount, 0)
        XCTAssertFalse(likesService.getLikedMovieIds().contains(movieId))
    }

    func testLikeMovie() {
        // Given
        let movieId = 5
        XCTAssertFalse(likesService.isMovieLiked(movieId))

        // When
        likesService.likeMovie(movieId)

        // Then
        XCTAssertTrue(likesService.isMovieLiked(movieId))
        XCTAssertEqual(likesService.likedMoviesCount, 1)
    }

    func testLikeAlreadyLikedMovie() {
        // Given
        let movieId = 5
        likesService.likeMovie(movieId)
        let initialCount = likesService.likedMoviesCount

        // When
        likesService.likeMovie(movieId) // Like again

        // Then
        XCTAssertTrue(likesService.isMovieLiked(movieId))
        XCTAssertEqual(likesService.likedMoviesCount, initialCount) // Count shouldn't change
    }

    func testUnlikeMovie() {
        // Given
        let movieId = 3
        likesService.likeMovie(movieId)
        XCTAssertTrue(likesService.isMovieLiked(movieId))

        // When
        likesService.unlikeMovie(movieId)

        // Then
        XCTAssertFalse(likesService.isMovieLiked(movieId))
        XCTAssertEqual(likesService.likedMoviesCount, 0)
    }

    func testUnlikeNotLikedMovie() {
        // Given
        let movieId = 3
        XCTAssertFalse(likesService.isMovieLiked(movieId))

        // When
        likesService.unlikeMovie(movieId)

        // Then
        XCTAssertFalse(likesService.isMovieLiked(movieId))
        XCTAssertEqual(likesService.likedMoviesCount, 0)
    }

    // MARK: - Multiple Movies Tests
    func testMultipleLikes() {
        // Given
        let movieIds = [1, 2, 3, 4, 5]

        // When
        for movieId in movieIds {
            likesService.likeMovie(movieId)
        }

        // Then
        XCTAssertEqual(likesService.likedMoviesCount, movieIds.count)
        for movieId in movieIds {
            XCTAssertTrue(likesService.isMovieLiked(movieId))
        }

        let likedIds = likesService.getLikedMovieIds()
        XCTAssertEqual(likedIds.count, movieIds.count)
        for movieId in movieIds {
            XCTAssertTrue(likedIds.contains(movieId))
        }
    }

    func testClearAllLikes() {
        // Given
        let movieIds = [1, 2, 3]
        for movieId in movieIds {
            likesService.likeMovie(movieId)
        }
        XCTAssertEqual(likesService.likedMoviesCount, 3)

        // When
        likesService.clearAllLikes()

        // Then
        XCTAssertEqual(likesService.likedMoviesCount, 0)
        XCTAssertTrue(likesService.getLikedMovieIds().isEmpty)
        for movieId in movieIds {
            XCTAssertFalse(likesService.isMovieLiked(movieId))
        }
    }

    // MARK: - Persistence Tests
    func testPersistence() {
        // Given
        let movieId = 42
        likesService.likeMovie(movieId)
        XCTAssertTrue(likesService.isMovieLiked(movieId))

        // When - create new service instance (simulates app restart)
        let newLikesService = LikesService(userDefaults: mockUserDefaults)

        // Then - data should be persisted
        XCTAssertTrue(newLikesService.isMovieLiked(movieId))
        XCTAssertEqual(newLikesService.likedMoviesCount, 1)
    }

    func testPersistenceWithMultipleMovies() {
        // Given
        let movieIds = [10, 20, 30]
        for movieId in movieIds {
            likesService.likeMovie(movieId)
        }

        // When - create new service instance
        let newLikesService = LikesService(userDefaults: mockUserDefaults)

        // Then
        XCTAssertEqual(newLikesService.likedMoviesCount, movieIds.count)
        for movieId in movieIds {
            XCTAssertTrue(newLikesService.isMovieLiked(movieId))
        }
    }

    // MARK: - Publisher Tests
    @MainActor
    func testLikedMoviesPublisher() async {
        // Given
        let expectation = XCTestExpectation(description: "Publisher emits liked movies")
        var receivedLikedIds: Set<Int>?

        let cancellable = likesService.likedMoviesPublisher
            .sink { likedIds in
                receivedLikedIds = likedIds
                expectation.fulfill()
            }

        // When
        likesService.likeMovie(1)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedLikedIds, Set([1]))

        cancellable.cancel()
    }

    @MainActor
    func testPublisherUpdatesOnToggle() async {
        // Given
        let expectation = XCTestExpectation(description: "Publisher updates on toggle")
        expectation.expectedFulfillmentCount = 2
        var receivedUpdates: [Set<Int>] = []

        let cancellable = likesService.likedMoviesPublisher
            .sink { likedIds in
                receivedUpdates.append(likedIds)
                expectation.fulfill()
            }

        // When
        likesService.toggleLike(for: 1) // Like
        likesService.toggleLike(for: 1) // Unlike

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedUpdates.count, 2)
        XCTAssertEqual(receivedUpdates[0], Set([1])) // After like
        XCTAssertEqual(receivedUpdates[1], Set()) // After unlike

        cancellable.cancel()
    }

    // MARK: - Edge Cases Tests
    func testNegativeMovieId() {
        // Given
        let negativeId = -1

        // When & Then - should handle gracefully
        likesService.toggleLike(for: negativeId)
        XCTAssertTrue(likesService.isMovieLiked(negativeId))

        likesService.toggleLike(for: negativeId)
        XCTAssertFalse(likesService.isMovieLiked(negativeId))
    }

    func testZeroMovieId() {
        // Given
        let zeroId = 0

        // When & Then - should handle gracefully
        likesService.likeMovie(zeroId)
        XCTAssertTrue(likesService.isMovieLiked(zeroId))
        XCTAssertEqual(likesService.likedMoviesCount, 1)
    }

    func testLargeMovieId() {
        // Given
        let largeId = Int.max

        // When & Then - should handle gracefully
        likesService.likeMovie(largeId)
        XCTAssertTrue(likesService.isMovieLiked(largeId))
        XCTAssertEqual(likesService.likedMoviesCount, 1)
    }
}

// MARK: - Mock Likes Service Tests
final class MockLikesServiceTests: XCTestCase {

    func testMockLikesService() {
        // Given
        let mockService = MockLikesService()

        // When & Then - test mock behavior
        XCTAssertTrue(mockService.isMovieLiked(1)) // Pre-populated
        XCTAssertTrue(mockService.isMovieLiked(3)) // Pre-populated
        XCTAssertFalse(mockService.isMovieLiked(2)) // Not pre-populated

        // Test toggle
        mockService.toggleLike(for: 2)
        XCTAssertTrue(mockService.isMovieLiked(2))

        mockService.toggleLike(for: 1)
        XCTAssertFalse(mockService.isMovieLiked(1))
    }
}
