import SwiftUI

struct RecommendedCarousel: View {
    let movies: [MovieSummary]
    let locator: ServiceLocator

    private let cardWidth: CGFloat = 160
    private let cardPadding: CGFloat = 8
    private var innerWidth: CGFloat { cardWidth - cardPadding * 2 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended")
                .font(.title3.bold())
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(movies) { m in
                        NavigationLink(value: m.id) {
                            VStack(alignment: .leading, spacing: 6) {
                                Poster(url: m.poster, size: innerWidth)

                                Text(m.title)
                                    .font(.subheadline)
                                    .lineLimit(2)
                                    .frame(width: innerWidth, alignment: .leading)

                                Text(m.year)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(cardPadding)
                            .frame(width: cardWidth, alignment: .leading)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

