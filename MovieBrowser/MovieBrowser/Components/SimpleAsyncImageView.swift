//
//  SimpleAsyncImageView.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Simple Async Image View
//

import SwiftUI
import Kingfisher

// MARK: - Simple Async Image View
/// An enhanced image view using Kingfisher for better performance and caching
struct SimpleAsyncImageView: View {
    let url: URL?
    let height: CGFloat
    @State private var loadingFailed = false

    // Debug options for testing loading states
    let simulateSlowLoading: Bool
    let simulateError: Bool

    // State for controlling delayed loading
    @State private var shouldStartLoading = false

    init(url: URL?, height: CGFloat = 200, simulateSlowLoading: Bool = false, simulateError: Bool = false) {
        self.url = url
        self.height = height
        self.simulateSlowLoading = simulateSlowLoading
        self.simulateError = simulateError
    }

    var body: some View {
        // Force exact dimensions to ensure consistent card sizes
        Rectangle()
            .fill(Color.clear)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .overlay(
                Group {
                    if simulateSlowLoading && !shouldStartLoading {
                        // Show loading state for slow simulation
                        loadingPlaceholder
                    } else {
                        KFImage(simulateError ? URL(string: "https://invalid-url-for-testing.com/image.jpg") : url)
                            .placeholder {
                                loadingPlaceholder
                            }
                            .onFailure { error in
                                // Update state and log error for debugging
                                loadingFailed = true
                                #if DEBUG
                                print("🖼️ Image loading failed: \(error.localizedDescription)")
                                if let url = url {
                                    print("🔗 Failed URL: \(url)")
                                }
                                #endif
                            }
                            .onSuccess { result in
                                // Reset failure state and log success
                                loadingFailed = false
                                #if DEBUG
                                print("🖼️ Image loaded successfully from: \(result.source)")
                                #endif
                            }
                            .retry(maxCount: 3)
                            .fade(duration: 0.25)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .onAppear {
                    if simulateSlowLoading {
                        // Delay the start of loading by 3 seconds using async/await
                        Task {
                            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                            shouldStartLoading = true
                        }
                    } else {
                        shouldStartLoading = true
                    }
                }
            )
            .overlay(
                // Error state overlay
                Group {
                    if loadingFailed {
                        ZStack {
                            // Subtle gradient background for error state
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.tertiaryBackground.opacity(0.8),
                                    DesignSystem.Colors.tertiaryBackground
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )

                            VStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "photo.badge.exclamationmark")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(DesignSystem.Colors.tertiaryLabel.opacity(0.8))

                                Text("Image unavailable")
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.tertiaryLabel.opacity(0.9))
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }
            )
            .clipped()
            .cornerRadius(DesignSystem.CornerRadius.image)
    }

    // MARK: - Loading Placeholder
    private var loadingPlaceholder: some View {
        ZStack {
            // Gradient background for depth
            LinearGradient(
                colors: [
                    DesignSystem.Colors.tertiaryBackground,
                    DesignSystem.Colors.tertiaryBackground.opacity(0.7),
                    DesignSystem.Colors.tertiaryBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Animated shimmer overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .customShimmer()

            // Elegant loading indicator
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 28, weight: .ultraLight))
                    .foregroundColor(DesignSystem.Colors.primary.opacity(0.6))

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                    .scaleEffect(0.8)
            }
        }
    }
}

// MARK: - Shimmer Effect Extension
extension View {
    func customShimmer() -> some View {
        @State var isAnimating = false

        return self
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(-70))
                    .offset(x: isAnimating ? 250 : -250)
                    .animation(
                        Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                    .onAppear {
                        isAnimating = true
                    }
            )
    }
}

// MARK: - Preview
#Preview("Loading States") {
    ScrollView {
        VStack(spacing: 20) {
            Text("Normal Loading")
                .font(.headline)
            SimpleAsyncImageView(
                url: URL(string: "https://raw.githubusercontent.com/p0werserg17/tr-ios-challenge/master/1.jpg"),
                height: 200
            )

            Text("Slow Loading (3s delay)")
                .font(.headline)
            SimpleAsyncImageView(
                url: URL(string: "https://raw.githubusercontent.com/p0werserg17/tr-ios-challenge/master/2.jpg"),
                height: 200,
                simulateSlowLoading: true
            )

            Text("Error State")
                .font(.headline)
            SimpleAsyncImageView(
                url: URL(string: "https://raw.githubusercontent.com/p0werserg17/tr-ios-challenge/master/3.jpg"),
                height: 200,
                simulateError: true
            )
        }
        .padding()
    }
}
