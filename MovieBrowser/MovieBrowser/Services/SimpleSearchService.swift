//
//  SimpleSearchService.swift
//  MovieBrowser
//
//  Created by Laurent Lefebvre on 9/9/25.
//  OpenLane iOS Challenge - Simple but Professional Search Service
//

import Foundation

// MARK: - Search Result
struct SimpleSearchResult<T> {
    let item: T
    let relevanceScore: Double
    let matchType: MatchType

    enum MatchType {
        case exact
        case prefix
        case contains
        case fuzzy
    }
}

// MARK: - Searchable Protocol
protocol SimpleSearchable {
    var searchableText: String { get }
    var searchableYear: String? { get }
}

// MARK: - Movie Searchable Conformance
extension Movie: SimpleSearchable {
    var searchableText: String { name }
    var searchableYear: String? { String(year) }
}

// MARK: - Simple Search Service
/// Clean, focused search service with fuzzy matching and typo tolerance
final class SimpleSearchService: @unchecked Sendable {

    // MARK: - Main Search Method
    nonisolated func search<T: SimpleSearchable>(_ items: [T], query: String) -> [SimpleSearchResult<T>] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let lowercaseQuery = trimmedQuery.lowercased()
        var results: [SimpleSearchResult<T>] = []

        for item in items {
            if let result = searchItem(item, query: lowercaseQuery) {
                results.append(result)
            }
        }

