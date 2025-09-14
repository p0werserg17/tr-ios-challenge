import XCTest
import UIKit
@testable import MovieBrowser

final class ImageLoaderTests: XCTestCase {

    func test_imageLoader_returns_cached_image_without_network() async {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 1)
        UIColor.red.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let pngData = UIGraphicsGetImageFromCurrentImageContext()?.pngData()
        UIGraphicsEndImageContext()
        XCTAssertNotNil(pngData)

        let url = URL(string: "https://example.com/red.png")!
        var req = URLRequest(url: url)
        req.cachePolicy = .returnCacheDataDontLoad
        let resp = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let cached = CachedURLResponse(response: resp, data: pngData!)
        URLCache.shared.storeCachedResponse(cached, for: req)

        let loader = ImageLoader()
        let img = await loader.image(for: url)

        XCTAssertNotNil(img, "Expected image from cache without network")
        XCTAssertEqual(img?.size, CGSize(width: 1, height: 1))
    }
}
