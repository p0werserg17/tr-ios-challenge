import Foundation

final class MovieServiceImpl: MovieService {
    private let client: APIClient
    private let cache: CacheBox

    init(client: APIClient, cache: CacheBox) {
        self.client = client
        self.cache = cache
    }

    func fetchList() async throws -> [MovieSummary] {
        let url = try Endpoints.list()
        let envelope = try await loadJSON(RawMovieListEnvelope.self, for: url)
        return (envelope.movies ?? []).map(Mapper.summary)
    }

    func fetchDetails(id: MovieID) async throws -> MovieDetails {
        let url = try Endpoints.details(id: id)
        let raw = try await loadJSON(RawMovieDetails.self, for: url)
        return Mapper.details(raw)
    }

    func fetchRecommended(id: MovieID) async throws -> [MovieSummary] {
        let url = try Endpoints.recommended(id: id)
        let envelope = try await loadJSON(RawMovieListEnvelope.self, for: url)
        return (envelope.movies ?? []).map(Mapper.summary)
    }

    // MARK: - Shared decode with simple in-memory cache
    private func loadJSON<T: Decodable>(_ type: T.Type, for url: URL) async throws -> T {
        let key = url.absoluteString

        if let data = cache.data(for: key),
           let decoded = try? JSONDecoder().decode(T.self, from: data) {
            return decoded
        }

        do {
            let (data, response) = try await client.get(url: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw ServiceError.http(code: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                cache.set(data, for: key)
                return decoded
            } catch {
                #if DEBUG
                print("Decoding error for \(url): \(error)")
                #endif
                throw ServiceError.decoding(underlying: error)
            }
        } catch {
            if error.isOffline { throw ServiceError.offline }
            throw error
        }
    }
}
