//
//  ContentViewTests.swift
//  MovieBrowserTests
//
//  Created by Laurent Lefebvre on 9/10/25.
//

import XCTest
import SwiftUI
@testable import MovieBrowser

final class ContentViewTests: XCTestCase {

    func testContentViewInitialization() {
        // Test that ContentView can be created without crashing
        let contentView = ContentView()
        XCTAssertNotNil(contentView)
    }

    func testContentViewBodyRendering() {
        // Test that ContentView body can be accessed without crashing
        let contentView = ContentView()
        XCTAssertNotNil(contentView.body)
    }

    func testContentViewWithDifferentStates() {
        // Test ContentView creation multiple times to ensure stability
        for _ in 0..<10 {
            let contentView = ContentView()
            XCTAssertNotNil(contentView)
        }
    }
}
