import Foundation

enum ViewState: Equatable {
    case idle, loading, loaded, empty, error(String)
}
