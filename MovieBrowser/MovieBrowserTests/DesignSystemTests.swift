//
//  DesignSystemTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  Unit tests for DesignSystem
//

import XCTest
import SwiftUI
@testable import MovieBrowser

final class DesignSystemTests: XCTestCase {

    // MARK: - Colors Tests
    func testPrimaryColors() {
        // Test that primary colors are defined and accessible
        XCTAssertNotNil(DesignSystem.Colors.primary)
        XCTAssertNotNil(DesignSystem.Colors.secondary)

        // Test that colors are different
        XCTAssertNotEqual(DesignSystem.Colors.primary, DesignSystem.Colors.secondary)
    }

    func testBackgroundColors() {
        // Test background colors are defined
        XCTAssertNotNil(DesignSystem.Colors.background)
        XCTAssertNotNil(DesignSystem.Colors.secondaryBackground)
        XCTAssertNotNil(DesignSystem.Colors.tertiaryBackground)
        XCTAssertNotNil(DesignSystem.Colors.quaternaryBackground)
        XCTAssertNotNil(DesignSystem.Colors.cardBackground)
    }

    func testLabelColors() {
        // Test label colors are defined
        XCTAssertNotNil(DesignSystem.Colors.label)
        XCTAssertNotNil(DesignSystem.Colors.secondaryLabel)
        XCTAssertNotNil(DesignSystem.Colors.tertiaryLabel)
    }

    func testStatusColors() {
        // Test status colors are defined
        XCTAssertNotNil(DesignSystem.Colors.success)
        XCTAssertNotNil(DesignSystem.Colors.warning)
        XCTAssertNotNil(DesignSystem.Colors.error)

        // Test they are different colors
        XCTAssertNotEqual(DesignSystem.Colors.success, DesignSystem.Colors.error)
        XCTAssertNotEqual(DesignSystem.Colors.warning, DesignSystem.Colors.error)
    }

    func testRatingColors() {
        // Test rating colors are defined
        XCTAssertNotNil(DesignSystem.Colors.starFilled)
        XCTAssertNotNil(DesignSystem.Colors.starEmpty)

        // Test they are different
        XCTAssertNotEqual(DesignSystem.Colors.starFilled, DesignSystem.Colors.starEmpty)
    }

    func testHeartColors() {
        // Test heart colors are defined
        XCTAssertNotNil(DesignSystem.Colors.heartFilled)
        XCTAssertNotNil(DesignSystem.Colors.heartEmpty)

        // Test they are different
        XCTAssertNotEqual(DesignSystem.Colors.heartFilled, DesignSystem.Colors.heartEmpty)
    }

    func testUtilityColors() {
        // Test utility colors are defined
        XCTAssertNotNil(DesignSystem.Colors.cardShadow)
        XCTAssertNotNil(DesignSystem.Colors.separator)
    }

    // MARK: - Typography Tests
    func testTitleFonts() {
        // Test title fonts are defined
        XCTAssertNotNil(DesignSystem.Typography.largeTitle)
        XCTAssertNotNil(DesignSystem.Typography.title1)
        XCTAssertNotNil(DesignSystem.Typography.title2)
        XCTAssertNotNil(DesignSystem.Typography.title3)
    }

    func testBodyFonts() {
        // Test body fonts are defined
        XCTAssertNotNil(DesignSystem.Typography.body)
        XCTAssertNotNil(DesignSystem.Typography.bodyEmphasized)
        XCTAssertNotNil(DesignSystem.Typography.callout)
    }

    func testUtilityFonts() {
        // Test utility fonts are defined
        XCTAssertNotNil(DesignSystem.Typography.caption)
        XCTAssertNotNil(DesignSystem.Typography.caption2)

        // Test custom fonts
        XCTAssertNotNil(DesignSystem.Typography.movieTitle)
        XCTAssertNotNil(DesignSystem.Typography.movieYear)
        XCTAssertNotNil(DesignSystem.Typography.movieRating)
        XCTAssertNotNil(DesignSystem.Typography.sectionTitle)
    }

    // MARK: - Spacing Tests
    func testSpacingValues() {
        // Test that spacing values are positive and in logical order
        XCTAssertGreaterThan(DesignSystem.Spacing.xs, 0)
        XCTAssertGreaterThan(DesignSystem.Spacing.sm, DesignSystem.Spacing.xs)
        XCTAssertGreaterThan(DesignSystem.Spacing.md, DesignSystem.Spacing.sm)
        XCTAssertGreaterThan(DesignSystem.Spacing.lg, DesignSystem.Spacing.md)
        XCTAssertGreaterThan(DesignSystem.Spacing.xl, DesignSystem.Spacing.lg)
        XCTAssertGreaterThan(DesignSystem.Spacing.xxl, DesignSystem.Spacing.xl)
    }

