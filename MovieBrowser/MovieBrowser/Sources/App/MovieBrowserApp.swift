import SwiftUI

@main
struct MovieBrowserApp: App {
    @State private var locator = ServiceLocator.bootstrap()

    var body: some Scene {
        WindowGroup {
            RootView()
              .environment(\.locator, locator)
              .environmentObject(locator.likeStore)
        }
    }
}
