import SwiftUI

struct RecommendedCard: View {
    let movie: MovieSummary
    let liked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Poster(url: movie.poster, size: 120)
            Text(movie.title).font(.caption).lineLimit(2)
            HStack {
                if liked { Image(systemName: "heart.fill") }
                Text(movie.year).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .frame(width: 140)
    }
}
