import XCTest
@testable import MovieBrowser

final class LikeStoreTests: XCTestCase {
    private let key = "liked_movies"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: key)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: key)
        super.tearDown()
    }

    func test_toggle_and_isLiked_and_persistence() {
        let store = LikeStore()
        let id = MovieID(raw: "xyz")
        XCTAssertFalse(store.isLiked(id))

        store.toggle(id)
        XCTAssertTrue(store.isLiked(id))

        let store2 = LikeStore()
        XCTAssertTrue(store2.isLiked(id))
    }
}
