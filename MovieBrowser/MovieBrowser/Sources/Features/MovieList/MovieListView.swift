import SwiftUI

struct MovieListView: View {
    private let locator: ServiceLocator
    @StateObject private var vm: MovieListViewModel

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    init(locator: ServiceLocator) {
        self.locator = locator
        _vm = StateObject(
            wrappedValue: MovieListViewModel(service: locator.movieService,
                                             likes: locator.likeStore)
        )
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Movies")
                .task { await vm.loadIfNeeded() }
                .searchable(
                    text: $vm.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { vm.toggleLayout() }) {
                            Image(systemName: vm.layoutIconName)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Filters") { vm.showFilters = true }
                    }
                }
                .sheet(isPresented: $vm.showFilters) {
                    FiltersSheet(sort: $vm.sort, layout: $vm.layout) {
                        Task { await vm.onFiltersApplied() }
                        vm.showFilters = false
                    }
                    .presentationDetents([.medium, .large])
                }
                .overlay(alignment: .top) {
                    if vm.isFetchingRatings {
                        ProgressView("Loading ratings…")
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.top, 8)
                    }
                }
                .navigationDestination(for: MovieID.self) { id in
                    MovieDetailView(id: id, locator: locator)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)

        case .error(let message):
            ErrorView(message: message) {
                await vm.retryAfterError()
            }

        case .empty:
            EmptyStateView(text: "No movies found")

        case .loaded:
            if vm.layout == .grid { gridContent } else { listContent }
        }
    }

    private var gridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(vm.visibleMovies) { m in
                    NavigationLink(value: m.id) {
                        VStack(alignment: .leading, spacing: 8) {
                            Poster(url: m.poster, size: 180)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(m.title)
                                    .font(.headline)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 44)
                                HStack {
                                    Text(m.year)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    LikeButton(isOn: vm.isLiked(m.id)) { vm.toggleLike(m.id) }
                                        .padding(6)
                                        .shadow(radius: 1, x: 0, y: 1)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(6)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .contextMenu {
                        Button(vm.isLiked(m.id) ? "Unlike" : "Like") { vm.toggleLike(m.id) }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .refreshable { await vm.refreshRespectingSort() }
    }

    private var listContent: some View {
        List(vm.visibleMovies) { m in
            NavigationLink(value: m.id) {
                MovieRow(movie: m, liked: vm.isLiked(m.id))
            }
            .contextMenu {
                Button(vm.isLiked(m.id) ? "Unlike" : "Like") { vm.toggleLike(m.id) }
            }
        }
        .listStyle(.plain)
        .refreshable { await vm.refreshRespectingSort() }
    }
}
