import SwiftUI

struct FavoritesView: View {
    private let locator: ServiceLocator
    @EnvironmentObject private var likes: LikeStore
    @State private var list: [MovieSummary] = []
    @State private var loading = false
    @State private var error: String?

    init(locator: ServiceLocator) { self.locator = locator }

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error {
                    ErrorView(message: error) {
                        await load()
                    }
                } else if filtered.isEmpty {
                    EmptyStateView(text: "No favorites yet")
                } else {
                    favoriteList
                }
            }
            .navigationTitle("Favorites")
            .task { await load() }
            .navigationDestination(for: MovieID.self) { id in
                MovieDetailView(id: id, locator: locator)
            }
        }
    }

    private var filtered: [MovieSummary] {
        list.filter { likes.isLiked($0.id) }
            .sorted { $0.title < $1.title }
    }
    
    private var favoriteList: some View {
        List(filtered) { m in
            NavigationLink(value: m.id) {
                MovieRow(movie: m, liked: true)
            }
        }
        .listStyle(.plain)
    }

    private func load() async {
        loading = true; defer { loading = false }
        do {
            list = try await locator.movieService.fetchList()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
