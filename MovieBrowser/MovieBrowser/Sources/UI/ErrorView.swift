import SwiftUI

struct ErrorView: View {
    let message: String
    let retry: () async -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Retry") {
                Task { await retry() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
