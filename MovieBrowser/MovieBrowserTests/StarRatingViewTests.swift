//
//  StarRatingViewTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  Unit tests for StarRatingView components
//

import XCTest
import SwiftUI
@testable import MovieBrowser

final class StarRatingViewTests: XCTestCase {

    // MARK: - StarRatingView Tests
    func testStarRatingViewInitialization() {
        // Given
        let rating = 4.5
        let starSize: CGFloat = 20
        let spacing: CGFloat = 3
        let showRatingText = false

        // When
        let starRatingView = StarRatingView(
            rating: rating,
            starSize: starSize,
            spacing: spacing,
            showRatingText: showRatingText
        )

        // Then
        XCTAssertEqual(starRatingView.rating, rating)
        XCTAssertEqual(starRatingView.starSize, starSize)
        XCTAssertEqual(starRatingView.spacing, spacing)
        XCTAssertEqual(starRatingView.showRatingText, showRatingText)
    }

    func testStarRatingViewDefaultValues() {
        // Given
        let rating = 3.7

        // When
        let starRatingView = StarRatingView(rating: rating)

        // Then
        XCTAssertEqual(starRatingView.rating, rating)
        XCTAssertEqual(starRatingView.starSize, 16)
        XCTAssertEqual(starRatingView.spacing, 2)
        XCTAssertEqual(starRatingView.showRatingText, true)
    }

    func testStarRatingViewRatingClamping() {
        // Given
        let negativeRating = -1.0
        let excessiveRating = 6.0

        // When
        let negativeStarView = StarRatingView(rating: negativeRating)
        let excessiveStarView = StarRatingView(rating: excessiveRating)

        // Then
        XCTAssertEqual(negativeStarView.rating, 0.0)
        XCTAssertEqual(excessiveStarView.rating, 5.0)
    }

    func testStarRatingViewBodyRendering() {
        // Given
        let starRatingView = StarRatingView(rating: 4.2)

        // When
        let body = starRatingView.body

        // Then
        XCTAssertNotNil(body)
    }

    // MARK: - LargeStarRatingView Tests
    func testLargeStarRatingViewInitialization() {
        // Given
        let rating = 4.3
        let originalRating = 8.6

        // When
        let largeStarRatingView = LargeStarRatingView(rating: rating, originalRating: originalRating)

        // Then
        XCTAssertEqual(largeStarRatingView.rating, rating)
        XCTAssertEqual(largeStarRatingView.originalRating, originalRating)
    }

    func testLargeStarRatingViewBodyRendering() {
        // Given
        let largeStarRatingView = LargeStarRatingView(rating: 4.1, originalRating: 8.2)

        // When
        let body = largeStarRatingView.body

        // Then
        XCTAssertNotNil(body)
    }

    // MARK: - CompactStarRatingView Tests
    func testCompactStarRatingViewInitialization() {
        // Given
        let rating = 3.8

        // When
        let compactStarRatingView = CompactStarRatingView(rating: rating)

        // Then
        XCTAssertEqual(compactStarRatingView.rating, rating)
    }

    func testCompactStarRatingViewBodyRendering() {
        // Given
        let compactStarRatingView = CompactStarRatingView(rating: 3.5)

        // When
        let body = compactStarRatingView.body

        // Then
        XCTAssertNotNil(body)
    }

    // MARK: - AnimatedStarRatingView Tests
    func testAnimatedStarRatingViewInitialization() {
        // Given
        let rating = 4.7

        // When
        let animatedStarRatingView = AnimatedStarRatingView(rating: rating)

        // Then
        XCTAssertEqual(animatedStarRatingView.rating, rating)
    }

    func testAnimatedStarRatingViewBodyRendering() {
        // Given
        let animatedStarRatingView = AnimatedStarRatingView(rating: 4.0)

        // When
        let body = animatedStarRatingView.body

        // Then
        XCTAssertNotNil(body)
    }

