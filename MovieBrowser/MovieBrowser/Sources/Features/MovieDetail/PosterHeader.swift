import SwiftUI

struct PosterHeader: View {
    let poster: URL?
    let gradient: [Color]
    let onBack: () -> Void
    let likeButton: AnyView?

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 360)
                .ignoresSafeArea(edges: .top)
                .overlay(
                    Poster(url: poster, mode: .fit)
                        .frame(maxWidth: 360)
                        .padding(.top, 28)
                        .shadow(radius: 10, x: 0, y: 6)
                        .frame(maxWidth: .infinity)
                )
                .overlay(alignment: .bottom) {
                    LinearGradient(colors: [Color(.systemBackground).opacity(0),
                                            Color(.systemBackground)],
                                   startPoint: .top, endPoint: .bottom)
                        .frame(height: 60)
                }

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                }
                .buttonStyle(.plain)
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())

                Spacer()

                likeButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
        }
    }
}