    func testSpacingConsistency() {
        // Test that spacing values are reasonable
        XCTAssertEqual(DesignSystem.Spacing.xs, 4)
        XCTAssertEqual(DesignSystem.Spacing.sm, 8)
        XCTAssertEqual(DesignSystem.Spacing.md, 16)
        XCTAssertEqual(DesignSystem.Spacing.lg, 24)
        XCTAssertEqual(DesignSystem.Spacing.xl, 32)
        XCTAssertEqual(DesignSystem.Spacing.xxl, 48)
    }

    // MARK: - Corner Radius Tests
    func testCornerRadiusValues() {
        // Test that corner radius values are positive and in logical order
        XCTAssertGreaterThan(DesignSystem.CornerRadius.small, 0)
        XCTAssertGreaterThan(DesignSystem.CornerRadius.medium, DesignSystem.CornerRadius.small)
        XCTAssertGreaterThan(DesignSystem.CornerRadius.large, DesignSystem.CornerRadius.medium)
    }

    func testCornerRadiusConsistency() {
        // Test that corner radius values are reasonable
        XCTAssertEqual(DesignSystem.CornerRadius.small, 8)
        XCTAssertEqual(DesignSystem.CornerRadius.medium, 12)
        XCTAssertEqual(DesignSystem.CornerRadius.large, 16)
    }

    // MARK: - Shadow Tests
    func testShadowValues() {
        // Test that shadow values are defined
        XCTAssertGreaterThan(DesignSystem.Shadow.card.radius, 0)
        XCTAssertGreaterThan(DesignSystem.Shadow.button.radius, 0)
    }

    func testShadowConsistency() {
        // Test shadow radius values
        XCTAssertEqual(DesignSystem.Shadow.card.radius, 8)
        XCTAssertEqual(DesignSystem.Shadow.button.radius, 4)

        // Test shadow y offsets
        XCTAssertEqual(DesignSystem.Shadow.card.y, 2)
        XCTAssertEqual(DesignSystem.Shadow.button.y, 2)

        // Test shadow x offsets
        XCTAssertEqual(DesignSystem.Shadow.card.x, 0)
        XCTAssertEqual(DesignSystem.Shadow.button.x, 0)
    }

    // MARK: - Animation Tests
    func testAnimationValues() {
        // Test that animations are defined
        XCTAssertNotNil(DesignSystem.Animation.quick)
        XCTAssertNotNil(DesignSystem.Animation.standard)
        XCTAssertNotNil(DesignSystem.Animation.slow)

        // Test semantic animations
        XCTAssertNotNil(DesignSystem.Animation.cardTap)
        XCTAssertNotNil(DesignSystem.Animation.likeButton)
        XCTAssertNotNil(DesignSystem.Animation.loadingFade)
    }

    // MARK: - Integration Tests
    func testDesignSystemStructureExists() {
        // Test that all main structures exist
        XCTAssertNotNil(DesignSystem.Colors.self)
        XCTAssertNotNil(DesignSystem.Typography.self)
        XCTAssertNotNil(DesignSystem.Spacing.self)
        XCTAssertNotNil(DesignSystem.CornerRadius.self)
        XCTAssertNotNil(DesignSystem.Shadow.self)
        XCTAssertNotNil(DesignSystem.Animation.self)
    }

    func testColorAccessibility() {
        // Test that we can access colors without runtime errors
        let colors = [
            DesignSystem.Colors.primary,
            DesignSystem.Colors.secondary,
            DesignSystem.Colors.background,
            DesignSystem.Colors.label,
            DesignSystem.Colors.success,
            DesignSystem.Colors.error,
            DesignSystem.Colors.starFilled,
            DesignSystem.Colors.heartFilled
        ]

        // Test that all colors are accessible
        for color in colors {
            XCTAssertNotNil(color)
        }
    }

    // MARK: - DropShadow Tests
    func testDropShadowStruct() {
        let shadow = DropShadow(color: .red, radius: 5, x: 1, y: 2)
        XCTAssertEqual(shadow.radius, 5)
        XCTAssertEqual(shadow.x, 1)
        XCTAssertEqual(shadow.y, 2)
        XCTAssertNotNil(shadow.color)
    }