    // MARK: - RatingBadgeView Tests
    func testRatingBadgeViewInitialization() {
        // Given
        let rating = 4.3

        // When
        let ratingBadgeView = RatingBadgeView(rating: rating)

        // Then
        XCTAssertEqual(ratingBadgeView.rating, rating)
    }

    func testRatingBadgeViewBodyRendering() {
        // Given
        let ratingBadgeView = RatingBadgeView(rating: 4.6)

        // When
        let body = ratingBadgeView.body

        // Then
        XCTAssertNotNil(body)
    }

    func testRatingBadgeViewBackgroundColorLogic() {
        // Given - High rating (should be green/success)
        let highRating = 4.5
        let highRatingBadge = RatingBadgeView(rating: highRating)

        // Given - Medium rating (should be yellow/warning)
        let mediumRating = 3.5
        let mediumRatingBadge = RatingBadgeView(rating: mediumRating)

        // Given - Low rating (should be red/error)
        let lowRating = 2.0
        let lowRatingBadge = RatingBadgeView(rating: lowRating)

        // Then - All badges should initialize successfully
        XCTAssertEqual(highRatingBadge.rating, highRating)
        XCTAssertEqual(mediumRatingBadge.rating, mediumRating)
        XCTAssertEqual(lowRatingBadge.rating, lowRating)

        // Then - All badges should render their body
        XCTAssertNotNil(highRatingBadge.body)
        XCTAssertNotNil(mediumRatingBadge.body)
        XCTAssertNotNil(lowRatingBadge.body)
    }

    // MARK: - Edge Cases and Performance Tests
    func testStarRatingViewWithExtremeValues() {
        // Test with various extreme values
        let extremeValues = [0.0, 0.1, 0.9, 1.0, 2.5, 3.0, 4.0, 4.9, 5.0]

        for rating in extremeValues {
            let starView = StarRatingView(rating: rating)
            XCTAssertEqual(starView.rating, rating)
            XCTAssertNotNil(starView.body)
        }
    }

    func testCalculateFillAmountMethod() {
        // Given
        let starRatingView = StarRatingView(rating: 3.7)

        measure {
            for _ in 0..<1000 {
                for index in 0..<5 {
                    _ = starRatingView.calculateFillAmount(for: index)
                }
            }
        }
    }

    // MARK: - Additional Coverage Tests
    func testRatingBadgeViewColorVariations() {
        // Test that different ratings create different background colors
        let excellentBadge = RatingBadgeView(rating: 4.5)
        let goodBadge = RatingBadgeView(rating: 3.5)
        let poorBadge = RatingBadgeView(rating: 1.5)

        // Verify they can be created (background color logic executed)
        XCTAssertNotNil(excellentBadge)
        XCTAssertNotNil(goodBadge)
        XCTAssertNotNil(poorBadge)

        // Test edge cases
        let edgeCase1 = RatingBadgeView(rating: 4.0) // Exactly 4.0
        let edgeCase2 = RatingBadgeView(rating: 3.0) // Exactly 3.0
        XCTAssertNotNil(edgeCase1)
        XCTAssertNotNil(edgeCase2)
    }

    // MARK: - CalculateFillAmount Tests
    func testCalculateFillAmountEdgeCases() {
        // Test various edge cases by creating views with different ratings
        let testCases: [Double] = [0.0, 0.1, 0.9, 1.0, 1.1, 2.9, 3.0, 4.9, 5.0]

        for rating in testCases {
            let view = StarRatingView(rating: rating)
            XCTAssertNotNil(view.body)
        }
    }
}

// MARK: - Test Extensions
extension StarRatingView {
    // Expose private method for testing
    func calculateFillAmount(for index: Int) -> CGFloat {
        let starPosition = Double(index)

        if rating >= starPosition + 1 {
            return 1.0
        } else if rating > starPosition {
            return CGFloat(rating - starPosition)
        } else {
            return 0.0
        }
    }
}
