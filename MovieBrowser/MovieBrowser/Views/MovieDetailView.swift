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

    // MARK: - Movie Detail Content
    private var movieDetailContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
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
            }
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refreshData()
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Large movie poster - Using Kingfisher for consistency
            SimpleAsyncImageView(
                url: viewModel.movieDetails?.pictureURL ?? movie.thumbnailURL,
                height: 400
            )
            .shadow(
                color: DesignSystem.Shadow.card.color,
                radius: DesignSystem.Shadow.card.radius * 2,
                x: 0,
                y: DesignSystem.Shadow.card.y * 2
            )
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)

            // Title and basic info
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(movie.name)
                    .font(DesignSystem.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.label)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                HStack(spacing: DesignSystem.Spacing.md) {
                    Text(movie.yearString)
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.secondaryLabel)

                    if let details = viewModel.movieDetails {
                        Text("•")
                            .foregroundColor(DesignSystem.Colors.tertiaryLabel)

                        Text(details.formattedReleaseDate)
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.secondaryLabel)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        }
    }

    // MARK: - Movie Info Section
    private var movieInfoSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if let details = viewModel.movieDetails {
                // Rating
                LargeStarRatingView(
                    rating: details.starRating,
                    originalRating: details.rating
                )

                // Quick stats
                HStack(spacing: DesignSystem.Spacing.xl) {
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Text("RATING")
                            .font(DesignSystem.Typography.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.tertiaryLabel)

                        Text(details.formattedRating)
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.label)
                    }

                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Text("YEAR")
                            .font(DesignSystem.Typography.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.tertiaryLabel)

                        Text(movie.yearString)
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.label)
                    }

                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Text("LIKED")
                            .font(DesignSystem.Typography.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.tertiaryLabel)

                        Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(
                                viewModel.isLiked ? DesignSystem.Colors.heartFilled : DesignSystem.Colors.heartEmpty
                            )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
        }
    }

    // MARK: - Description Section
    private func descriptionSection(_ details: MovieDetails) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Synopsis")
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundColor(DesignSystem.Colors.label)
                .accessibilityAddTraits(.isHeader)

            Text(details.description)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.label)
                .lineSpacing(4)
        }
        .cardPadding()
        .cardStyle()
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Additional Information")
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundColor(DesignSystem.Colors.label)
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.movieNotes)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.secondaryLabel)
                .lineSpacing(3)
        }
        .cardPadding()
        .cardStyle()
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }

    // MARK: - Recommendations Section
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("You Might Also Like")
                    .font(DesignSystem.Typography.sectionTitle)
                    .foregroundColor(DesignSystem.Colors.label)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                if viewModel.recommendationsLoadingState == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)

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

    // MARK: - Recommendations Scroll View
    private var recommendationsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.md) {
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
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        }
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

// MARK: - Preview
#Preview {
    MovieDetailView(movie: Movie.sampleMovie)
}

#Preview("Dark Mode") {
    MovieDetailView(movie: Movie.sampleMovie)
        .preferredColorScheme(.dark)
}
