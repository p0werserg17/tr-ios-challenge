import Foundation

struct MovieSummary: Identifiable, Codable, Equatable {
    let id: MovieID
    let title: String
    let year: String
    let poster: URL?
}
