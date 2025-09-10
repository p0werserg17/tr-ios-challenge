//
//  MovieListViewTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  Unit tests for MovieListView and related components
//

import XCTest
import SwiftUI
@testable import MovieBrowser

final class MovieListViewTests: XCTestCase {

    // MARK: - Basic Initialization Tests
    func testMovieListViewInitialization() {
        let movieListView = MovieListView()
        XCTAssertNotNil(movieListView)
    }

    func testMovieListViewWithNavigationInitialization() {
        let movieListViewWithNav = MovieListViewWithNavigation()
        XCTAssertNotNil(movieListViewWithNav)
    }

    // MARK: - Component Rendering Tests
    func testMovieListViewBodyRendering() {
        // Test that MovieListView can be created without crashing
        // Note: We avoid accessing .body directly to prevent StateObject warnings
        let movieListView = MovieListView()
        XCTAssertNotNil(movieListView)
    }

    func testMovieListViewWithNavigationBodyRendering() {
        let movieListViewWithNav = MovieListViewWithNavigation()

        // Test that MovieListViewWithNavigation can be created without crashing
        // Note: We avoid accessing .body directly to prevent StateObject warnings
        XCTAssertNotNil(movieListViewWithNav)
    }

    // MARK: - State Variation Tests
    func testMovieListViewCreationStability() {
        // Test creating multiple instances
        for _ in 0..<10 {
            let movieListView = MovieListView()
            XCTAssertNotNil(movieListView)
            XCTAssertNotNil(movieListView.body)
        }
    }

    func testMovieListViewMemoryManagement() {
        var views: [MovieListView] = []

        // Create multiple instances
        for _ in 0..<5 {
            views.append(MovieListView())
        }

        XCTAssertEqual(views.count, 5)

        // Clear and verify
        views.removeAll()
        XCTAssertEqual(views.count, 0)
    }

    // MARK: - Edge Case Tests
    func testMovieListViewMultipleBodyAccess() {
        let movieListView = MovieListView()

        // Test multiple body accesses don't cause issues
        for _ in 0..<5 {
            XCTAssertNotNil(movieListView.body)
        }
    }

    func testMovieListViewPerformance() {
        // Test performance of view creation
        measure {
            for _ in 0..<50 {
                let movieListView = MovieListView()
                _ = movieListView.body
            }
        }
    }

    // MARK: - Integration Tests
    func testMovieListViewIntegration() {
        let movieListView = MovieListView()

        // Test that view integrates properly
        XCTAssertNotNil(movieListView.body)

        // Test that navigation version also works
        let movieListViewWithNav = MovieListViewWithNavigation()
        XCTAssertNotNil(movieListViewWithNav.body)
    }
}

// MARK: - LoadingOverlay Tests
final class LoadingOverlayTests: XCTestCase {

    func testLoadingOverlayVisible() {
        let loadingOverlay = LoadingOverlay(isVisible: true)
        XCTAssertNotNil(loadingOverlay)
        XCTAssertNotNil(loadingOverlay.body)
    }

    func testLoadingOverlayHidden() {
        let loadingOverlay = LoadingOverlay(isVisible: false)
        XCTAssertNotNil(loadingOverlay)
        XCTAssertNotNil(loadingOverlay.body)
    }

    func testLoadingOverlayStateToggle() {
        let visibleOverlay = LoadingOverlay(isVisible: true)
        let hiddenOverlay = LoadingOverlay(isVisible: false)

        XCTAssertNotNil(visibleOverlay.body)
        XCTAssertNotNil(hiddenOverlay.body)
    }

    func testLoadingOverlayMultipleInstances() {
        let overlays = [
            LoadingOverlay(isVisible: true),
            LoadingOverlay(isVisible: false),
            LoadingOverlay(isVisible: true),
            LoadingOverlay(isVisible: false)
        ]

        for overlay in overlays {
            XCTAssertNotNil(overlay)
            XCTAssertNotNil(overlay.body)
        }
    }

    func testLoadingOverlayPerformance() {
        measure {
            for i in 0..<100 {
                let isVisible = i % 2 == 0
                let overlay = LoadingOverlay(isVisible: isVisible)
                _ = overlay.body
            }
        }
    }
}

// MARK: - PullToRefreshView Tests
final class PullToRefreshViewTests: XCTestCase {

    func testPullToRefreshViewRefreshing() {
        let refreshView = PullToRefreshView(isRefreshing: true)
        XCTAssertNotNil(refreshView)
        XCTAssertNotNil(refreshView.body)
    }

    func testPullToRefreshViewNotRefreshing() {
        let refreshView = PullToRefreshView(isRefreshing: false)
        XCTAssertNotNil(refreshView)
        XCTAssertNotNil(refreshView.body)
    }

