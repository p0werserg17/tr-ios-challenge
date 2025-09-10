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
    @State private var showingFilterView = false
    @State private var isFavoritesSectionCollapsed = false

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
            .toolbar(content: toolbarContent)
            .contentShape(Rectangle())
            .onTapGesture {
                // Dismiss keyboard when tapping anywhere
                hideKeyboard()
            }
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie)
            }
            .sheet(isPresented: $showingFilterView) {
                FilterView(
                    filterOptions: $viewModel.filterOptions,
                    sortOption: $viewModel.sortOption,
                    movies: viewModel.movies,
                    onApply: {
                        // Auto-collapse favorites when filters/sorting are applied
                        DispatchQueue.main.async {
                            if viewModel.filterOptions.isActive || viewModel.sortOption != .yearNewest {
                                isFavoritesSectionCollapsed = true
                            }
                        }
                    },
                    onReset: {
                        DispatchQueue.main.async {
                            viewModel.resetFilters()
                        }
                    }
                )
            }
            .onChange(of: viewModel.filterOptions) { newFilterOptions in
                // Auto-collapse favorites when filters are applied
                if newFilterOptions.isActive {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isFavoritesSectionCollapsed = true
                    }
                }
            }
            .onChange(of: viewModel.sortOption) { newSortOption in
                // Auto-collapse favorites when custom sorting is applied
                if newSortOption != .yearNewest {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isFavoritesSectionCollapsed = true
                    }
                }
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
            // Non-refreshable top section
            topSection

            // Refreshable movie content
            refreshableMovieContent
        }
    }

    // MARK: - Top Section (Non-refreshable)
    private var topSection: some View {
        VStack(spacing: 0) {
            // Sticky search bar
            SearchBarView(
                text: $viewModel.searchText,
                onSearchButtonClicked: {
                    let searchText = viewModel.searchText
                    viewModel.trackSearchPerformed(searchText)
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

            // Professional Toolbar
            MovieToolbarView(
                filterOptions: viewModel.filterOptions,
                sortOption: viewModel.sortOption,
                filteredCount: viewModel.filteredMovies.count,
                totalCount: viewModel.movies.count,
                onFilterTap: {
                    hideKeyboard()
                    showingFilterView = true
                },
                onSortTap: {
                    hideKeyboard()
                    showingFilterView = true
                }
            )
            .padding(.top, 2)
            .padding(.bottom, 4)

            // Filter Status (when active) - NON-REFRESHABLE
            FilterStatusView(
                filterOptions: viewModel.filterOptions,
                sortOption: viewModel.sortOption,
                onClearFilters: {
                    DispatchQueue.main.async {
                        viewModel.resetFilters()
                    }
                },
                onRemoveFilter: { chipType in
                    removeSpecificFilter(chipType)
                }
            )
        }
    }

    // MARK: - Refreshable Movie Content
    private var refreshableMovieContent: some View {
        Group {
            // Movie grid or empty state
            if viewModel.filteredMovies.isEmpty && !viewModel.searchText.isEmpty {
                // Show no search results but keep search bar at top
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        Spacer(minLength: 40) // Reduced spacing for better connection to search bar

                        NoSearchResultsView(
                            searchTerm: viewModel.searchText,
                            onClearSearch: {
                                DispatchQueue.main.async {
                                    viewModel.clearSearch()
                                }
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
        .refreshable {
            await viewModel.refreshMovies()
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
            // Collapsible header
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isFavoritesSectionCollapsed.toggle()
                }
            }) {
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

                    // Collapsible chevron arrow
                    Image(systemName: isFavoritesSectionCollapsed ? "chevron.down" : "chevron.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.secondaryLabel)
                        .animation(.easeInOut(duration: 0.2), value: isFavoritesSectionCollapsed)
                }
                .contentShape(Rectangle()) // Make entire header tappable
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)

            // Collapsible content
            if !isFavoritesSectionCollapsed {
                MovieCardGridView(
                    movies: viewModel.likedMovies,
                    likedMovieIds: viewModel.likedMovieIds,
                    onMovieTap: { movie in
                        hideKeyboard()
                        selectedMovie = movie
                        DispatchQueue.main.async {
                            viewModel.trackMovieViewed(movie)
                        }
                    },
                    onLikeToggle: { movie in
                        DispatchQueue.main.async {
                            viewModel.toggleLike(for: movie)
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
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
                    DispatchQueue.main.async {
                        viewModel.trackMovieViewed(movie)
                    }
                },
                onLikeToggle: { movie in
                    DispatchQueue.main.async {
                        viewModel.toggleLike(for: movie)
                    }
                }
            )
        }
    }


    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            // Invisible button to catch taps on title area
            Button(action: {
                hideKeyboard()
            }) {
                Color.clear
                    .frame(width: 100, height: 44)
            }
            .buttonStyle(PlainButtonStyle())
        }

        ToolbarItemGroup(placement: .principal) {
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

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: {
                hideKeyboard()
            }) {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            .opacity(0) // Hidden but keeps layout
        }
    }

    // MARK: - Helper Methods

    /// Dismisses the keyboard by ending editing
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Removes a specific filter based on chip type
    private func removeSpecificFilter(_ chipType: FilterChipType) {
        var updatedFilterOptions = viewModel.filterOptions
        var updatedSortOption = viewModel.sortOption

        switch chipType {
        case .decade(let decade):
            updatedFilterOptions.selectedDecades.remove(decade)
        case .genre(let genre):
            updatedFilterOptions.selectedGenres.remove(genre)
        case .rating:
            updatedFilterOptions.minRating = 0.0
            updatedFilterOptions.maxRating = 10.0
        case .likedOnly:
            updatedFilterOptions.showLikedOnly = false
        case .unlikedOnly:
            updatedFilterOptions.showUnlikedOnly = false
        case .sort:
            updatedSortOption = .yearNewest
        }

        // Update the view model
        viewModel.updateFilterOptions(updatedFilterOptions)
        viewModel.updateSortOption(updatedSortOption)
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
