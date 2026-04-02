import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView()
            }

            Tab("Explore", systemImage: "magnifyingglass", value: 1) {
                ExploreView()
            }

            Tab("Favorites", systemImage: "heart.fill", value: 2) {
                FavoritesView()
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 3) {
                SettingsView()
            }
        }
        .tint(.white)
    }
}
