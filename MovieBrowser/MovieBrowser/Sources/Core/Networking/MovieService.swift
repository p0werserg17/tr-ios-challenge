import Foundation

protocol MovieService {
    func fetchList() async throws -> [MovieSummary]
    func fetchDetails(id: MovieID) async throws -> MovieDetails
    func fetchRecommended(id: MovieID) async throws -> [MovieSummary]
}
