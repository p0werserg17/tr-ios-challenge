import Foundation

protocol CacheBox {
    func data(for key: String) -> Data?
    func set(_ data: Data, for key: String)
}

final class ResponseCache: CacheBox {
    private let cache = NSCache<NSString, NSData>()

    init() {
        cache.totalCostLimit = 4 * 1024 * 1024
    }

    func data(for key: String) -> Data? {
        cache.object(forKey: key as NSString) as Data?
    }

    func set(_ data: Data, for key: String) {
        cache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
    }
}

