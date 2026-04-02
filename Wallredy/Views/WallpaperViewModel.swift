import SwiftUI

@MainActor
class WallpaperViewModel: ObservableObject {
    @Published var photos: [PexelsPhoto] = []
    @Published var featured: [PexelsPhoto] = []
    @Published var isLoading = false
    @Published var selectedCategory = "Nature"
    @Published var searchQuery = ""

    private var currentPage = 1

    static let categories = [
        "Nature", "Abstract", "Space", "Dark", "Animals",
        "City", "Ocean", "Minimal", "Anime", "Mountains",
        "Flowers", "Aesthetic"
    ]

    func loadPhotos() async {
        isLoading = true
        currentPage = 1

        do {
            let query = searchQuery.isEmpty ? selectedCategory : searchQuery
            let response = try await PexelsService.shared.searchPhotos(query: query, page: 1)
            photos = response.photos
            if featured.isEmpty {
                featured = Array(response.photos.prefix(5))
            }
        } catch {
            print("Error loading photos: \(error)")
        }

        isLoading = false
    }

    func loadMore() async {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1

        do {
            let query = searchQuery.isEmpty ? selectedCategory : searchQuery
            let response = try await PexelsService.shared.searchPhotos(query: query, page: currentPage)
            photos.append(contentsOf: response.photos)
        } catch {
            print("Error loading more: \(error)")
        }

        isLoading = false
    }

    func selectCategory(_ category: String) {
        selectedCategory = category
        searchQuery = ""
        Task { await loadPhotos() }
    }

    func search(_ query: String) {
        searchQuery = query
        Task { await loadPhotos() }
    }
}
