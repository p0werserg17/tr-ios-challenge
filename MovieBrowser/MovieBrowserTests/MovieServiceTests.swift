import XCTest
@testable import MovieBrowser

final class MovieServiceTests: XCTestCase {

    // MARK: - Sample JSON

    private let listJSON = """
    {
      "movies": [
        { "id": 1, "name": "Inception",   "thumbnail": "https://example.com/inception.jpg",   "year": 2010 },
        { "id": 2, "name": "Interstellar", "thumbnail": "https://example.com/interstellar.jpg", "year": 2014 }
      ]
    }
    """.data(using: .utf8)!

    private let detailsJSON = """
    {
      "id": 1,
      "name": "Inception",
      "Description": "Dream heist.",
      "Notes": "Some production note.",
      "Rating": 8.7,
      "picture": "https://example.com/inception-big.jpg",
      "releaseDate": 1279238400
    }
    """.data(using: .utf8)!

    private let recommendedJSON = """
    {
      "movies": [
        { "id": 2, "name": "Interstellar", "thumbnail": "https://example.com/interstellar.jpg", "year": 2014 }
      ]
    }
    """.data(using: .utf8)!

    // MARK: - Test doubles

    private final class MockClient: APIClient {
        let map: [String: (Data, Int)]
        init(map: [String: (Data, Int)]) { self.map = map }
        func get(url: URL) async throws -> (Data, URLResponse) {
            if let (data, code) = map[url.absoluteString] {
                let resp = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
                return (data, resp)
            } else {
                throw URLError(.notConnectedToInternet)
            }
        }
    }

    private final class SpyCache: CacheBox {
        private(set) var setKeys: [String] = []
        private var storage: [String: Data] = [:]
        func data(for key: String) -> Data? { storage[key] }
        func set(_ data: Data, for key: String) { storage[key] = data; setKeys.append(key) }
    }

    // MARK: - URL helpers (avoid scattering try everywhere)

    private func listURLString() throws -> String {
        try Endpoints.list().absoluteString
    }
    private func detailsURLString(id: MovieID) throws -> String {
        try Endpoints.details(id: id).absoluteString
    }
    private func recommendedURLString(id: MovieID) throws -> String {
        try Endpoints.recommended(id: id).absoluteString
    }

    // MARK: - Tests

    func test_fetchList_decodes_and_caches() async throws {
        let cache = SpyCache()
        let listURL = try listURLString()
        let client = MockClient(map: [listURL: (listJSON, 200)])
        let svc = MovieServiceImpl(client: client, cache: cache)

        let list = try await svc.fetchList()

        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list[0].title, "Inception")
        XCTAssertEqual(list[0].year, "2010")
        XCTAssertFalse(cache.setKeys.isEmpty) // verify caching occurred
    }

    func test_fetchDetails_uses_cache_when_offline() async throws {
        let cache = SpyCache()
        let id = MovieID(raw: "1")
        let detailsURL = try detailsURLString(id: id)

        // 1) Online first to populate cache
        let onlineClient = MockClient(map: [detailsURL: (detailsJSON, 200)])
        let onlineSvc = MovieServiceImpl(client: onlineClient, cache: cache)
        _ = try await onlineSvc.fetchDetails(id: id)

        // 2) Offline now, should hit cache
        let offlineClient = MockClient(map: [:]) // triggers offline
        let offlineSvc = MovieServiceImpl(client: offlineClient, cache: cache)
        let d = try await offlineSvc.fetchDetails(id: id)

        XCTAssertEqual(d.title, "Inception")
        XCTAssertEqual(d.rating, "8.7")
    }

    func test_http_error_maps_to_service_error_http() async throws {
        let cache = SpyCache()
        let listURL = try listURLString()
        let client = MockClient(map: [listURL: (Data(), 500)])
        let svc = MovieServiceImpl(client: client, cache: cache)

        do {
            _ = try await svc.fetchList()
            XCTFail("Expected to throw")
        } catch let err as ServiceError {
            if case .http(let code) = err {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected .http, got \(err)")
            }
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func test_fetchRecommended_decodes_envelope() async throws {
        let cache = SpyCache()
        let id = MovieID(raw: "1")
        let recURL = try recommendedURLString(id: id)

        let client = MockClient(map: [recURL: (recommendedJSON, 200)])
        let svc = MovieServiceImpl(client: client, cache: cache)

        let recs = try await svc.fetchRecommended(id: id)

        XCTAssertEqual(recs.count, 1)
        XCTAssertEqual(recs.first?.title, "Interstellar")
        XCTAssertEqual(recs.first?.year, "2014")
    }
}
