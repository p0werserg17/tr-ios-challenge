//
//  FilterStatusView.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Filter Status Indicator
//

import SwiftUI

// MARK: - Filter Chip Type
enum FilterChipType {
    case decade(String)
    case genre(String)
    case rating
    case likedOnly
    case unlikedOnly
    case sort
}

// MARK: - Filter Status View
struct FilterStatusView: View {
    let filterOptions: FilterOptions
    let sortOption: SortOption
    let onClearFilters: () -> Void
    let onRemoveFilter: (FilterChipType) -> Void

    var body: some View {
        if filterOptions.isActive || sortOption != .yearNewest {
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    // Active filters summary
                    HStack(spacing: 8) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.primary)

                        Text(activeFiltersText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.label)
                    }

                    Spacer()

                    // Clear filters button
                    Button("Clear All") {
                        onClearFilters()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                        )
                )

                // Active filter chips
                if filterOptions.isActive || sortOption != .yearNewest {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(activeFilterChipsWithTypes, id: \.text) { chipData in
                                Button(action: {
                                    onRemoveFilter(chipData.type)
                                }) {
                                    HStack(spacing: 4) {
                                        Text(chipData.text)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(DesignSystem.Colors.primary)

                                        Image(systemName: "xmark")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(DesignSystem.Colors.primary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                                            .overlay(
                                                Capsule()
                                                    .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Computed Properties
    private var activeFiltersText: String {
        var components: [String] = []

        if sortOption != .yearNewest {
            components.append("Sorted by \(sortOption.displayName)")
        }

        if filterOptions.activeFiltersCount > 0 {
            components.append("\(filterOptions.activeFiltersCount) filter\(filterOptions.activeFiltersCount == 1 ? "" : "s")")
        }

        return components.joined(separator: " • ")
    }

    private var activeFilterChipsWithTypes: [FilterChipData] {
        var chips: [FilterChipData] = []

        // Sort chip
        if sortOption != .yearNewest {
            chips.append(FilterChipData(text: "Sort: \(sortOption.displayName)", type: .sort))
        }

        // Decade chips
        for decade in filterOptions.selectedDecades.sorted() {
            chips.append(FilterChipData(text: decade, type: .decade(decade)))
        }

        // Genre chips
        for genre in filterOptions.selectedGenres.sorted() {
            chips.append(FilterChipData(text: genre, type: .genre(genre)))
        }

        // Rating chip
        if filterOptions.minRating > 0.0 || filterOptions.maxRating < 10.0 {
            let ratingText: String
            if filterOptions.maxRating == 10.0 {
                ratingText = "Rating: \(Int(filterOptions.minRating))+"
            } else if filterOptions.minRating == filterOptions.maxRating {
                ratingText = "Rating: \(Int(filterOptions.minRating))"
            } else {
                ratingText = "Rating: \(Int(filterOptions.minRating))-\(Int(filterOptions.maxRating))"
            }
            chips.append(FilterChipData(text: ratingText, type: .rating))
        }

        // Liked/Unliked chips
        if filterOptions.showLikedOnly {
            chips.append(FilterChipData(text: "Liked Only", type: .likedOnly))
        } else if filterOptions.showUnlikedOnly {
            chips.append(FilterChipData(text: "Unliked Only", type: .unlikedOnly))
        }

        return chips
    }
}

// MARK: - Filter Chip Data
struct FilterChipData {
    let text: String
    let type: FilterChipType
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // No filters
        FilterStatusView(
            filterOptions: FilterOptions(),
            sortOption: .yearNewest,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )

        // Active filters
        FilterStatusView(
            filterOptions: FilterOptions(
                selectedDecades: ["2010s", "2020s"],
                selectedGenres: ["Action"],
                minRating: 8.0,
                maxRating: 10.0,
                showLikedOnly: true,
                showUnlikedOnly: false
            ),
            sortOption: .liked,
            onClearFilters: {},
            onRemoveFilter: { _ in }
        )
    }
    .background(DesignSystem.Colors.background)
}
