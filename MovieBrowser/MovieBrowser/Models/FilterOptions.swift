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
/// These extensions provide computed properties to enable filtering functionality
/// that isn't directly supported by the API data structure.
///
/// **Key Design Challenge:**
/// The provided API has a limitation where the list endpoint only provides basic info
/// (id, name, thumbnail, year) while detailed info (ratings, descriptions) requires
/// individual API calls. This creates a performance vs. accuracy tradeoff for filtering.
extension Movie {
    var decade: String {
        let decade = (year / 10) * 10
        return "\(decade)s"
    }

    /// Estimated genre for filtering purposes
    ///
    /// **Design Tradeoff Discussion:**
    /// Neither the movie list API nor the details API provide genre information.
    /// This creates a challenge for genre-based filtering functionality.
    ///
    /// **Options Considered:**
    /// 1. **Remove genre filtering** - Simplest but reduces functionality
    /// 2. **Use external API** - Adds complexity and dependencies (TMDB, OMDB, etc.)
    /// 3. **Manual genre mapping** - Current approach, works for known movies
    /// 4. **Machine learning classification** - Overkill for this scope
    ///
    /// **Current Choice: Name-based Genre Estimation**
    /// - Pros: Simple, no external dependencies, works for demo
    /// - Cons: Limited accuracy, only works for well-known movies
    /// - Tradeoff: Enables genre filtering demo without API complexity
    var estimatedGenre: String {
        let name = self.name.lowercased()

        if name.contains("avengers") || name.contains("dark knight") || name.contains("matrix") {
            return "Action"
        } else if name.contains("inception") {
            return "Sci-Fi"
        } else if name.contains("home alone") {
            return "Comedy"
        } else {
            return "Drama" // Default fallback
        }
    }

    /// Estimated rating for filtering purposes
    ///
    /// **Design Tradeoff Discussion:**
    /// The movie list API (`/list.json`) only provides basic movie info (id, name, thumbnail, year)
    /// but does NOT include ratings. Ratings are only available in the details API (`/details/{id}.json`).
    ///
    /// **Options Considered:**
    /// 1. **Fetch all details upfront** - Would require N API calls on app launch (expensive, slow)
    /// 2. **Remove rating-based filtering** - Reduces functionality for users
    /// 3. **Use estimated ratings** - Current approach, enables filtering without performance cost
    /// 4. **Hybrid approach** - Fetch ratings on-demand and cache them (complex implementation)
    ///
    /// **Current Choice: Estimated Ratings**
    /// - Pros: Fast filtering, no additional API calls, good UX
    /// - Cons: Not 100% accurate, requires maintenance for new movies
    /// - Tradeoff: Prioritizes performance and UX over perfect data accuracy
    ///
    /// **Future Improvements:**
    /// - Consider adding ratings to the list API response
    /// - Implement progressive enhancement (show estimates, replace with real data when available)
    /// - Add visual indicator that ratings are estimates vs. actual
    var estimatedRating: Double {
        switch id {
        case 1: return 8.4 // Avengers: Endgame (matches API: 8.4)
        case 2: return 7.7 // Home Alone
        case 3: return 8.8 // Inception
        case 4: return 9.0 // The Dark Knight
        case 5: return 8.7 // The Matrix
        default: return Double.random(in: 6.0...9.5) // Fallback for unknown movies
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
