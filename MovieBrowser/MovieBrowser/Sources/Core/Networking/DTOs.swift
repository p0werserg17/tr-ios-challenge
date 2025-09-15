import Foundation

struct RawMovieListEnvelope: Codable {
    let movies: [RawMovieSummary]?
}

// Elements inside the list/recommended envelopes
struct RawMovieSummary: Codable {
    let id: Int
    let name: String
    let thumbnail: String
    let year: Int
}

struct RawMovieDetails: Codable {
    let id: Int
    let name: String
    let description: String
    let notes: String?
    let rating: Double?
    let picture: String
    let releaseDate: TimeInterval

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description = "Description"
        case notes = "Notes"
        case rating = "Rating"
        case picture
        case releaseDate
    }
}
