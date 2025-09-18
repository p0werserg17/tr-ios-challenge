import Foundation

enum Endpoints {

    private static let baseString = "https://raw.githubusercontent.com/p0werserg17/tr-ios-challenge/master"

    static func list() throws -> URL {
        try build(path: "/list.json")
    }

    static func details(id: MovieID) throws -> URL {
        try build(path: "/details/\(id.raw).json")
    }

    static func recommended(id: MovieID) throws -> URL {
        try build(path: "/details/recommended/\(id.raw).json")
    }

    private static func build(path: String) throws -> URL {
        guard var comps = URLComponents(string: baseString) else {
            throw ServiceError.badURL
        }
        comps.path = (comps.path as NSString).appending(path)
        guard let url = comps.url else {
            throw ServiceError.badURL
        }
        return url
    }
}
