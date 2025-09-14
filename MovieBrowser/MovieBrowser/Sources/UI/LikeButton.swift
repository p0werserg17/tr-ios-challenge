import SwiftUI

struct LikeButton: View {
    let isOn: Bool
    let toggle: () -> Void
    var body: some View {
        Button(action: toggle) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .foregroundStyle(.primary)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(isOn ? "Unlike" : "Like")
    }
}
