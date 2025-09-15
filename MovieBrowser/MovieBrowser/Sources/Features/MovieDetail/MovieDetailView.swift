import SwiftUI

struct MovieDetailView: View {
    private let locator: ServiceLocator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var vm: MovieDetailViewModel

    @State private var plotCollapsed = true
    @State private var notesCollapsed = true

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
        .task(id: vm.details?.poster) { await vm.updateGradient(for: colorScheme) }
        .task(id: colorScheme) { await vm.updateGradient(for: colorScheme) }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)

        case .error(let message):
            ErrorView(message: message) { await vm.load() }.padding()

        case .empty:
            EmptyStateView(text: "No details").padding()

        case .loaded:
            ScrollView { detailsBody }
                .scrollIndicators(.never)
        }
    }

    private var detailsBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)
                .padding(.bottom, 12)

            VStack(alignment: .leading, spacing: 16) {
                titleRow
                overviewSection
                notesSection
                recommendedSection
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Sections

    private var header: some View {
        PosterHeader(
            poster: vm.details?.poster,
            gradient: vm.gradient,
            onBack: { dismiss() },
            likeButton: AnyView(
                LikeButton(isOn: vm.isCurrentLiked) { vm.toggleCurrentLike() }
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            )
        )
    }

    private var titleRow: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(vm.titleText)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineSpacing(2)
                Text(vm.yearText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let rating = vm.ratingText {
                RatingPill(rating: rating)
            }
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview").font(.headline)
            Text(vm.plotText(collapsed: plotCollapsed))
                .font(.body)
                .foregroundStyle(.primary)
            if vm.needsPlotExpand() {
                Button(plotCollapsed ? "Read more" : "Read less") {
                    withAnimation(.easeInOut) { plotCollapsed.toggle() }
                }
                .font(.callout.weight(.semibold))
                .foregroundStyle(.secondary)
            }
        }
    }

    private var notesSection: some View {
        Group {
            if vm.hasNotes {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes").font(.headline)
                    Text(vm.notesText(collapsed: notesCollapsed))
                        .font(.body)
                        .foregroundStyle(.primary)
                    if vm.needsNotesExpand() {
                        Button(notesCollapsed ? "Show more" : "Show less") {
                            withAnimation(.easeInOut) { notesCollapsed.toggle() }
                        }
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var recommendedSection: some View {
        Group {
            if !vm.recommended.isEmpty {
                RecommendedCarousel(movies: vm.recommended, locator: locator)
            }
        }
    }
}
