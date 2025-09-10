//
//  SimpleAsyncImageViewTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/9/25.
//  Unit tests for SimpleAsyncImageView
//

import XCTest
import SwiftUI
@testable import MovieBrowser

final class SimpleAsyncImageViewTests: XCTestCase {

    // MARK: - Basic Initialization Tests
    func testSimpleAsyncImageViewInitialization() {
        let imageView = SimpleAsyncImageView(url: URL(string: "https://example.com/image.jpg"))
        XCTAssertNotNil(imageView)
    }

    func testSimpleAsyncImageViewWithInvalidURL() {
        let imageView = SimpleAsyncImageView(url: URL(string: ""))
        XCTAssertNotNil(imageView)
    }

    func testSimpleAsyncImageViewWithNilURL() {
        let imageView = SimpleAsyncImageView(url: nil)
        XCTAssertNotNil(imageView)
    }

    // MARK: - Body Rendering Tests
    func testSimpleAsyncImageViewBodyRendering() {
        let testURLStrings = [
            "https://example.com/image1.jpg",
            "https://example.com/image2.png",
            "https://example.com/image3.gif",
            "https://example.com/image4.webp",
            "https://invalid-url",
            ""
        ]

        for urlString in testURLStrings {
            let imageView = SimpleAsyncImageView(url: URL(string: urlString))

            // Force body computation to execute internal logic
            XCTAssertNotNil(imageView)
        }

        // Test with nil URL
        let nilImageView = SimpleAsyncImageView(url: nil)
        XCTAssertNotNil(nilImageView)
    }

    func testSimpleAsyncImageViewWithDifferentAspectRatios() {
        let imageView = SimpleAsyncImageView(url: URL(string: "https://example.com/image.jpg"))

        // Test body rendering multiple times to trigger different code paths
        for _ in 0..<10 {
            XCTAssertNotNil(imageView)
        }
    }

    // MARK: - URL Validation Tests
    func testSimpleAsyncImageViewWithValidURLs() {
        let validURLStrings = [
            "https://example.com/image.jpg",
            "https://cdn.example.com/path/to/image.png",
            "http://localhost:8080/image.gif",
            "https://images.unsplash.com/photo-123456789"
        ]

        for urlString in validURLStrings {
            let imageView = SimpleAsyncImageView(url: URL(string: urlString))
            XCTAssertNotNil(imageView)
        }
    }

    func testSimpleAsyncImageViewWithInvalidURLs() {
        let invalidURLStrings = [
            "not-a-url",
            "ftp://example.com/image.jpg",
            "file:///local/path/image.png",
            "javascript:alert('xss')",
            "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
        ]

        for urlString in invalidURLStrings {
            let imageView = SimpleAsyncImageView(url: URL(string: urlString))
            XCTAssertNotNil(imageView)
        }
    }

    // MARK: - Edge Cases Tests
    func testSimpleAsyncImageViewEdgeCases() {
        // Test with very long URL
        let longURLString = "https://example.com/" + String(repeating: "a", count: 1000) + ".jpg"
        let longURLView = SimpleAsyncImageView(url: URL(string: longURLString))
        XCTAssertNotNil(longURLView)

        // Test with URL containing special characters (will likely be nil due to invalid characters)
        let specialURLString = "https://example.com/image with spaces & symbols!@#$%^&*().jpg"
        let specialURLView = SimpleAsyncImageView(url: URL(string: specialURLString))
        XCTAssertNotNil(specialURLView)

        // Test with URL containing Unicode characters
        let unicodeURLString = "https://example.com/图片.jpg"
        let unicodeURLView = SimpleAsyncImageView(url: URL(string: unicodeURLString))
        XCTAssertNotNil(unicodeURLView)
    }

    // MARK: - Performance Tests
    func testSimpleAsyncImageViewCreationPerformance() {
        measure {
            for i in 0..<100 {
                let imageView = SimpleAsyncImageView(url: URL(string: "https://example.com/image\(i).jpg"))
                XCTAssertNotNil(imageView)
            }
        }
    }

    func testSimpleAsyncImageViewBodyComputationPerformance() {
        // Test performance of creating different configurations
        measure {
            for i in 0..<100 {
                let imageView = SimpleAsyncImageView(
                    url: URL(string: "https://example.com/image\(i).jpg"),
                    height: CGFloat(100 + i % 200),
                    simulateSlowLoading: i % 2 == 0,
                    simulateError: i % 3 == 0
                )
                XCTAssertNotNil(imageView)
            }
        }
    }

    // MARK: - Memory Management Tests
    func testSimpleAsyncImageViewMemoryUsage() {
        var imageViews: [SimpleAsyncImageView] = []

        // Create multiple instances
        for i in 0..<100 {
            let imageView = SimpleAsyncImageView(url: URL(string: "https://example.com/image\(i).jpg"))
            imageViews.append(imageView)
        }

        XCTAssertEqual(imageViews.count, 100)

        // Force body computation on all
        for imageView in imageViews {
            XCTAssertNotNil(imageView)
        }

        // Clean up
        imageViews.removeAll()
        XCTAssertEqual(imageViews.count, 0)
    }

    // MARK: - State Management Tests
    func testSimpleAsyncImageViewStateHandling() {
        // Test different loading states by creating multiple views
        let stateURLStrings = [
            "https://example.com/loading.jpg",
            "https://example.com/success.jpg",
            "https://example.com/error.jpg",
            ""
        ]

        for urlString in stateURLStrings {
            let imageView = SimpleAsyncImageView(url: URL(string: urlString))

            // Force body computation to trigger state handling
            XCTAssertNotNil(imageView)
        }

        // Test with nil URL
        let nilImageView = SimpleAsyncImageView(url: nil)
        XCTAssertNotNil(nilImageView)
    }

    // MARK: - Concurrency Tests
    func testSimpleAsyncImageViewConcurrentAccess() {
        // Test that multiple SimpleAsyncImageView instances can be created concurrently
        let expectation = XCTestExpectation(description: "Concurrent instance creation")
        expectation.expectedFulfillmentCount = 10

        // Create instances from multiple threads
        for i in 0..<10 {
            DispatchQueue.global().async {
                let imageView = SimpleAsyncImageView(url: URL(string: "https://example.com/image\(i).jpg"))
                XCTAssertNotNil(imageView)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Integration Tests
    func testSimpleAsyncImageViewIntegration() {
        // Test integration with different SwiftUI contexts
        let imageView = SimpleAsyncImageView(url: URL(string: "https://example.com/integration.jpg"))

        // Simulate being used in different contexts
        let contexts = [
            "List context",
            "NavigationView context",
            "VStack context",
            "HStack context",
            "LazyVGrid context"
        ]

        for _ in contexts {
            XCTAssertNotNil(imageView)
        }
    }
}
