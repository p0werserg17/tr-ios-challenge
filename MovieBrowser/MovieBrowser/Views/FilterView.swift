//
//  FilterView.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Professional Filter Interface
//

import SwiftUI

// MARK: - Filter View
struct FilterView: View {
    @Binding var filterOptions: FilterOptions
    @Binding var sortOption: SortOption
    let movies: [Movie]
    let onApply: () -> Void
    let onReset: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var tempFilterOptions: FilterOptions
    @State private var tempSortOption: SortOption

    init(filterOptions: Binding<FilterOptions>, sortOption: Binding<SortOption>, movies: [Movie], onApply: @escaping () -> Void, onReset: @escaping () -> Void) {
        self._filterOptions = filterOptions
        self._sortOption = sortOption
        self.movies = movies
        self.onApply = onApply
        self.onReset = onReset
        self._tempFilterOptions = State(initialValue: filterOptions.wrappedValue)
        self._tempSortOption = State(initialValue: sortOption.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with handle
            headerView

            // Content
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Sort Section
                    sortSection

                    Divider()
                        .padding(.horizontal, 24)

                    // Filter Sections
                    decadeSection
                    genreSection
                    ratingSection
                    favoritesSection
                }
                .padding(.vertical, 24)
            }

            // Action Buttons
            actionButtons
        }
        .background(DesignSystem.Colors.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 16) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            // Title and close
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sort & Filter")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.label)

                    if tempFilterOptions.isActive {
                        Text("\(tempFilterOptions.activeFiltersCount) filter\(tempFilterOptions.activeFiltersCount == 1 ? "" : "s") active")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.primary)
                    } else {
                        Text("Customize your movie list")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.secondaryLabel)
                    }
                }

                Spacer()

                // Reset button
                Button("Reset") {
                    tempFilterOptions.reset()
                    tempSortOption = .yearNewest
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(hasActiveFiltersOrSort ? DesignSystem.Colors.primary : DesignSystem.Colors.secondaryLabel)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
        }
        .background(DesignSystem.Colors.background)
    }

    // MARK: - Sort Section
    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Sort", icon: "arrow.up.arrow.down")

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(SortOption.allCases) { option in
                    sortOptionCard(option)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func sortOptionCard(_ option: SortOption) -> some View {
        Button(action: {
            tempSortOption = option
        }) {
            VStack(spacing: 8) {
                Image(systemName: option.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(tempSortOption == option ? DesignSystem.Colors.primary : DesignSystem.Colors.secondaryLabel)

                VStack(spacing: 2) {
                    Text(option.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.label)

                    Text(option.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.tertiaryLabel)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(tempSortOption == option ?
                          DesignSystem.Colors.primary.opacity(0.1) :
                          DesignSystem.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(tempSortOption == option ?
                                   DesignSystem.Colors.primary :
                                   Color.clear,
                                   lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Decade Section
    private var decadeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Decade", icon: "calendar")

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(AvailableFilterValues.decades(from: movies), id: \.self) { decade in
                    filterChip(
                        title: decade,
                        isSelected: tempFilterOptions.selectedDecades.contains(decade)
                    ) {
                        if tempFilterOptions.selectedDecades.contains(decade) {
                            tempFilterOptions.selectedDecades.remove(decade)
                        } else {
                            tempFilterOptions.selectedDecades.insert(decade)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Genre Section
    private var genreSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Genre", icon: "theatermasks")

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(AvailableFilterValues.genres(from: movies), id: \.self) { genre in
                    filterChip(
                        title: genre,
                        isSelected: tempFilterOptions.selectedGenres.contains(genre)
                    ) {
                        if tempFilterOptions.selectedGenres.contains(genre) {
                            tempFilterOptions.selectedGenres.remove(genre)
                        } else {
                            tempFilterOptions.selectedGenres.insert(genre)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Rating Section
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Minimum Rating", icon: "star")

            VStack(spacing: 12) {
                ForEach(AvailableFilterValues.ratingRanges, id: \.0) { range in
                    let (title, minRating, maxRating) = range

                    Button(action: {
                        tempFilterOptions.minRating = minRating
                        tempFilterOptions.maxRating = maxRating
                    }) {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.yellow)

                                Text(title)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(DesignSystem.Colors.label)
                            }

                            Spacer()

                            if tempFilterOptions.minRating == minRating && tempFilterOptions.maxRating == maxRating {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(DesignSystem.Colors.primary)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(DesignSystem.Colors.tertiaryLabel)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(tempFilterOptions.minRating == minRating && tempFilterOptions.maxRating == maxRating ?
                                      DesignSystem.Colors.primary.opacity(0.1) :
                                      DesignSystem.Colors.secondaryBackground)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Favorites Section
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Favorites", icon: "heart")

            VStack(spacing: 12) {
                favoriteToggle("Show only liked movies", isOn: $tempFilterOptions.showLikedOnly) {
                    if tempFilterOptions.showLikedOnly {
                        tempFilterOptions.showUnlikedOnly = false
                    }
                }

                favoriteToggle("Show only unliked movies", isOn: $tempFilterOptions.showUnlikedOnly) {
                    if tempFilterOptions.showUnlikedOnly {
                        tempFilterOptions.showLikedOnly = false
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func favoriteToggle(_ title: String, isOn: Binding<Bool>, onToggle: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.label)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .onChange(of: isOn.wrappedValue) { newValue in
                    if newValue {
                        onToggle()
                    }
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.secondaryBackground)
        )
    }

    // MARK: - Helper Views
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)

            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DesignSystem.Colors.label)
        }
        .padding(.horizontal, 24)
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.label)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ?
                              DesignSystem.Colors.primary.opacity(0.1) :
                              DesignSystem.Colors.secondaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ?
                                       DesignSystem.Colors.primary :
                                       Color.clear,
                                       lineWidth: 1.5)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Divider()

            HStack(spacing: 16) {
                // Cancel Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.secondaryLabel)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(DesignSystem.Colors.secondaryBackground)
                        )
                }
                .buttonStyle(PlainButtonStyle())

                // Apply Button
                Button(action: applyFilters) {
                    Text("Apply Filters")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(DesignSystem.Colors.primary)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .background(DesignSystem.Colors.background)
    }

    // MARK: - Computed Properties
    private var hasActiveFiltersOrSort: Bool {
        tempFilterOptions.isActive || tempSortOption != .yearNewest
    }

    // MARK: - Actions
    private func applyFilters() {
        filterOptions = tempFilterOptions
        sortOption = tempSortOption
        onApply()
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    FilterView(
        filterOptions: .constant(FilterOptions()),
        sortOption: .constant(.yearNewest),
        movies: Movie.sampleMovies,
        onApply: {},
        onReset: {}
    )
}
