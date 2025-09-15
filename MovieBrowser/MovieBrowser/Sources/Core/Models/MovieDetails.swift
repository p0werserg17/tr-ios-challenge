import Foundation

struct MovieDetails: Identifiable, Equatable {
    let id: MovieID
    let title: String
    let year: String
    let plot: String
    let notes: String?
    let poster: URL?
    let rating: String?
}
