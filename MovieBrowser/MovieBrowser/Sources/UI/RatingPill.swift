import SwiftUI

public struct RatingPill: View {
    public let rating: String

    public init(rating: String) { self.rating = rating }

    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
            Text(rating)
        }
        .font(.callout.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(.yellow)
        .background(.thinMaterial, in: Capsule())
        .accessibilityLabel("Rating \(rating) out of 10")
    }
}
