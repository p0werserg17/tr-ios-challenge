import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case titleAZ = "Title (A–Z)"
    case titleZA = "Title (Z–A)"
    case yearNewest = "Year (Newest)"
    case yearOldest = "Year (Oldest)"
    case ratingHigh = "Rating (High→Low)"
    var id: String { rawValue }
}

enum LayoutMode: String, CaseIterable, Identifiable {
    case grid
    case list
    var id: String { rawValue }
}
