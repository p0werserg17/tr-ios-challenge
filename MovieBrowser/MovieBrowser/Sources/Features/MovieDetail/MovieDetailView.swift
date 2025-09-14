import SwiftUI

struct MovieDetailView: View {
    private let locator: ServiceLocator
    @EnvironmentObject private var likes: LikeStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var vm: MovieDetailViewModel

    // Show expand/collapse controls only when text is longer than this many characters.
    private let expandThreshold = 100

    @State private var gradient: [Color] = [
        Color(.sRGB, red: 0.12, green: 0.16, blue: 0.18, opacity: 1),
        Color(.sRGB, red: 0.06, green: 0.07, blue: 0.09, opacity: 1)
    ]
    @State private var plotExpanded = false
    @State private var notesExpanded = false

    init(id: MovieID, locator: ServiceLocator) {
        self.locator = locator
        _vm = StateObject(wrappedValue: MovieDetailViewModel(
            id: id,
            service: locator.movieService,
            likes: locator.likeStore
        ))
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            content
        }
        .task { await vm.load() }
        // Recompute gradient when poster or color scheme changes
        .task(id: vm.details?.poster) {
            gradient = await AverageColorProvider.gradientColors(from: vm.details?.poster,
                                                                 colorScheme: colorScheme)
        }
        .task(id: colorScheme) {
            gradient = await AverageColorProvider.gradientColors(from: vm.details?.poster,
                                                                 colorScheme: colorScheme)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .error(let message):
            ErrorView(message: message) {
                await vm.load()
            }
            .padding()

        case .empty:
            EmptyStateView(text: "No details")
                .padding()

        case .loaded:
            if let d = vm.details {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        PosterHeader(
                            poster: d.poster,
                            gradient: gradient,
                            onBack: { dismiss() },
                            likeButton: AnyView(
                                LikeButton(isOn: likes.isLiked(d.id)) { likes.toggle(d.id) }
                                    .padding(10)
                                    .background(.ultraThinMaterial, in: Circle())
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(edges: .top)
                        .padding(.bottom, 12)

                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(d.title)
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .lineSpacing(2)

                                    Text(d.year)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if let rating = d.rating {
                                    RatingPill(rating: rating)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Overview")
                                    .font(.headline)

                                let needsPlotExpand = d.plot.count > expandThreshold
                                Text(needsPlotExpand && !plotExpanded
                                     ? truncated(d.plot, limit: expandThreshold)
                                     : d.plot)
                                    .font(.body)
                                    .foregroundStyle(.primary)

                                if needsPlotExpand {
                                    Button(plotExpanded ? "Read less" : "Read more") {
                                        withAnimation(.easeInOut) { plotExpanded.toggle() }
                                    }
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                }
                            }

                            if let notes = d.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes")
                                        .font(.headline)

                                    let needsNotesExpand = notes.count > expandThreshold
                                    Text(needsNotesExpand && !notesExpanded
                                         ? truncated(notes, limit: expandThreshold)
                                         : notes)
                                        .font(.body)
                                        .foregroundStyle(.primary)

                                    if needsNotesExpand {
                                        Button(notesExpanded ? "Show less" : "Show more") {
                                            withAnimation(.easeInOut) { notesExpanded.toggle() }
                                        }
                                        .font(.callout.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    }
                                }
                            }

                            if !vm.recommended.isEmpty {
                                RecommendedCarousel(movies: vm.recommended, locator: locator)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                }
                .scrollIndicators(.never)
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }

    // MARK: - Truncation helper
    private func truncated(_ text: String, limit: Int) -> String {
        guard text.count > limit else { return text }
        let idx = text.index(text.startIndex, offsetBy: limit)
        let slice = text[..<idx]
        if let lastSpace = slice.lastIndex(of: " ") {
            return String(text[..<lastSpace]) + "…"
        }
        return String(slice) + "…"
    }
}
