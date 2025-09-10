//
//  MovieListView.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Movie List View
//

import SwiftUI

// MARK: - Movie List View
/// Main view displaying the list of movies with search and filtering capabilities
struct MovieListView: View {

    // MARK: - Properties
    @StateObject private var viewModel = MovieListViewModel()
    @State private var selectedMovie: Movie?
    @State private var showingMovieDetail = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()

                mainContent
            }
            .navigationTitle("Movies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Invisible button to catch taps on title area
                    Button(action: {
                        hideKeyboard()
                    }) {
                        Color.clear
                            .frame(width: 100, height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                ToolbarItem(placement: .principal) {
                    // Tappable title that dismisses keyboard
                    Button(action: {
                        hideKeyboard()
                    }) {
                        Text("Movies")
                            .font(.headline)
                            .foregroundColor(DesignSystem.Colors.label)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarButton
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // Dismiss keyboard when tapping anywhere
                hideKeyboard()
            }
            .refreshable {
                await viewModel.refreshMovies()
            }
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie)
            }
        }
        .preferredColorScheme(nil) // Support both light and dark mode
    }

    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.loadingState {
        case .idle, .loading:
            if viewModel.movies.isEmpty {
                LoadingView("Loading amazing movies...")
            } else {
                movieListContent
            }

        case .loaded:
            movieListContent

        case .failed(let error):
            if viewModel.movies.isEmpty {
                ErrorView(
                    viewModel.userFriendlyErrorMessage ?? error.localizedDescription,
                    retryAction: {
                        Task {
                            await viewModel.retryLoading()
                        }
                    }
                )
            } else {
                movieListContent
            }
        }
    }

    // MARK: - Movie List Content
    private var movieListContent: some View {
        VStack(spacing: 0) {
            // Sticky search bar
            SearchBarView(
                text: $viewModel.searchText,
                onSearchButtonClicked: {
                    viewModel.trackSearchPerformed(viewModel.searchText)
                },
                onCancelButtonClicked: {
                    viewModel.clearSearch()
                }
            )
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.xs)
            .background(
                DesignSystem.Colors.background
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            )

            // Search results header removed - count now shown in section

            // Movie grid or empty state
            if viewModel.filteredMovies.isEmpty && !viewModel.searchText.isEmpty {
                // Show no search results but keep search bar at top
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        Spacer(minLength: 40) // Reduced spacing for better connection to search bar

                        NoSearchResultsView(
                            searchTerm: viewModel.searchText,
                            onClearSearch: {
                                viewModel.clearSearch()
                            }
                        )

                        Spacer() // Fill remaining space
                    }
                }
                .onTapGesture {
                    // Dismiss keyboard when tapping in no-results area
                    hideKeyboard()
                }
            } else if viewModel.movies.isEmpty && viewModel.searchText.isEmpty {
                // Only show "No Movies Available" when we have no movies at all AND no search
                // Keep search bar at top by wrapping in ScrollView
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        Spacer(minLength: 40)

                        EmptyStateView(
                            title: "No Movies Available",
                            message: "We couldn't find any movies to display. Please try refreshing.",
                            systemImage: "film",
                            actionTitle: "Refresh",
                            action: {
                                Task {
                                    await viewModel.refreshMovies()
                                }
                            }
                        )

                        Spacer()
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
            } else {
                movieGrid
            }
        }
    }

    // MARK: - Movie Grid
    private var movieGrid: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.lg) {
                // Featured section (liked movies) - only show when not searching
                if !viewModel.likedMovies.isEmpty && viewModel.searchText.isEmpty {
                    featuredSection
                }

                // All movies section
                allMoviesSection
            }
            .padding(.top, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .scrollIndicators(.hidden)
        .onTapGesture {
            // Dismiss keyboard when tapping in scroll area
            hideKeyboard()
        }
    }

    // MARK: - Featured Section
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .center, spacing: DesignSystem.Spacing.sm) {
                Label("Your Favorites", systemImage: "heart.fill")
                    .font(DesignSystem.Typography.sectionTitle)
                    .foregroundColor(DesignSystem.Colors.label)

                // Improved count badge
                Text("\(viewModel.likedMoviesCount)")
                    .font(DesignSystem.Typography.callout.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(minWidth: 24, minHeight: 24)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .background(
                        Capsule()
                            .fill(DesignSystem.Colors.primary)
                    )
                    .scaleEffect(0.9) // Slightly smaller for better proportions

                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)

            MovieCardGridView(
                movies: viewModel.likedMovies,
                likedMovieIds: viewModel.likedMovieIds,
                onMovieTap: { movie in
                    hideKeyboard()
                    selectedMovie = movie
                    viewModel.trackMovieViewed(movie)
                },
                onLikeToggle: { movie in
                    viewModel.toggleLike(for: movie)
                }
            )
        }
    }

    // MARK: - All Movies Section
    private var allMoviesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(viewModel.searchText.isEmpty ? "All Movies" : "Search Results")
                    .font(DesignSystem.Typography.sectionTitle)
                    .foregroundColor(DesignSystem.Colors.label)

                Text(viewModel.searchText.isEmpty ?
                     "\(viewModel.filteredMovies.count) movie\(viewModel.filteredMovies.count == 1 ? "" : "s")" :
                     "\(viewModel.filteredMovies.count) movie\(viewModel.filteredMovies.count == 1 ? "" : "s") for \"\(viewModel.searchText)\""
                )
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryLabel)
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)

            MovieCardGridView(
                movies: viewModel.filteredMovies,
                likedMovieIds: viewModel.likedMovieIds,
                onMovieTap: { movie in
                    hideKeyboard()
                    selectedMovie = movie
                    viewModel.trackMovieViewed(movie)
                },
                onLikeToggle: { movie in
                    viewModel.toggleLike(for: movie)
                }
            )
        }
    }

    // MARK: - Toolbar Button
    private var toolbarButton: some View {
        Menu {
            Button(action: {
                hideKeyboard()
                Task {
                    await viewModel.refreshMovies()
                }
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }

            Divider()

            Button(action: {
                hideKeyboard()
                // Future: Sort options
            }) {
                Label("Sort by Year", systemImage: "calendar")
            }

            Button(action: {
                hideKeyboard()
                // Future: Filter options
            }) {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }

        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .onTapGesture {
            // Dismiss keyboard when toolbar button is tapped
            hideKeyboard()
        }
        .accessibilityLabel("More options")
    }

    // MARK: - Helper Methods

    /// Dismisses the keyboard by ending editing
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Movie List View with Custom Navigation
/// Alternative implementation with custom navigation handling
struct MovieListViewWithNavigation: View {
    @StateObject private var viewModel = MovieListViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            MovieListView()
                .navigationDestination(for: Movie.self) { movie in
                    MovieDetailView(movie: movie)
                }
        }
    }
}

// MARK: - Loading Overlay
/// Overlay shown during refresh operations
struct LoadingOverlay: View {
    let isVisible: Bool

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: DesignSystem.Spacing.md) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)

                    Text("Refreshing...")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(.white)
                }
                .padding(DesignSystem.Spacing.xl)
                .background(Color.black.opacity(0.7))
                .cornerRadius(DesignSystem.CornerRadius.large)
            }
            .transition(.opacity)
            .animation(DesignSystem.Animation.standard, value: isVisible)
        }
    }
}

// MARK: - Pull to Refresh Indicator
/// Custom pull to refresh indicator (iOS 16+ provides built-in support)
struct PullToRefreshView: View {
    let isRefreshing: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if isRefreshing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                    .scaleEffect(0.8)
            }

            Text(isRefreshing ? "Refreshing..." : "Pull to refresh")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryLabel)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.secondaryBackground)
    }
}

// MARK: - Preview
#Preview {
    MovieListView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    MovieListView()
        .preferredColorScheme(.dark)
}
