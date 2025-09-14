import SwiftUI

struct MovieListView: View {
    private let locator: ServiceLocator
    @EnvironmentObject private var likes: LikeStore
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
            Group {
                switch vm.state {
                case .idle, .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .error(let message):
                    ErrorView(message: message) {
                        await vm.load()
                        if vm.sort == .ratingHigh { await vm.ensureRatings() }
                    }

                case .empty:
                    EmptyStateView(text: "No movies found")

                case .loaded:
                    content
                }
            }
            .navigationTitle("Movies")
            .task { await vm.loadIfNeeded() }
            .searchable(
                text: $vm.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search"
            )
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        vm.layout = (vm.layout == .grid ? .list : .grid)
                    } label: {
                        Image(systemName: vm.layout == .grid ? "list.bullet" : "square.grid.2x2")
                    }

                    Button("Filters") {
                        vm.showFilters = true
                    }
                }
            }
            .sheet(isPresented: $vm.showFilters) {
                FiltersSheet(sort: $vm.sort, layout: $vm.layout) {
                    Task { if vm.sort == .ratingHigh { await vm.ensureRatings() } }
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
        if vm.layout == .grid {
            gridContent
        } else {
            listContent
        }
    }

    // Grid
    private var gridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(vm.visibleMovies) { m in
                    NavigationLink(value: m.id) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Poster
                            Poster(url: m.poster, size: 180)

                            // Title + Year
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

                                    LikeButton(isOn: likes.isLiked(m.id)) { likes.toggle(m.id) }
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
                        Button(likes.isLiked(m.id) ? "Unlike" : "Like") { likes.toggle(m.id) }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .refreshable {
            await vm.load()
            if vm.sort == .ratingHigh { await vm.ensureRatings() }
        }
    }

    // List
    private var listContent: some View {
        List(vm.visibleMovies) { m in
            NavigationLink(value: m.id) {
                MovieRow(movie: m, liked: likes.isLiked(m.id))
            }
            .contextMenu {
                Button(likes.isLiked(m.id) ? "Unlike" : "Like") { likes.toggle(m.id) }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await vm.load()
            if vm.sort == .ratingHigh { await vm.ensureRatings() }
        }
    }
}
