//
//  MovieDetailView.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Movie Detail View
//

import SwiftUI

// MARK: - Movie Detail View
/// Detailed view displaying comprehensive movie information and recommendations
struct MovieDetailView: View {

    // MARK: - Properties
    let movie: Movie
    @StateObject private var viewModel: MovieDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRecommendation: Movie?
    @State private var showingShareSheet = false
    @State private var scrollOffset: CGFloat = 0

    // MARK: - Initialization
    init(movie: Movie) {
        self.movie = movie
        self._viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()

                mainContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    closeButton
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        likeButton
                        shareButton
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(DesignSystem.Colors.background, for: .navigationBar)
            .sheet(item: $selectedRecommendation) { recommendation in
                MovieDetailView(movie: recommendation)
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [viewModel.shareableContent])
            }
        }
    }

    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.detailsLoadingState == .loading && viewModel.movieDetails == nil {
            LoadingView("Loading movie details...")
        } else if case .failed(let error) = viewModel.detailsLoadingState, viewModel.movieDetails == nil {
            ErrorView(
                viewModel.detailsErrorMessage ?? error.localizedDescription,
                retryAction: {
                    Task {
                        await viewModel.retryLoading()
                    }
                }
            )
        } else {
            movieDetailContent
        }
    }

    // MARK: - Movie Detail Content (Redesigned)
    private var movieDetailContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Hero section with poster and basic info
                heroSection

                // Movie information section
                movieInfoSection

                // Description section
                if let details = viewModel.movieDetails {
                    descriptionSection(details)
                }

                // Additional notes section
                if viewModel.shouldShowNotes {
                    notesSection
                }

                // Recommendations section
                recommendationsSection

                // Bottom safe area padding for full visibility
                Color.clear.frame(height: 16)
            }
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refreshData()
        }
    }

    // MARK: - Hero Section (Redesigned)
    private var heroSection: some View {
        VStack(spacing: 0) {
            // Premium poster with consistent background
            VStack(spacing: 16) {
                Spacer(minLength: 16)

                // Enhanced poster with premium styling
                SimpleAsyncImageView(
                    url: viewModel.movieDetails?.pictureURL ?? movie.thumbnailURL,
                    height: 320
                )
                .frame(width: 214) // Golden ratio: 320/214 ≈ 1.5 (poster ratio)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )

                Spacer(minLength: 16)
            }
            .frame(maxWidth: .infinity, maxHeight: 400) // Center horizontally
            .background(DesignSystem.Colors.background) // Consistent background

            // Title section with improved typography hierarchy
            VStack(spacing: 12) {
                VStack(spacing: 8) {
                    Text(movie.name)
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(DesignSystem.Colors.label)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .frame(minHeight: 60, alignment: .center) // Allocate space and center vertically
                        .accessibilityAddTraits(.isHeader)

                    // Enhanced metadata with single date source
                    HStack {
                        Spacer()
                        if let details = viewModel.movieDetails {
                            // Use the more specific release date from details
                            Text(details.formattedReleaseDate)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.secondaryLabel)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(DesignSystem.Colors.tertiaryBackground)
                                .clipShape(Capsule())
                        } else {
                            // Fallback to year if details not loaded
                            Text(movie.yearString)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.secondaryLabel)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(DesignSystem.Colors.tertiaryBackground)
                                .clipShape(Capsule())
                        }
                        Spacer()
                    }
                }

                // Star rating - clean display without redundant text
                if let details = viewModel.movieDetails {
                    HStack {
                        Spacer()
                        StarRatingView(
                            rating: details.starRating,
                            starSize: 24,
                            spacing: 6,
                            showRatingText: false
                        )
                        .padding(.horizontal, 8) // Reasonable padding
                        .padding(.vertical, 8)   // Reasonable padding
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity) // Ensure full width for centering
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Movie Info Section (Redesigned)
    @ViewBuilder
    private var movieInfoSection: some View {
        if let details = viewModel.movieDetails {
            VStack(spacing: 16) {
                // Premium stats cards with glassmorphism effect
                HStack(spacing: 16) {
                    // Rating card
                    VStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.yellow)

                        Text(details.formattedRating)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.label)

                        Text("Rating")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.secondaryLabel)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(DesignSystem.Colors.secondaryBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                    )

                    // Year card
                    VStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.primary)

                        Text(movie.yearString)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.label)

                        Text("Year")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.secondaryLabel)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(DesignSystem.Colors.secondaryBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                    )

                    // Interactive Like status card
                    Button(action: {
                        viewModel.toggleLike()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(viewModel.isLiked ? DesignSystem.Colors.heartFilled : DesignSystem.Colors.heartEmpty)
                                .scaleEffect(viewModel.isLiked ? 1.1 : 1.0)
                                .animation(DesignSystem.Animation.likeButton, value: viewModel.isLiked)

                            Text(viewModel.isLiked ? "Liked" : "Like")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.label)

                            Text("Status")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.secondaryLabel)
                                .textCase(.uppercase)
                                .tracking(0.5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(DesignSystem.Colors.secondaryBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.isLiked)
                    .accessibilityLabel(viewModel.isLiked ? "Unlike movie" : "Like movie")
                    .accessibilityHint("Double tap to toggle like status")
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Description Section (Redesigned)
    private func descriptionSection(_ details: MovieDetails) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header with refined styling
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Synopsis")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.label)

                    Rectangle()
                        .fill(LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 30, height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            // Enhanced description with better readability
            VStack(alignment: .leading, spacing: 16) {
                Text(details.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.label)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DesignSystem.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Notes Section (Redesigned with Expandable Text)
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header matching other sections
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Additional Information")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.label)

                    Rectangle()
                        .fill(LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 40, height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            // Expandable text content
            ExpandableTextView(text: viewModel.movieNotes)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(DesignSystem.Colors.secondaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Recommendations Section (Redesigned)
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Enhanced section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You Might Also Like")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.label)
                        .accessibilityAddTraits(.isHeader)

                    Rectangle()
                        .fill(LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 50, height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                }

                Spacer()

                if viewModel.recommendationsLoadingState == .loading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                            .scaleEffect(0.8)

                        Text("Loading...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.secondaryLabel)
                    }
                }
            }
            .padding(.horizontal, 24)

            recommendationsContent
        }
    }

    // MARK: - Recommendations Content
    @ViewBuilder
    private var recommendationsContent: some View {
        switch viewModel.recommendationsLoadingState {
        case .idle, .loading:
            if viewModel.recommendedMovies.isEmpty {
                recommendationsPlaceholder
            } else {
                recommendationsScrollView
            }

        case .loaded:
            if viewModel.recommendedMovies.isEmpty {
                noRecommendationsView
            } else {
                recommendationsScrollView
            }

        case .failed:
            recommendationsErrorView
        }
    }

    // MARK: - Recommendations Scroll View (Enhanced)
    private var recommendationsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                // Leading spacer for proper edge padding
                Color.clear.frame(width: 8)

                ForEach(viewModel.recommendedMovies) { recommendation in
                    CompactMovieCardView(
                        movie: recommendation,
                        isLiked: false, // Could be enhanced to check likes
                        onLikeToggle: {
                            // Handle recommendation like
                        },
                        onTap: {
                            selectedRecommendation = recommendation
                        }
                    )
                    .scaleEffect(0.95) // Slightly smaller for better visual hierarchy
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }

                // Trailing spacer for proper edge padding
                Color.clear.frame(width: 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8) // Add vertical padding to prevent clipping
        }
        .frame(height: 230) // Ensure sufficient height for cards
    }

    // MARK: - Recommendations Placeholder
    private var recommendationsPlaceholder: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Colors.tertiaryBackground)
                    .frame(width: 120, height: 180)
                    .shimmer()
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }

    // MARK: - No Recommendations View
    private var noRecommendationsView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "film")
                .font(.system(size: 32))
                .foregroundColor(DesignSystem.Colors.tertiaryLabel)

            Text("No recommendations available")
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.secondaryLabel)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }

    // MARK: - Recommendations Error View
    private var recommendationsErrorView: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("Unable to load recommendations")
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.secondaryLabel)

            if viewModel.canRetryRecommendations {
                Button("Try Again") {
                    Task {
                        await viewModel.loadRecommendations()
                    }
                }
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.primary)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }


    // MARK: - Toolbar Buttons
    private var closeButton: some View {
        Button("Close") {
            dismiss()
        }
        .font(DesignSystem.Typography.body)
        .foregroundColor(DesignSystem.Colors.primary)
    }

    private var likeButton: some View {
        Button(action: {
            viewModel.toggleLike()
        }) {
            Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(
                    viewModel.isLiked ? DesignSystem.Colors.heartFilled : DesignSystem.Colors.heartEmpty
                )
        }
        .scaleEffect(viewModel.isLiked ? 1.1 : 1.0)
        .animation(DesignSystem.Animation.likeButton, value: viewModel.isLiked)
        .accessibilityLabel(viewModel.isLiked ? "Unlike movie" : "Like movie")
    }

    private var shareButton: some View {
        Button(action: {
            viewModel.trackShareAction()
            showingShareSheet = true
        }) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .accessibilityLabel("Share movie")
    }
}

