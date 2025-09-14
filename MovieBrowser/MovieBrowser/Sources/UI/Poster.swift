import SwiftUI
import UIKit

enum PosterMode { case fill, fit }

struct Poster: View {
    let url: URL?
    var size: CGFloat? = nil
    var mode: PosterMode = .fill

    @Environment(\.locator) private var locator
    @State private var uiImage: UIImage?

    var body: some View {
        ZStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: mode == .fill ? .fill : .fit)
                    .ifLet(size) { view, s in view.frame(width: s, height: s) }
                    .if(mode == .fill) { $0.clipped() }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                placeholder.redacted(reason: .placeholder)
            }
        }
        .task(id: url) {
            guard let url else { uiImage = nil; return }
            uiImage = await locator.imageLoader.image(for: url)
        }
    }

    private var placeholder: some View {
        Rectangle().fill(.secondary.opacity(0.15))
            .overlay {
                Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary)
            }
            .ifLet(size) { view, s in view.frame(width: s, height: s) }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// Small helper to apply a transform when a value exists
private extension View {
    @ViewBuilder func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition { transform(self) } else { self }
    }
    @ViewBuilder func ifLet<T>(_ value: T?, transform: (Self, T) -> some View) -> some View {
        if let v = value { transform(self, v) } else { self }
    }
}
