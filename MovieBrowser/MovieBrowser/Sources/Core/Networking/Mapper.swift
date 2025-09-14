import Foundation

enum Mapper {
    static func summary(_ raw: RawMovieSummary) -> MovieSummary {
        MovieSummary(
            id: MovieID(raw: String(raw.id)),
            title: raw.name,
            year: String(raw.year),
            poster: URL(string: raw.thumbnail)
        )
    }

    static func details(_ raw: RawMovieDetails) -> MovieDetails {
        MovieDetails(
            id: MovieID(raw: String(raw.id)),
            title: raw.name,
            year: yearString(from: raw.releaseDate) ?? "",
            plot: raw.description,
            notes: raw.notes,
            poster: URL(string: raw.picture),
            rating: raw.rating.map { String(format: "%.1f", $0) }
        )
    }

    private static func yearString(from epochSeconds: TimeInterval) -> String? {
        let date = Date(timeIntervalSince1970: epochSeconds)
        return Calendar.current.dateComponents([.year], from: date).year.map(String.init)
    }
}
