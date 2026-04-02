import SwiftUI

class FavoritesManager: ObservableObject {
    @Published var favorites: [PexelsPhoto] = []

    func toggle(_ photo: PexelsPhoto) {
        if let index = favorites.firstIndex(where: { $0.id == photo.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(photo)
        }
    }

    func isFavorite(_ photo: PexelsPhoto) -> Bool {
        favorites.contains(where: { $0.id == photo.id })
    }
}
