//
//  MovieCardView.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Movie Card Component
//

import SwiftUI

// MARK: - Movie Card View
/// A reusable card component for displaying movie information
struct MovieCardView: View {

    // MARK: - Properties
    let movie: Movie
    let isLiked: Bool
    let onLikeToggle: () -> Void
    let onTap: () -> Void

    @State private var isPressed = false

    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Movie Poster
            posterImageView

            // Movie Information
            movieInfoView
        }
        .frame(maxWidth: .infinity, minHeight: 260, maxHeight: 260) // Ensure consistent dimensions (reduced)
        .cardPadding()
        .cardModifier(isPressed: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onPressGesture(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("\(movie.name), \(movie.year)")
        .accessibilityHint("Tap to view movie details")
    }

    // MARK: - Poster Image View
    private var posterImageView: some View {
        ZStack(alignment: .topTrailing) {
            // Main poster image - Using simple AsyncImage for reliability
            SimpleAsyncImageView(url: movie.thumbnailURL, height: 200)

            // Like button overlay
            likeButton
        }
    }


    // MARK: - Like Button
    private var likeButton: some View {
        Button(action: onLikeToggle) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isLiked ? DesignSystem.Colors.heartFilled : DesignSystem.Colors.heartEmpty)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 32, height: 32)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isLiked ? 1.1 : 1.0)
        .animation(DesignSystem.Animation.likeButton, value: isLiked)
        .padding(DesignSystem.Spacing.sm)
        .accessibilityLabel(isLiked ? "Unlike movie" : "Like movie")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Movie Info View
    private var movieInfoView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title area - centered vertically for better balance
            Text(movie.name)
                .font(DesignSystem.Typography.movieTitle)
                .foregroundColor(DesignSystem.Colors.label)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, minHeight: 34, maxHeight: 34, alignment: .center) // Centered alignment
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 6) // Consistent spacing

            // Year at bottom with centered alignment for consistency
            Text(movie.yearString)
                .font(DesignSystem.Typography.movieYear)
                .foregroundColor(DesignSystem.Colors.secondaryLabel)
                .frame(maxWidth: .infinity, alignment: .center) // Centered like the title
        }
        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .top) // Top alignment for container
    }
}

// MARK: - Press Gesture Extension
extension View {
    func onPressGesture(
        onPress: @escaping () -> Void,
        onRelease: @escaping () -> Void
    ) -> some View {
        self
            .scaleEffect(1.0)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    if pressing {
                        onPress()
                    } else {
                        onRelease()
                    }
                },
                perform: {}
            )
    }
}

// MARK: - Movie Card Grid View
/// A grid layout for displaying multiple movie cards
struct MovieCardGridView: View {
    let movies: [Movie]
    let likedMovieIds: Set<Int>
    let onMovieTap: (Movie) -> Void
    let onLikeToggle: (Movie) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
            ForEach(movies) { movie in
                MovieCardView(
                    movie: movie,
                    isLiked: likedMovieIds.contains(movie.id),
                    onLikeToggle: { onLikeToggle(movie) },
                    onTap: { onMovieTap(movie) }
                )
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }
}

// MARK: - Compact Movie Card View
/// A more compact version of the movie card for recommendations
struct CompactMovieCardView: View {
    let movie: Movie
    let isLiked: Bool
    let onLikeToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                // Compact poster
                SimpleAsyncImageView(url: movie.thumbnailURL, height: 160)
                    .frame(width: 120)

                // Compact info with better spacing
                VStack(alignment: .center, spacing: 0) {
                    Text(movie.name)
                        .font(DesignSystem.Typography.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.label)
                        .lineLimit(2)
                        .multilineTextAlignment(.center) // Center the text
                        .truncationMode(.tail)
                        .frame(height: 28, alignment: .center) // Centered for balance

                    Spacer(minLength: 4) // Consistent spacing

                    Text(movie.yearString)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.secondaryLabel)
                        .frame(maxWidth: .infinity, alignment: .center) // Centered for consistency
                }
                .frame(width: 120, height: 40, alignment: .top)
            }
            .frame(width: 120, height: 210) // Fixed total dimensions
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(movie.name), \(movie.year)")
        .accessibilityHint("Tap to view movie details")
    }

}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        MovieCardView(
            movie: Movie.sampleMovie,
            isLiked: false,
            onLikeToggle: {},
            onTap: {}
        )

        MovieCardView(
            movie: Movie.sampleMovie,
            isLiked: true,
            onLikeToggle: {},
            onTap: {}
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
}
