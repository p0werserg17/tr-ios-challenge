import Foundation

extension Error {
    var isOffline: Bool {
        if let se = self as? ServiceError {
            if case .offline = se { return true }
        }
        
        if let urlErr = self as? URLError {
            switch urlErr.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                return true
            default:
                break
            }
        }

        let ns = self as NSError
        if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? Error, underlying.isOffline {
            return true
        }

        return false
    }
}
