//
//  MovieBrowserApp.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Main App Entry Point
//

import SwiftUI

// MARK: - Movie Browser App
/// Main app structure with proper setup and dependency injection
@main
struct MovieBrowserApp: App {

    // MARK: - App Lifecycle
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupApp()
                }
        }
    }

    // MARK: - App Setup
    /// Performs initial app setup and configuration
    private func setupApp() {
        // Configure network cache
        configureNetworkCache()

        // Configure appearance
        configureAppearance()

        // Setup analytics (placeholder for real implementation)
        setupAnalytics()
    }

    /// Configures network caching for better performance
    private func configureNetworkCache() {
        let urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024, // 50MB memory cache
            diskCapacity: 100 * 1024 * 1024,  // 100MB disk cache
            diskPath: "movie_browser_cache"
        )
        URLCache.shared = urlCache
    }

    /// Configures app-wide appearance settings
    private func configureAppearance() {
        // Configure navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor.systemBackground
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        // Configure tab bar appearance (for future use)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    /// Sets up analytics tracking (placeholder for real implementation)
    private func setupAnalytics() {
        // In a production app, this would initialize analytics SDKs
        #if DEBUG
        print("📊 Analytics initialized")
        #endif
    }
}

// MARK: - App Configuration Extension
extension MovieBrowserApp {
    /// App version information
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// Build number information
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// Full version string for display
    static var fullVersionString: String {
        "Version \(appVersion) (\(buildNumber))"
    }
}
