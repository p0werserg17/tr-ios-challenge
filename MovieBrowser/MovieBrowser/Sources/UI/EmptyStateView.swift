import SwiftUI

struct EmptyStateView: View {
    let text: String
    var body: some View {
        Text(text)
            .foregroundStyle(.secondary)
            .padding()
    }
}
