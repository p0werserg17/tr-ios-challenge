import Foundation

protocol APIClient {
    func get(url: URL) async throws -> (Data, URLResponse)
}

final class URLSessionAPIClient: APIClient {
    private let session: URLSession

    init() {
        let cfg = URLSessionConfiguration.default
        cfg.waitsForConnectivity = true
        cfg.timeoutIntervalForRequest = 15
        cfg.timeoutIntervalForResource = 30
        cfg.requestCachePolicy = .useProtocolCachePolicy
        cfg.allowsConstrainedNetworkAccess = true
        cfg.allowsExpensiveNetworkAccess = true
        self.session = URLSession(configuration: cfg)
    }

    func get(url: URL) async throws -> (Data, URLResponse) {
        var req = URLRequest(url: url)
        req.cachePolicy = .reloadRevalidatingCacheData
        req.timeoutInterval = 15
        return try await session.data(for: req)
    }
}