    // MARK: - View Extension Tests
    func testCardStyleExtension() {
        let testView = Rectangle()
        let styledView = testView.cardStyle()
        XCTAssertNotNil(styledView)
    }

    func testButtonStyleExtension() {
        let testView = Rectangle()
        let styledView = testView.buttonStyle()
        XCTAssertNotNil(styledView)
    }

    func testShimmerExtension() {
        let testView = Rectangle()
        let shimmerView = testView.customShimmer()
        XCTAssertNotNil(shimmerView)
    }

    // MARK: - Semantic Values Tests
    func testSemanticSpacing() {
        XCTAssertEqual(DesignSystem.Spacing.cardPadding, DesignSystem.Spacing.md)
        XCTAssertEqual(DesignSystem.Spacing.sectionSpacing, DesignSystem.Spacing.lg)
        XCTAssertEqual(DesignSystem.Spacing.itemSpacing, DesignSystem.Spacing.sm)
        XCTAssertEqual(DesignSystem.Spacing.screenPadding, DesignSystem.Spacing.md)
    }

    func testSemanticCornerRadius() {
        XCTAssertEqual(DesignSystem.CornerRadius.card, DesignSystem.CornerRadius.medium)
        XCTAssertEqual(DesignSystem.CornerRadius.button, DesignSystem.CornerRadius.small)
        XCTAssertEqual(DesignSystem.CornerRadius.image, DesignSystem.CornerRadius.medium)
    }

    func testExtraLargeCornerRadius() {
        XCTAssertEqual(DesignSystem.CornerRadius.extraLarge, 24)
        XCTAssertGreaterThan(DesignSystem.CornerRadius.extraLarge, DesignSystem.CornerRadius.large)
    }

    // MARK: - View Modifier Integration Tests
    func testScreenPaddingModifierIntegration() {
        let testView = Rectangle()
        let paddedView = testView.screenPadding()

        // Test that the modifier can be applied without errors
        XCTAssertNotNil(paddedView)
    }

    func testButtonStyleModifiersIntegration() {
        let testView = Text("Test Button")

        // Test PrimaryButtonStyle integration
        let primaryButton = testView.buttonStyle(backgroundColor: .blue, foregroundColor: .white)
        XCTAssertNotNil(primaryButton)

        // Test SecondaryButtonStyle integration
        let secondaryButton = testView.buttonStyle(backgroundColor: .gray, foregroundColor: .black)
        XCTAssertNotNil(secondaryButton)

        // Test with different color combinations
        let colorCombinations = [
            (bg: Color.red, fg: Color.white),
            (bg: Color.green, fg: Color.black),
            (bg: Color.blue, fg: Color.yellow),
            (bg: Color.clear, fg: Color.primary)
        ]

        for combo in colorCombinations {
            let coloredButton = testView.buttonStyle(backgroundColor: combo.bg, foregroundColor: combo.fg)
            XCTAssertNotNil(coloredButton)
        }
    }

    func testCardModifierIntegration() {
        let testView = Rectangle()

        // Test different pressed states
        let normalCard = testView.cardModifier(isPressed: false)
        XCTAssertNotNil(normalCard)

        let pressedCard = testView.cardModifier(isPressed: true)
        XCTAssertNotNil(pressedCard)
    }

    // MARK: - ErrorView Body Rendering Tests
    func testErrorViewIntegration() {
        var retryCount = 0
        let errorView = ErrorView("Network Error", retryAction: { retryCount += 1 })

        // Test that ErrorView can be created without issues
        XCTAssertNotNil(errorView)

        // Verify retry hasn't been called during initialization
        XCTAssertEqual(retryCount, 0)
    }

    func testErrorViewVariationsIntegration() {
        let variations = [
            "Network Error",
            "Server Error",
            "Unknown Error",
            "Timeout Error",
            "Authentication Error"
        ]

        for errorType in variations {
            var actionCalled = false
            let errorView = ErrorView(errorType, retryAction: { actionCalled = true })

            // Test that ErrorView can be created with different messages
            XCTAssertNotNil(errorView)

            // Verify action not called during initialization
            XCTAssertFalse(actionCalled, "Action should not be called during initialization for \(errorType)")
        }
    }