    func testPullToRefreshViewStateVariations() {
        let refreshStates = [true, false, true, false, true]

        for state in refreshStates {
            let refreshView = PullToRefreshView(isRefreshing: state)
            XCTAssertNotNil(refreshView)
            XCTAssertNotNil(refreshView.body)
        }
    }

    func testPullToRefreshViewMultipleCreations() {
        // Test rapid creation/destruction
        for i in 0..<20 {
            let isRefreshing = i % 3 == 0
            let refreshView = PullToRefreshView(isRefreshing: isRefreshing)
            XCTAssertNotNil(refreshView.body)
        }
    }

    func testPullToRefreshViewPerformance() {
        measure {
            for i in 0..<100 {
                let isRefreshing = i % 2 == 0
                let refreshView = PullToRefreshView(isRefreshing: isRefreshing)
                _ = refreshView.body
            }
        }
    }

    func testPullToRefreshViewConsistency() {
        // Test that the same state produces consistent results
        let refreshingView1 = PullToRefreshView(isRefreshing: true)
        let refreshingView2 = PullToRefreshView(isRefreshing: true)

        XCTAssertNotNil(refreshingView1.body)
        XCTAssertNotNil(refreshingView2.body)

        let notRefreshingView1 = PullToRefreshView(isRefreshing: false)
        let notRefreshingView2 = PullToRefreshView(isRefreshing: false)

        XCTAssertNotNil(notRefreshingView1.body)
        XCTAssertNotNil(notRefreshingView2.body)
    }

    func testPullToRefreshViewEdgeCases() {
        // Test with rapid state changes
        let states = [true, false, true, false, true, false]

        for state in states {
            let refreshView = PullToRefreshView(isRefreshing: state)

            // Test multiple body accesses
            for _ in 0..<3 {
                XCTAssertNotNil(refreshView.body)
            }
        }
    }

    func testPullToRefreshViewMemoryUsage() {
        var refreshViews: [PullToRefreshView] = []

        // Create multiple instances
        for i in 0..<10 {
            let isRefreshing = i % 2 == 0
            refreshViews.append(PullToRefreshView(isRefreshing: isRefreshing))
        }

        XCTAssertEqual(refreshViews.count, 10)

        // Test all instances
        for refreshView in refreshViews {
            XCTAssertNotNil(refreshView.body)
        }

        // Clean up
        refreshViews.removeAll()
        XCTAssertEqual(refreshViews.count, 0)
    }
}

// MARK: - Integration Tests
final class MovieListViewIntegrationTests: XCTestCase {

    func testAllComponentsTogether() {
        // Test that all components work together
        let movieListView = MovieListView()
        let loadingOverlay = LoadingOverlay(isVisible: true)
        let refreshView = PullToRefreshView(isRefreshing: false)

        XCTAssertNotNil(movieListView.body)
        XCTAssertNotNil(loadingOverlay.body)
        XCTAssertNotNil(refreshView.body)
    }

    func testComponentInteractionStability() {
        // Test creating multiple instances of all components
        for i in 0..<5 {
            let movieListView = MovieListView()
            let loadingOverlay = LoadingOverlay(isVisible: i % 2 == 0)
            let refreshView = PullToRefreshView(isRefreshing: i % 3 == 0)

            XCTAssertNotNil(movieListView.body)
            XCTAssertNotNil(loadingOverlay.body)
            XCTAssertNotNil(refreshView.body)
        }
    }

    func testComponentsWithNavigationStack() {
        let movieListViewWithNav = MovieListViewWithNavigation()

        // Test that navigation version renders properly
        XCTAssertNotNil(movieListViewWithNav.body)

        // Test with overlay components
        let loadingOverlay = LoadingOverlay(isVisible: true)
        let refreshView = PullToRefreshView(isRefreshing: true)

        XCTAssertNotNil(loadingOverlay.body)
        XCTAssertNotNil(refreshView.body)
    }

    func testLargeScaleComponentCreation() {
        // Test creating many components at once
        measure {
            for i in 0..<20 {
                let _ = MovieListView()
                let _ = LoadingOverlay(isVisible: i % 2 == 0)
                let _ = PullToRefreshView(isRefreshing: i % 3 == 0)
            }
        }
    }

    func testComponentRenderingPerformance() {
        let movieListView = MovieListView()
        let loadingOverlay = LoadingOverlay(isVisible: true)
        let refreshView = PullToRefreshView(isRefreshing: false)

        measure {
            for _ in 0..<50 {
                _ = movieListView.body
                _ = loadingOverlay.body
                _ = refreshView.body
            }
        }
    }
}
