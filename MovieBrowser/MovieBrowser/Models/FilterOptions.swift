//
//  FilterOptions.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Advanced Filtering System
//

import Foundation

// MARK: - Sort Options
enum SortOption: String, CaseIterable, Identifiable {
    case yearNewest = "year_newest"
    case yearOldest = "year_oldest"
    case nameAZ = "name_az"
    case nameZA = "name_za"
    case liked = "liked_first"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .yearNewest: return "Newest First"
        case .yearOldest: return "Oldest First"
        case .nameAZ: return "A to Z"
        case .nameZA: return "Z to A"
        case .liked: return "Liked First"
        }
    }

    var icon: String {
        switch self {
        case .yearNewest: return "calendar.badge.minus"
        case .yearOldest: return "calendar.badge.plus"
        case .nameAZ: return "textformat.abc"
        case .nameZA: return "textformat.abc"
        case .liked: return "heart.fill"
        }
    }

    var description: String {
        switch self {
        case .yearNewest: return "Most recent movies first"
        case .yearOldest: return "Oldest movies first"
        case .nameAZ: return "Alphabetical order"
        case .nameZA: return "Reverse alphabetical"
        case .liked: return "Your favorites at the top"
        }
    }
}

// MARK: - Filter Options
struct FilterOptions: Equatable {
    var selectedDecades: Set<String> = []
    var selectedGenres: Set<String> = []
    var minRating: Double = 0.0
    var maxRating: Double = 10.0
    var showLikedOnly: Bool = false
    var showUnlikedOnly: Bool = false

    var isActive: Bool {
        !selectedDecades.isEmpty ||
        !selectedGenres.isEmpty ||
        minRating > 0.0 ||
        maxRating < 10.0 ||
        showLikedOnly ||
        showUnlikedOnly
    }

    var activeFiltersCount: Int {
        var count = 0
        if !selectedDecades.isEmpty { count += 1 }
        if !selectedGenres.isEmpty { count += 1 }
        if minRating > 0.0 || maxRating < 10.0 { count += 1 }
        if showLikedOnly || showUnlikedOnly { count += 1 }
        return count
    }

    mutating func reset() {
        selectedDecades.removeAll()
        selectedGenres.removeAll()
        minRating = 0.0
        maxRating = 10.0
        showLikedOnly = false
        showUnlikedOnly = false
    }
}

// MARK: - Filter Categories
enum FilterCategory: String, CaseIterable {
    case decade = "decade"
    case genre = "genre"
    case rating = "rating"
    case liked = "liked"

    var displayName: String {
        switch self {
        case .decade: return "Decade"
        case .genre: return "Genre"
        case .rating: return "Rating"
        case .liked: return "Favorites"
        }
    }

    var icon: String {
        switch self {
        case .decade: return "calendar"
        case .genre: return "theatermasks"
        case .rating: return "star"
        case .liked: return "heart"
        }
    }
}

// MARK: - Movie Extensions for Filtering
extension Movie {
    var decade: String {
        let decade = (year / 10) * 10
        return "\(decade)s"
    }

    var estimatedGenre: String {
        // Since we don't have genre data, we'll estimate based on movie names
        // This is a simplified approach for demo purposes
        let name = self.name.lowercased()

        if name.contains("avengers") || name.contains("dark knight") || name.contains("matrix") {
            return "Action"
        } else if name.contains("inception") {
            return "Sci-Fi"
        } else if name.contains("home alone") {
            return "Comedy"
        } else {
            return "Drama"
        }
    }

    // Estimated rating based on well-known movies for demo
    var estimatedRating: Double {
        switch id {
        case 1: return 8.4 // Avengers: Endgame
        case 2: return 7.7 // Home Alone
        case 3: return 8.8 // Inception
        case 4: return 9.0 // The Dark Knight
        case 5: return 8.7 // The Matrix
        default: return Double.random(in: 6.0...9.5)
        }
    }
}

// MARK: - Available Filter Values
struct AvailableFilterValues {
    static func decades(from movies: [Movie]) -> [String] {
        let decades = Set(movies.map { $0.decade })
        return decades.sorted { $0 > $1 } // Newest first
    }

    static func genres(from movies: [Movie]) -> [String] {
        let genres = Set(movies.map { $0.estimatedGenre })
        return genres.sorted()
    }

    static let ratingRanges: [(String, Double, Double)] = [
        ("9+ Excellent", 9.0, 10.0),
        ("8+ Great", 8.0, 10.0),
        ("7+ Good", 7.0, 10.0),
        ("6+ Fair", 6.0, 10.0),
        ("All Ratings", 0.0, 10.0)
    ]
}