        // Sort by relevance score (highest first)
        return results.sorted { $0.relevanceScore > $1.relevanceScore }
    }

    // MARK: - Suggestions
    nonisolated func generateSuggestions<T: SimpleSearchable>(_ items: [T], partialQuery: String) -> [String] {
        let trimmedQuery = partialQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= 2 else { return [] }

        let lowercaseQuery = trimmedQuery.lowercased()
        var suggestions = Set<String>()

        for item in items {
            let searchText = item.searchableText.lowercased()

            // Add suggestions that start with the query
            if searchText.hasPrefix(lowercaseQuery) {
                suggestions.insert(item.searchableText)
            }

            // Add word-based suggestions
            let words = searchText.components(separatedBy: .whitespaces)
            for word in words {
                if word.hasPrefix(lowercaseQuery) && word.count > lowercaseQuery.count {
                    suggestions.insert(word.capitalized)
                }
            }
        }

        return Array(suggestions).sorted().prefix(5).map { $0 }
    }

    // MARK: - Private Methods
    private func searchItem<T: SimpleSearchable>(_ item: T, query: String) -> SimpleSearchResult<T>? {
        let searchText = item.searchableText.lowercased()
        let searchYear = item.searchableYear?.lowercased()

        // 1. Exact match (highest score)
        if searchText == query {
            return SimpleSearchResult(item: item, relevanceScore: 1.0, matchType: .exact)
        }

        // 2. Year match
        if let year = searchYear, year == query {
            return SimpleSearchResult(item: item, relevanceScore: 0.95, matchType: .exact)
        }

        // 3. Prefix match
        if searchText.hasPrefix(query) {
            let score = 0.9 * (Double(query.count) / Double(searchText.count))
            return SimpleSearchResult(item: item, relevanceScore: score, matchType: .prefix)
        }

        // 4. Contains match
        if searchText.contains(query) {
            let score = 0.8 * (Double(query.count) / Double(searchText.count))
            return SimpleSearchResult(item: item, relevanceScore: score, matchType: .contains)
        }

        // 5. Multi-word fuzzy matching (for queries like "hme al" -> "Home Alone")
        if let multiWordScore = multiWordFuzzyMatch(query: query, text: searchText) {
            return SimpleSearchResult(item: item, relevanceScore: multiWordScore, matchType: .fuzzy)
        }

        // 5.5. Single word subsequence matching (for queries like "hme" -> "Home Alone")
        if query.count >= 3 {
            let words = searchText.components(separatedBy: .whitespaces)
            for word in words {
                if isSubsequence(query, in: word.lowercased()) {
                    let score = 0.65 * (Double(query.count) / Double(word.count))
                    if score > 0.4 {
                        return SimpleSearchResult(item: item, relevanceScore: score, matchType: .fuzzy)
                    }
                }
            }
        }

        // 6. Word-based search (including fuzzy matching on words)
        let words = searchText.components(separatedBy: .whitespaces)
        for word in words {
            if word.hasPrefix(query) {
                let score = 0.7 * (Double(query.count) / Double(word.count))
                return SimpleSearchResult(item: item, relevanceScore: score, matchType: .prefix)
            }
            if word.contains(query) {
                let score = 0.6 * (Double(query.count) / Double(word.count))
                return SimpleSearchResult(item: item, relevanceScore: score, matchType: .contains)
            }

            // Fuzzy match on individual words (for typos like "drk" -> "dark")
            if let fuzzyScore = fuzzyMatch(query: query, text: word) {
                return SimpleSearchResult(item: item, relevanceScore: fuzzyScore * 0.8, matchType: .fuzzy)
            }
        }

        // 6. Fuzzy match on full text (for broader typos)
        if let fuzzyScore = fuzzyMatch(query: query, text: searchText) {
            return SimpleSearchResult(item: item, relevanceScore: fuzzyScore * 0.5, matchType: .fuzzy)
        }

        return nil
    }

    // MARK: - Multi-word Fuzzy Matching
    private func multiWordFuzzyMatch(query: String, text: String) -> Double? {
        let queryWords = query.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let textWords = text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

        // Only attempt multi-word matching if query has multiple words
        guard queryWords.count > 1 else { return nil }

        var totalScore = 0.0
        var matchedWords = 0

        for queryWord in queryWords {
            var bestWordScore = 0.0

            for textWord in textWords {
                let queryLower = queryWord.lowercased()
                let textLower = textWord.lowercased()
                let cleanTextLower = textLower.trimmingCharacters(in: .punctuationCharacters)

                // Try exact match first
                if textLower == queryLower || cleanTextLower == queryLower {
                    bestWordScore = max(bestWordScore, 1.0)
                }
                // Try prefix match (handle punctuation)
                else if textLower.hasPrefix(queryLower) || cleanTextLower.hasPrefix(queryLower) {
                    let targetLength = cleanTextLower.isEmpty ? textLower.count : cleanTextLower.count
                    let score = Double(queryLower.count) / Double(targetLength)
                    bestWordScore = max(bestWordScore, score * 0.9)
                }
                // Try contains match (important for "end" in "Endgame")
                else if textLower.contains(queryLower) || cleanTextLower.contains(queryLower) {
                    let targetLength = cleanTextLower.isEmpty ? textLower.count : cleanTextLower.count
                    let score = Double(queryLower.count) / Double(targetLength)
                    bestWordScore = max(bestWordScore, score * 0.8)
                }
                // Try subsequence matching (for "hme" -> "home")
                else if queryLower.count >= 2 && (isSubsequence(queryLower, in: textLower) || isSubsequence(queryLower, in: cleanTextLower)) {
                    let targetLength = cleanTextLower.isEmpty ? textLower.count : cleanTextLower.count
                    let score = Double(queryLower.count) / Double(targetLength)
                    bestWordScore = max(bestWordScore, score * 0.6)
                }
                // Try fuzzy match on individual words
                else if let fuzzyScore = fuzzyMatch(query: queryLower, text: textLower) {
                    bestWordScore = max(bestWordScore, fuzzyScore * 0.5)
                }
                else if let fuzzyScore = fuzzyMatch(query: queryLower, text: cleanTextLower) {
                    bestWordScore = max(bestWordScore, fuzzyScore * 0.5)
                }
            }

            if bestWordScore > 0.1 { // Very low threshold for debugging
                totalScore += bestWordScore
                matchedWords += 1
            }
        }

        // Require at least half the query words to match
        guard matchedWords >= (queryWords.count + 1) / 2 else { return nil }

        let averageScore = totalScore / Double(queryWords.count)
        return averageScore > 0.2 ? averageScore * 0.75 : nil // Very low threshold for debugging
    }

    // MARK: - Subsequence Matching
    private func isSubsequence(_ subsequence: String, in string: String) -> Bool {
        guard !subsequence.isEmpty && !string.isEmpty else { return false }

        let subArray = Array(subsequence)
        let strArray = Array(string)

        var subIndex = 0

        for char in strArray {
            if subIndex < subArray.count && char == subArray[subIndex] {
                subIndex += 1
            }
        }

        return subIndex == subArray.count
    }

    // MARK: - Improved Fuzzy Matching
    private func fuzzyMatch(query: String, text: String) -> Double? {
        // Allow fuzzy matching for shorter queries (was 3, now 2)
        guard query.count >= 2 else { return nil }

        // Allow fuzzy matching even when query is shorter than text (for typos)
        let distance = levenshteinDistance(query, text)
        let maxLength = max(query.count, text.count)

        // More lenient distance allowance, especially for short queries
        let maxAllowedDistance: Int
        switch query.count {
        case 2: maxAllowedDistance = 1  // "dr" -> "dark" (1 insertion)
        case 3: maxAllowedDistance = 2  // "drk" -> "dark" (1 insertion)
        case 4: maxAllowedDistance = 2  // "hme" -> "home" (1 insertion)
        default: maxAllowedDistance = min(3, query.count / 2)
        }

        guard distance <= maxAllowedDistance else { return nil }

        let similarity = 1.0 - (Double(distance) / Double(maxLength))

        // More lenient scoring for short queries with typos
        let minSimilarity: Double
        switch query.count {
        case 2: minSimilarity = 0.3
        case 3: minSimilarity = 0.4
        case 4: minSimilarity = 0.5
        default: minSimilarity = 0.6
        }

        return similarity > minSimilarity ? similarity : nil
    }

    // MARK: - Levenshtein Distance (Simple Implementation)
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let a1 = Array(s1)
        let a2 = Array(s2)

        var dp = Array(repeating: Array(repeating: 0, count: a2.count + 1), count: a1.count + 1)

        for i in 0...a1.count { dp[i][0] = i }
        for j in 0...a2.count { dp[0][j] = j }

        for i in 1...a1.count {
            for j in 1...a2.count {
                if a1[i-1] == a2[j-1] {
                    dp[i][j] = dp[i-1][j-1]
                } else {
                    dp[i][j] = 1 + min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1])
                }
            }
        }

        return dp[a1.count][a2.count]
    }
}

// MARK: - Search Service Protocol
protocol SimpleSearchServiceProtocol: Sendable {
    nonisolated func search<T: SimpleSearchable>(_ items: [T], query: String) -> [SimpleSearchResult<T>]
    nonisolated func generateSuggestions<T: SimpleSearchable>(_ items: [T], partialQuery: String) -> [String]
}

// MARK: - SimpleSearchService Protocol Conformance
extension SimpleSearchService: SimpleSearchServiceProtocol {}