// MARK: - Shimmer Effect
extension View {
    func shimmer() -> some View {
        self.overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(30))
                .offset(x: -200)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: UUID())
        )
        .clipped()
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Expandable Text View
struct ExpandableTextView: View {
    let text: String
    @State private var isExpanded = false
    @State private var isTruncated = false

    private let lineLimit = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(DesignSystem.Colors.label)
                .lineSpacing(6)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    // Hidden text to measure if truncation is needed
                    Text(text)
                        .font(.system(size: 16, weight: .regular))
                        .lineSpacing(6)
                        .lineLimit(lineLimit)
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear {
                                let font = UIFont.systemFont(ofSize: 16)
                                let attributes = [NSAttributedString.Key.font: font]
                                let attributedText = NSAttributedString(string: text, attributes: attributes)
                                let textRect = attributedText.boundingRect(
                                    with: CGSize(width: geometry.size.width, height: .greatestFiniteMagnitude),
                                    options: .usesLineFragmentOrigin,
                                    context: nil
                                )
                                let lineHeight = font.lineHeight + 6 // lineSpacing
                                isTruncated = textRect.height > lineHeight * Double(lineLimit)
                            }
                        })
                        .hidden()
                )

            if isTruncated {
                HStack {
                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(isExpanded ? "Show Less" : "Show More")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.primary)

                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DesignSystem.Colors.primary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MovieDetailView(movie: Movie.sampleMovie)
}

#Preview("Dark Mode") {
    MovieDetailView(movie: Movie.sampleMovie)
        .preferredColorScheme(.dark)
}
