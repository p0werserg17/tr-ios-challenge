//
//  ContentView.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Main Content View
//

import SwiftUI

// MARK: - Content View
/// Main content view that serves as the root of the application
struct ContentView: View {

    // MARK: - Body
    var body: some View {
        MovieListView()
            .preferredColorScheme(nil) // Supports both light and dark mode
    }
}

// MARK: - Preview
#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
