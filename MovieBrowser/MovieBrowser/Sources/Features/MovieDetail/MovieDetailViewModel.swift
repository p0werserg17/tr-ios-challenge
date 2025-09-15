import Foundation
import SwiftUI

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published var state: ViewState = .idle
    @Published var details: MovieDetails?
    @Published var recommended: [MovieSummary] = []
    @Published var gradient: [Color] = [
        Color(.sRGB, red: 0.12, green: 0.16, blue: 0.18, opacity: 1),
        Color(.sRGB, red: 0.06, green: 0.07, blue: 0.09, opacity: 1)
    ]

    // Control Text Size
    private let expandThreshold = 100

    private let service: MovieService
    private let likes: LikeStore
    private let id: MovieID

    init(id: MovieID, service: MovieService, likes: LikeStore) {
        self.id = id
        self.service = service
        self.likes = likes
    }


    func load() async {
        state = .loading
        do {
            async let d = service.fetchDetails(id: id)
            async let recs = service.fetchRecommended(id: id)
            let (details, recsValue) = try await (d, recs)
            self.details = details
            self.recommended = recsValue
            state = .loaded
        } catch {
            state = error.isOffline
                ? .error("You're offline. Check your connection.")
                : .error("Something went wrong. Please try again.")
        }
    }


    func updateGradient(for scheme: ColorScheme) async {
        let url = details?.poster
        gradient = await AverageColorProvider.gradientColors(from: url, colorScheme: scheme)
    }


    var isCurrentLiked: Bool {
        guard let id = details?.id else { return false }
        return likes.isLiked(id)
    }

    func toggleCurrentLike() {
        guard let id = details?.id else { return }
        likes.toggle(id)
    }


    var titleText: String { details?.title ?? "" }
    var yearText: String { details?.year ?? "" }
    var ratingText: String? { details?.rating }

    var plotTextFull: String { details?.plot ?? "" }
    var notesTextFull: String? { details?.notes }

    var hasNotes: Bool {
        guard let notes = details?.notes else { return false }
        return !notes.isEmpty
    }

    func needsPlotExpand() -> Bool {
        plotTextFull.count > expandThreshold
    }

    func needsNotesExpand() -> Bool {
        (notesTextFull ?? "").count > expandThreshold
    }

    func plotText(collapsed: Bool) -> String {
        guard collapsed, needsPlotExpand() else { return plotTextFull }
        return truncated(plotTextFull, limit: expandThreshold)
    }

    func notesText(collapsed: Bool) -> String {
        guard let notes = notesTextFull else { return "" }
        guard collapsed, needsNotesExpand() else { return notes }
        return truncated(notes, limit: expandThreshold)
    }

    private func truncated(_ text: String, limit: Int) -> String {
        guard text.count > limit else { return text }
        let idx = text.index(text.startIndex, offsetBy: limit)
        let slice = text[..<idx]
        if let lastSpace = slice.lastIndex(of: " ") {
            return String(text[..<lastSpace]) + "…"
        }
        return String(slice) + "…"
    }
}
