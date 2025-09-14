import Foundation

enum Endpoints {
    static let base = "https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master"
    static var list: URL { URL(string: base + "/list.json")! }
    static func details(id: MovieID) -> URL { URL(string: base + "/details/\(id.raw).json")! }
    static func recommended(id: MovieID) -> URL { URL(string: base + "/details/recommended/\(id.raw).json")! }
}
