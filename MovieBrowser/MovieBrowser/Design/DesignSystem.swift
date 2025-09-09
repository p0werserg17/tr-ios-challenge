//
//  DesignSystem.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Design System
//

import SwiftUI

// MARK: - Design System
/// Centralized design system providing consistent styling throughout the app
struct DesignSystem {

    // MARK: - Colors
    struct Colors {
        // Primary brand colors - Modern iOS colors
        static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // iOS Blue
        static let secondary = Color(red: 0.35, green: 0.34, blue: 0.84) // iOS Indigo

        // Semantic colors that adapt to light/dark mode
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)

        static let label = Color(UIColor.label)
        static let secondaryLabel = Color(UIColor.secondaryLabel)
        static let tertiaryLabel = Color(UIColor.tertiaryLabel)

        // Custom semantic colors
        static let cardBackground = Color(UIColor.systemBackground)
        static let cardShadow = Color.black.opacity(0.1)
        static let separator = Color(UIColor.separator)

        // Status colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red

        // Rating colors
        static let starFilled = Color.yellow
        static let starEmpty = Color.gray.opacity(0.3)

        // Like heart colors
        static let heartFilled = Color.red
        static let heartEmpty = Color.gray
    }

    // MARK: - Typography
    struct Typography {
        // Title styles
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)

        // Body styles
        static let body = Font.body
        static let bodyEmphasized = Font.body.weight(.medium)
        static let callout = Font.callout
        static let caption = Font.caption
        static let caption2 = Font.caption2

        // Custom styles
        static let movieTitle = Font.subheadline.weight(.semibold)  // Smaller, more compact
        static let movieYear = Font.caption.weight(.medium)
        static let movieRating = Font.subheadline.weight(.semibold)
        static let sectionTitle = Font.headline.weight(.semibold)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48

        // Semantic spacing
        static let cardPadding: CGFloat = md
        static let sectionSpacing: CGFloat = lg
        static let itemSpacing: CGFloat = sm
        static let screenPadding: CGFloat = md
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24

        // Semantic radius
        static let card: CGFloat = medium
        static let button: CGFloat = small
        static let image: CGFloat = medium
    }

    // MARK: - Shadows
    struct Shadow {
        static let card = DropShadow(
            color: Colors.cardShadow,
            radius: 8,
            x: 0,
            y: 2
        )

        static let button = DropShadow(
            color: Colors.cardShadow,
            radius: 4,
            x: 0,
            y: 2
        )
    }

    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)

        // Semantic animations
        static let cardTap = quick
        static let likeButton = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
        static let loadingFade = standard
    }
}

// MARK: - Drop Shadow Helper
struct DropShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    /// Applies the standard card styling
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.card)
            .shadow(
                color: DesignSystem.Shadow.card.color,
                radius: DesignSystem.Shadow.card.radius,
                x: DesignSystem.Shadow.card.x,
                y: DesignSystem.Shadow.card.y
            )
    }

    /// Applies standard screen padding
    func screenPadding() -> some View {
        self.padding(DesignSystem.Spacing.screenPadding)
    }

    /// Applies card padding
    func cardPadding() -> some View {
        self.padding(DesignSystem.Spacing.cardPadding)
    }

    /// Custom button style with haptic feedback
    func buttonStyle(
        backgroundColor: Color = DesignSystem.Colors.primary,
        foregroundColor: Color = .white
    ) -> some View {
        self
            .foregroundColor(foregroundColor)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(backgroundColor)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .shadow(
                color: DesignSystem.Shadow.button.color,
                radius: DesignSystem.Shadow.button.radius,
                x: DesignSystem.Shadow.button.x,
                y: DesignSystem.Shadow.button.y
            )
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(backgroundColor: DesignSystem.Colors.primary)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(DesignSystem.Animation.cardTap, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(
                backgroundColor: DesignSystem.Colors.secondaryBackground,
                foregroundColor: DesignSystem.Colors.label
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(DesignSystem.Animation.cardTap, value: configuration.isPressed)
    }
}

// MARK: - Custom Card Style
struct CardModifier: ViewModifier {
    let isPressed: Bool

    func body(content: Content) -> some View {
        content
            .cardStyle()
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animation.cardTap, value: isPressed)
    }
}

extension View {
    func cardModifier(isPressed: Bool = false) -> some View {
        self.modifier(CardModifier(isPressed: isPressed))
    }
}

// MARK: - Loading Indicators
struct LoadingView: View {
    let message: String

    init(_ message: String = "Loading...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                .scaleEffect(1.2)

            Text(message)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.secondaryLabel)
        }
        .padding(DesignSystem.Spacing.xl)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(
            color: DesignSystem.Shadow.card.color,
            radius: DesignSystem.Shadow.card.radius,
            x: DesignSystem.Shadow.card.x,
            y: DesignSystem.Shadow.card.y
        )
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?

    init(_ message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.error)

            Text("Oops!")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.label)

            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.md)

            if let retryAction = retryAction {
                Button("Try Again") {
                    retryAction()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(
            color: DesignSystem.Shadow.card.color,
            radius: DesignSystem.Shadow.card.radius,
            x: DesignSystem.Shadow.card.x,
            y: DesignSystem.Shadow.card.y
        )
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    let action: (() -> Void)?
    let actionTitle: String?

    init(
        title: String,
        message: String,
        systemImage: String = "tray",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.tertiaryLabel)

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(title)
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.label)

                Text(message)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }

            if let action = action, let actionTitle = actionTitle {
                Button(actionTitle) {
                    action()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(DesignSystem.Spacing.xl)
    }
}
