import SwiftUI

@main
struct WallredyApp: App {
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favoritesManager)
                .preferredColorScheme(.dark)
        }
    }
}