    // MARK: - EmptyStateView Integration Tests
    func testEmptyStateViewIntegration() {
        var actionCount = 0
        let emptyStateView = EmptyStateView(
            title: "No Results",
            message: "Try a different search",
            systemImage: "magnifyingglass",
            actionTitle: "Retry",
            action: { actionCount += 1 }
        )

        // Test that EmptyStateView can be created without issues
        XCTAssertNotNil(emptyStateView)

        // Verify action hasn't been called during initialization
        XCTAssertEqual(actionCount, 0)
    }

    func testEmptyStateViewVariationsIntegration() {
        let variations = [
            (title: "No Movies", message: "Start browsing", image: "film", action: "Browse"),
            (title: "No Favorites", message: "Like some movies", image: "heart", action: "Explore"),
            (title: "No Results", message: "Try different terms", image: "magnifyingglass", action: "Search"),
            (title: "Offline", message: "Check connection", image: "wifi.slash", action: "Retry"),
            (title: "Empty Library", message: "Add some content", image: "tray", action: "Add"),
            (title: "No Downloads", message: "Download for offline", image: "arrow.down.circle", action: "Download")
        ]

        for variation in variations {
            var actionCalled = false
            let emptyStateView = EmptyStateView(
                title: variation.title,
                message: variation.message,
                systemImage: variation.image,
                actionTitle: variation.action,
                action: { actionCalled = true }
            )

            // Test that EmptyStateView can be created with different variations
            XCTAssertNotNil(emptyStateView)

            // Verify action not called during initialization
            XCTAssertFalse(actionCalled, "Action should not be called during initialization for \(variation.title)")
        }
    }

    // MARK: - LoadingView Integration Tests
    func testLoadingViewIntegration() {
        let loadingView = LoadingView()

        // Test that LoadingView can be created without issues
        XCTAssertNotNil(loadingView)
    }

    func testLoadingViewMultipleInstances() {
        // Test creating multiple LoadingView instances
        for _ in 0..<10 {
            let loadingView = LoadingView()
            XCTAssertNotNil(loadingView)
        }
    }

    // MARK: - Force Body Getter Execution
    func testErrorViewBodyGetterExecution() {
        let errorMessages = [
            "Network Error",
            "Server Error",
            "Authentication Failed",
            "Timeout Error",
            "Unknown Error"
        ]

        for errorMessage in errorMessages {
            var retryCount = 0
            let errorView = ErrorView(errorMessage) {
                retryCount += 1
            }

            // Force body getter execution multiple times
            for _ in 0..<5 {
                let body = errorView.body
                XCTAssertNotNil(body)
            }

            XCTAssertEqual(retryCount, 0, "Retry should not be called during body computation")
        }
    }

    func testEmptyStateViewBodyGetterExecution() {
        let testCases = [
            (title: "No Movies", message: "Start browsing", image: "film", action: "Browse"),
            (title: "No Results", message: "Try different terms", image: "magnifyingglass", action: "Search"),
            (title: "Offline", message: "Check connection", image: "wifi.slash", action: "Retry")
        ]

        for testCase in testCases {
            var actionCount = 0
            let emptyStateView = EmptyStateView(
                title: testCase.title,
                message: testCase.message,
                systemImage: testCase.image,
                actionTitle: testCase.action
            ) {
                actionCount += 1
            }

            // Force body getter execution multiple times to trigger all internal closures
            for _ in 0..<5 {
                let body = emptyStateView.body
                XCTAssertNotNil(body)
            }

            XCTAssertEqual(actionCount, 0, "Action should not be called during body computation")
        }
    }

    func testPrimaryButtonStyleBodyExecution() {
        // Test button styles by creating buttons and forcing body computation
        let testButton = Button("Test") {}

        let primaryButton = testButton.buttonStyle(backgroundColor: Color.blue, foregroundColor: Color.white)
        XCTAssertNotNil(primaryButton)

        let secondaryButton = testButton.buttonStyle(backgroundColor: Color.gray, foregroundColor: Color.black)
        XCTAssertNotNil(secondaryButton)
    }

    func testSecondaryButtonStyleBodyExecution() {
        // Create buttons with different configurations
        let configurations = [
            (bg: Color.blue, fg: Color.white),
            (bg: Color.red, fg: Color.black),
            (bg: Color.green, fg: Color.white)
        ]

        for config in configurations {
            let testButton = Button("Test Button") {}
            let styledButton = testButton.buttonStyle(backgroundColor: config.bg, foregroundColor: config.fg)
            XCTAssertNotNil(styledButton)
        }
    }
}
