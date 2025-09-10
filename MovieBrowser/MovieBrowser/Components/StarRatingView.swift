//
//  StarRatingView.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Star Rating Component
//

import SwiftUI

// MARK: - Star Rating View
/// A customizable star rating component
struct StarRatingView: View {

    // MARK: - Properties
    let rating: Double // Rating out of 5
    let maxRating: Int = 5
    let starSize: CGFloat
    let spacing: CGFloat
    let showRatingText: Bool

    // MARK: - Initialization
    init(
        rating: Double,
        starSize: CGFloat = 16,
        spacing: CGFloat = 2,
        showRatingText: Bool = true
    ) {
        self.rating = max(0, min(5, rating)) // Clamp between 0 and 5
        self.starSize = starSize
        self.spacing = spacing
        self.showRatingText = showRatingText
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: spacing) {
            // Star icons
            HStack(spacing: spacing) {
                ForEach(0..<maxRating, id: \.self) { index in
                    starView(for: index)
                }
            }

            // Rating text
            if showRatingText {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: starSize * 0.8, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondaryLabel)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating: \(String(format: "%.1f", rating)) out of 5 stars")
    }

    // MARK: - Star View (Frame-Constrained with Precise Masking)
    private func starView(for index: Int) -> some View {
        let fillAmount = calculateFillAmount(for: index)

        return ZStack(alignment: .leading) {
            // Background star (empty) - constrained to exact frame
            Image(systemName: "star")
                .font(.system(size: starSize, weight: .medium))
                .foregroundColor(DesignSystem.Colors.starEmpty)
                .frame(width: starSize, height: starSize) // Constrain star to exact frame

            // Foreground star (filled) - constrained and masked
            if fillAmount > 0 {
                Image(systemName: "star.fill")
                    .font(.system(size: starSize, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.starFilled)
                    .frame(width: starSize, height: starSize) // Constrain star to exact frame
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: starSize * fillAmount, height: starSize) // Mask within exact frame
                    }
            }
        }
        .frame(width: starSize, height: starSize) // Container frame
        .clipped() // Ensure nothing extends beyond frame
    }

    // MARK: - Helper Methods
    private func calculateFillAmount(for index: Int) -> CGFloat {
        let starPosition = Double(index)

        if rating >= starPosition + 1 {
            return 1.0 // Full star
        } else if rating > starPosition {
            return CGFloat(rating - starPosition) // Partial star
        } else {
            return 0.0 // Empty star
        }
    }
}

// MARK: - Large Star Rating View
/// A larger version of the star rating for detail screens
struct LargeStarRatingView: View {
    let rating: Double
    let originalRating: Double // Original rating out of 10

    init(rating: Double, originalRating: Double) {
        self.rating = rating
        self.originalRating = originalRating
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            StarRatingView(
                rating: rating,
                starSize: 24,
                spacing: 4,
                showRatingText: false
            )

            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(String(format: "%.1f", rating))
                    .font(DesignSystem.Typography.movieRating)
                    .foregroundColor(DesignSystem.Colors.label)

                Text("•")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.tertiaryLabel)

                Text("\(String(format: "%.1f", originalRating))/10")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryLabel)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating: \(String(format: "%.1f", rating)) out of 5 stars, \(String(format: "%.1f", originalRating)) out of 10")
    }
}

// MARK: - Compact Star Rating View
/// A compact version for use in cards or lists
struct CompactStarRatingView: View {
    let rating: Double

    var body: some View {
        StarRatingView(
            rating: rating,
            starSize: 12,
            spacing: 1,
            showRatingText: true
        )
    }
}

// MARK: - Animated Star Rating View
/// Star rating with animation effects
struct AnimatedStarRatingView: View {
    let rating: Double
    @State private var animatedRating: Double = 0

    var body: some View {
        StarRatingView(
            rating: animatedRating,
            starSize: 20,
            spacing: 3,
            showRatingText: true
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                animatedRating = rating
            }
        }
    }
}

// MARK: - Rating Badge View
/// A badge-style rating display
struct RatingBadgeView: View {
    let rating: Double
    let backgroundColor: Color

    init(rating: Double) {
        self.rating = rating

        // Dynamic background color based on rating
        switch rating {
        case 4.0...5.0:
            self.backgroundColor = DesignSystem.Colors.success
        case 3.0..<4.0:
            self.backgroundColor = DesignSystem.Colors.warning
        default:
            self.backgroundColor = DesignSystem.Colors.error
        }
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "star.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)

            Text(String(format: "%.1f", rating))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(backgroundColor)
        .cornerRadius(DesignSystem.CornerRadius.small)
        .accessibilityLabel("Rating: \(String(format: "%.1f", rating)) out of 5 stars")
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        VStack(alignment: .leading, spacing: 15) {
            Text("Star Rating Examples")
                .font(.title2)
                .fontWeight(.bold)

            Group {
                StarRatingView(rating: 4.5)
                StarRatingView(rating: 3.2)
                StarRatingView(rating: 1.8)
                StarRatingView(rating: 5.0)
            }

            Divider()

            LargeStarRatingView(rating: 4.2, originalRating: 8.4)

            Divider()

            HStack {
                CompactStarRatingView(rating: 4.1)
                Spacer()
                RatingBadgeView(rating: 4.1)
            }

            Divider()

            AnimatedStarRatingView(rating: 3.7)
        }
        .padding()
    }
    .background(DesignSystem.Colors.background)
}
