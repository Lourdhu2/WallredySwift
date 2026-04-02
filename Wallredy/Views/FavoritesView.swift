import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        NavigationStack {
            Group {
                if favoritesManager.favorites.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No favorites yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Tap the heart on any wallpaper to save it here")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ], spacing: 10) {
                            ForEach(favoritesManager.favorites) { photo in
                                NavigationLink(value: photo) {
                                    WallpaperCard(photo: photo)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                    }
                    .navigationDestination(for: PexelsPhoto.self) { photo in
                        PhotoPreviewView(photo: photo)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}
