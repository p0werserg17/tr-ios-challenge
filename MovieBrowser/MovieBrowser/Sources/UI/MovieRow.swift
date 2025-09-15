import SwiftUI

struct MovieRow: View {
    let movie: MovieSummary
    let liked: Bool

    var body: some View {
        HStack(spacing: 12) {
            Poster(url: movie.poster, size: 60)
            VStack(alignment: .leading) {
                Text(movie.title).font(.headline)
                Text(movie.year).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if liked { Image(systemName: "heart.fill") }
        }
        .accessibilityElement(children: .combine)
    }
}
