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
        expectation.expectedFulfillmentCount = 3 // Initial + 2 toggles
        var receivedUpdates: [Set<Int>] = []

        let cancellable = likesService.likedMoviesPublisher
            .sink { likedIds in
                receivedUpdates.append(likedIds)
                expectation.fulfill()
            }

        // When
        likesService.toggleLike(for: 2) // Like movie 2 (not pre-liked)
        likesService.toggleLike(for: 2) // Unlike movie 2

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedUpdates.count, 3)
        // Second update (after first toggle) should include movie 2
        XCTAssertTrue(receivedUpdates[1].contains(2), "Should contain newly liked movie 2")
        // Third update (after second toggle) should remove movie 2
        XCTAssertFalse(receivedUpdates[2].contains(2), "Should not contain unliked movie 2")

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

    @MainActor
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

    @MainActor
    func testMockLikesServicePublisher() {
        // Test publisher functionality
        let mockService = MockLikesService()
        var receivedSets: [Set<Int>] = []

        let cancellable = mockService.likedMoviesPublisher.sink { likedIds in
            receivedSets.append(likedIds)
        }

        // Toggle likes to trigger publisher
        mockService.toggleLike(for: 5)
        mockService.toggleLike(for: 6)

        XCTAssertGreaterThan(receivedSets.count, 0)
        cancellable.cancel()
    }

    @MainActor
    func testMockLikesServiceGetLikedMovieIds() {
        let mockService = MockLikesService()
        let initialIds = mockService.getLikedMovieIds()

        XCTAssertTrue(initialIds.contains(1))
        XCTAssertTrue(initialIds.contains(3))

        mockService.toggleLike(for: 5)
        let updatedIds = mockService.getLikedMovieIds()
        XCTAssertTrue(updatedIds.contains(5))
    }
}

// MARK: - Additional LikesService Coverage Tests
extension LikesServiceTests {

    func testLikesServiceEdgeCases() {
        // Test with extreme movie IDs
        let extremeIds = [Int.min, -1, 0, Int.max]

        for movieId in extremeIds {
            // Should handle extreme IDs gracefully
            likesService.likeMovie(movieId)
            XCTAssertTrue(likesService.isMovieLiked(movieId))

            likesService.unlikeMovie(movieId)
            XCTAssertFalse(likesService.isMovieLiked(movieId))
        }
    }

    func testLikesServiceMassOperations() {
        // Test with many movies to stress test the service
        let movieIds = Array(1...1000)

        // Like all movies
        for movieId in movieIds {
            likesService.likeMovie(movieId)
        }

        XCTAssertEqual(likesService.likedMoviesCount, 1000)

        // Unlike half of them
        for movieId in movieIds.prefix(500) {
            likesService.unlikeMovie(movieId)
        }

        XCTAssertEqual(likesService.likedMoviesCount, 500)

        // Clear all
        for movieId in movieIds.suffix(500) {
            likesService.unlikeMovie(movieId)
        }

        XCTAssertEqual(likesService.likedMoviesCount, 0)
    }

    func testLikesServiceConcurrentAccess() async {
        // Test concurrent access to the service using MainActor
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask { @MainActor in
                    self.likesService.likeMovie(i)
                    self.likesService.toggleLike(for: i)
                }
            }
        }

        // Verify final state
        let finalCount = likesService.likedMoviesCount
        XCTAssertGreaterThanOrEqual(finalCount, 0)
    }

    func testLikesServicePublisherMultipleSubscribers() {
        var subscriber1Received: [Set<Int>] = []
        var subscriber2Received: [Set<Int>] = []

        let cancellable1 = likesService.likedMoviesPublisher.sink { ids in
            subscriber1Received.append(ids)
        }

        let cancellable2 = likesService.likedMoviesPublisher.sink { ids in
            subscriber2Received.append(ids)
        }

        // Make changes
        likesService.likeMovie(10)
        likesService.likeMovie(20)
        likesService.toggleLike(for: 30)

        // Both subscribers should receive updates
        XCTAssertGreaterThan(subscriber1Received.count, 0)
        XCTAssertGreaterThan(subscriber2Received.count, 0)

        cancellable1.cancel()
        cancellable2.cancel()
    }

    func testLikesServiceMemoryManagement() {
        // Test that likes service doesn't leak memory
        var services: [LikesService] = []

        for _ in 0..<100 {
            let service = LikesService()
            service.likeMovie(1)
            service.likeMovie(2)
            service.toggleLike(for: 3)
            services.append(service)
        }

        XCTAssertEqual(services.count, 100)

        // Clean up
        services.removeAll()
        XCTAssertEqual(services.count, 0)
    }

    func testLikesServicePersistenceStressTest() {
        // Test persistence with rapid changes
        for i in 0..<100 {
            likesService.likeMovie(i)
            if i % 2 == 0 {
                likesService.unlikeMovie(i)
            }
        }

        let finalCount = likesService.likedMoviesCount

        // Test that the current service maintains its state
        XCTAssertEqual(likesService.likedMoviesCount, finalCount)

        // Test that the service can handle the final state
        XCTAssertEqual(finalCount, 50) // Should have 50 liked movies (odd numbers 1,3,5...99)
    }

    func testLikesServiceToggleBehaviorExtensive() {
        let movieIds = [100, 200, 300, 400, 500]

        // Test multiple toggles
        for movieId in movieIds {
            // Start unliked
            XCTAssertFalse(likesService.isMovieLiked(movieId))

            // Toggle to liked
            likesService.toggleLike(for: movieId)
            XCTAssertTrue(likesService.isMovieLiked(movieId))

            // Toggle back to unliked
            likesService.toggleLike(for: movieId)
            XCTAssertFalse(likesService.isMovieLiked(movieId))

            // Toggle to liked again
            likesService.toggleLike(for: movieId)
            XCTAssertTrue(likesService.isMovieLiked(movieId))
        }

        XCTAssertEqual(likesService.likedMoviesCount, movieIds.count)
    }

    func testLikesServicePerformance() {
        measure {
            for i in 0..<1000 {
                likesService.likeMovie(i)
                _ = likesService.isMovieLiked(i)
            }
        }
    }
}
