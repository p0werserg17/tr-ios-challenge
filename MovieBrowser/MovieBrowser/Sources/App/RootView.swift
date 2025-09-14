import SwiftUI

struct RootView: View {
    @Environment(\.locator) private var locator
    @EnvironmentObject private var likes: LikeStore

    var body: some View {
        TabView {
            MovieListView(locator: locator).tabItem { Label("Movies", systemImage: "film") }
            FavoritesView(locator: locator).tabItem { Label("Favorites", systemImage: "star.fill") }
        }
    }
}
