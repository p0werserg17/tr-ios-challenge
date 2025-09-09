//
//  SearchBarView.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Search Bar Component
//

import SwiftUI

// MARK: - Search Bar View
/// A customizable search bar component with modern iOS styling
struct SearchBarView: View {

    // MARK: - Properties
    @Binding var text: String
    let placeholder: String
    let onSearchButtonClicked: (() -> Void)?
    let onCancelButtonClicked: (() -> Void)?

    @FocusState private var isFocused: Bool
    @State private var showCancelButton = false

    // MARK: - Initialization
    init(
        text: Binding<String>,
        placeholder: String = "Search movies...",
        onSearchButtonClicked: (() -> Void)? = nil,
        onCancelButtonClicked: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSearchButtonClicked = onSearchButtonClicked
        self.onCancelButtonClicked = onCancelButtonClicked
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Search field container
            searchFieldContainer

            // Cancel button
            if showCancelButton {
                cancelButton
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .animation(DesignSystem.Animation.standard, value: showCancelButton)
        .onChange(of: isFocused) { focused in
            withAnimation(DesignSystem.Animation.standard) {
                showCancelButton = focused
            }
        }
    }

    // MARK: - Search Field Container
    private var searchFieldContainer: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.tertiaryLabel)

            // Text field
            TextField(placeholder, text: $text)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.label)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit {
                    onSearchButtonClicked?()
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)

            // Clear button
            if !text.isEmpty {
                clearButton
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.tertiaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(
                    isFocused ? DesignSystem.Colors.primary : Color.clear,
                    lineWidth: isFocused ? 2 : 0
                )
        )
        .animation(DesignSystem.Animation.quick, value: isFocused)
    }

    // MARK: - Clear Button
    private var clearButton: some View {
        Button(action: clearText) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.tertiaryLabel)
        }
        .buttonStyle(PlainButtonStyle())
        .transition(.scale.combined(with: .opacity))
        .accessibilityLabel("Clear search")
    }

    // MARK: - Cancel Button
    private var cancelButton: some View {
        Button("Cancel") {
            cancelSearch()
        }
        .font(DesignSystem.Typography.body)
        .foregroundColor(DesignSystem.Colors.primary)
        .accessibilityLabel("Cancel search")
    }

    // MARK: - Actions
    private func clearText() {
        // Only clear text, keep search bar focused for continued typing
        text = ""
    }

    private func cancelSearch() {
        // Clear text, dismiss keyboard, and notify parent to reset search state
        text = ""
        isFocused = false
        onCancelButtonClicked?()
    }
}

// MARK: - Search Results View
/// Component to display search results count and filters
struct SearchResultsHeaderView: View {
    let resultCount: Int
    let searchTerm: String
    let onClearSearch: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if !searchTerm.isEmpty {
                    Text("Search Results")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.tertiaryLabel)

                    Text("\(resultCount) movie\(resultCount == 1 ? "" : "s") for \"\(searchTerm)\"")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.label)
                } else {
                    // Show movie count under the section title (not duplicate the title)
                    Text("\(resultCount) movie\(resultCount == 1 ? "" : "s")")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryLabel)
                }
            }

            Spacer()

            if !searchTerm.isEmpty {
                Button("Clear") {
                    onClearSearch()
                }
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Search Suggestions View
/// Component to display search suggestions
struct SearchSuggestionsView: View {
    let suggestions: [String]
    let onSuggestionTap: (String) -> Void

    var body: some View {
        if !suggestions.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(suggestions.prefix(5), id: \.self) { suggestion in
                        SearchSuggestionChip(
                            text: suggestion,
                            onTap: { onSuggestionTap(suggestion) }
                        )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
    }
}

// MARK: - Search Suggestion Chip
/// Individual suggestion chip component
struct SearchSuggestionChip: View {
    let text: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryLabel)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(DesignSystem.Colors.tertiaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.large)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - No Results View
/// Component to display when search returns no results
struct NoSearchResultsView: View {
    let searchTerm: String
    let onClearSearch: () -> Void

    var body: some View {
        EmptyStateView(
            title: "No Results Found",
            message: "No movies match \"\(searchTerm)\". Try a different search term.",
            systemImage: "magnifyingglass",
            actionTitle: "Clear Search",
            action: onClearSearch
        )
        .padding(.top, DesignSystem.Spacing.xxl)
    }
}

// MARK: - Search Filter View
/// Component for additional search filters (future enhancement)
struct SearchFilterView: View {
    @Binding var selectedGenre: String?
    @Binding var selectedDecade: String?

    let genres = ["Action", "Comedy", "Drama", "Horror", "Sci-Fi"]
    let decades = ["2020s", "2010s", "2000s", "1990s", "1980s"]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Filters")
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundColor(DesignSystem.Colors.label)

            // Genre filter
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Genre")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.secondaryLabel)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(genres, id: \.self) { genre in
                            FilterChip(
                                text: genre,
                                isSelected: selectedGenre == genre,
                                onTap: {
                                    selectedGenre = selectedGenre == genre ? nil : genre
                                }
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                }
            }

            // Decade filter
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Decade")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.secondaryLabel)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(decades, id: \.self) { decade in
                            FilterChip(
                                text: decade,
                                isSelected: selectedDecade == decade,
                                onTap: {
                                    selectedDecade = selectedDecade == decade ? nil : decade
                                }
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.md)
    }
}

// MARK: - Filter Chip
/// Individual filter chip component
struct FilterChip: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(
                    isSelected ? .white : DesignSystem.Colors.secondaryLabel
                )
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.tertiaryBackground
                )
                .cornerRadius(DesignSystem.CornerRadius.large)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(DesignSystem.Animation.quick, value: isSelected)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SearchBarView(text: .constant(""))
        SearchBarView(text: .constant("Avengers"))

        SearchResultsHeaderView(
            resultCount: 5,
            searchTerm: "Marvel",
            onClearSearch: {}
        )

        SearchSuggestionsView(
            suggestions: ["Action", "Comedy", "2019", "Marvel"],
            onSuggestionTap: { _ in }
        )

        Spacer()
    }
    .background(DesignSystem.Colors.background)
}
