import Foundation

enum ServiceError: Error, LocalizedError {
    case badURL
    case decoding(underlying: Error?)
    case http(code: Int)
    case offline

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL"
        case .decoding(let underlying):
            return "Failed to decode response" + (underlying.map { ": \($0.localizedDescription)" } ?? "")
        case .http(let code):
            return "Network error (\(code))"
        case .offline:
            return "You're offline. Check your connection."
        }
    }
}
