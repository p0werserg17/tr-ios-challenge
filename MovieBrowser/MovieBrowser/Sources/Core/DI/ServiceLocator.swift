import SwiftUI
import UIKit

final class ServiceLocator {
    let movieService: MovieService
    let likeStore: LikeStore
    let imageLoader: ImageLoader

    init(
        movieService: MovieService,
        likeStore: LikeStore,
        imageLoader: ImageLoader
    ) {
        self.movieService = movieService
        self.likeStore = likeStore
        self.imageLoader = imageLoader
    }

    static func bootstrap() -> ServiceLocator {
        let memoryMB = 64
        let diskMB = 256
        URLCache.shared = URLCache(
            memoryCapacity: memoryMB * 1024 * 1024,
            diskCapacity: diskMB * 1024 * 1024
        )

        let client = URLSessionAPIClient()
        let responseCache = ResponseCache()
        let service = MovieServiceImpl(client: client, cache: responseCache)
        let likes = LikeStore()
        let images = ImageLoader()
        return ServiceLocator(movieService: service, likeStore: likes, imageLoader: images)
    }
}

// Environment injection
private struct LocatorKey: EnvironmentKey {
    static let defaultValue = ServiceLocator.bootstrap()
}

extension EnvironmentValues {
    var locator: ServiceLocator {
        get { self[LocatorKey.self] }
        set { self[LocatorKey.self] = newValue }
    }
}

// Image loader with memory cache + cache-first URL loading
final class ImageLoader {
    private let memory = NSCache<NSURL, UIImage>()

    func image(for url: URL) async -> UIImage? {
        let key = url as NSURL
        if let cached = memory.object(forKey: key) { return cached }

        var req = URLRequest(url: url)
        req.cachePolicy = .returnCacheDataElseLoad
        req.timeoutInterval = 8

        if let img = await loadViaSession(req) {
            memory.setObject(img, forKey: key)
            return img
        }

        if let data = URLCache.shared.cachedResponse(for: req)?.data,
           let img = UIImage(data: data) {
            memory.setObject(img, forKey: key)
            return img
        }
        return nil
    }

    private func loadViaSession(_ req: URLRequest) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}
