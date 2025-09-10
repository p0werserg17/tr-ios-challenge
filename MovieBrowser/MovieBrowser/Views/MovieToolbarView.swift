//
//  MovieToolbarView.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Professional Movie Toolbar
//

import SwiftUI

// MARK: - Movie Toolbar View
struct MovieToolbarView: View {
    let filterOptions: FilterOptions
    let sortOption: SortOption
    let filteredCount: Int
    let totalCount: Int
    let onFilterTap: () -> Void
    let onSortTap: () -> Void

    var body: some View {
        HStack {
            Spacer()

            // Single Sort & Filter Button
            singleFilterSortButton
                .fixedSize() // Prevent expanding beyond intrinsic size
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }


    // MARK: - Single Sort & Filter Button
    private var singleFilterSortButton: some View {
        Button(action: onFilterTap) {
            HStack(spacing: 8) {
                // Icon with badge
                ZStack {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(filterOptions.isActive || sortOption != .yearNewest ? DesignSystem.Colors.primary : DesignSystem.Colors.label)

                    // Active state badge
                    if filterOptions.isActive || sortOption != .yearNewest {
                        VStack {
                            HStack {
                                Spacer()
                                Circle()
                                    .fill(DesignSystem.Colors.error)
                                    .frame(width: 6, height: 6)
                                    .offset(x: 3, y: -3)
                            }
                            Spacer()
                        }
                    }
                }

                Text("Sort & Filter")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(filterOptions.isActive || sortOption != .yearNewest ? DesignSystem.Colors.primary : DesignSystem.Colors.label)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(filterOptions.isActive || sortOption != .yearNewest ?
                          DesignSystem.Colors.primary.opacity(0.1) :
                          DesignSystem.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(filterOptions.isActive || sortOption != .yearNewest ?
                                   DesignSystem.Colors.primary :
                                   DesignSystem.Colors.separator,
                                   lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // No filters active
        MovieToolbarView(
            filterOptions: FilterOptions(),
            sortOption: .yearNewest,
            filteredCount: 42,
            totalCount: 42,
            onFilterTap: {},
            onSortTap: {}
        )

        // Filters active
        MovieToolbarView(
            filterOptions: FilterOptions(
                selectedDecades: ["2010s"],
                selectedGenres: ["Action"],
                minRating: 8.0,
                maxRating: 10.0,
                showLikedOnly: false,
                showUnlikedOnly: false
            ),
            sortOption: .liked,
            filteredCount: 12,
            totalCount: 42,
            onFilterTap: {},
            onSortTap: {}
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
}
