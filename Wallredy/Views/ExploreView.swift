import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @StateObject private var viewModel = WallpaperViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Category grid
                    Text("Browse Categories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(WallpaperViewModel.categories, id: \.self) { category in
                            NavigationLink {
                                CategoryDetailView(category: category)
                            } label: {
                                VStack(spacing: 8) {
                                    Text(categoryIcon(category))
                                        .font(.largeTitle)
                                    Text(category)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .glassEffect(.regular, in: .rect(cornerRadius: 16))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "Search wallpapers...")
            .onSubmit(of: .search) {
                viewModel.search(searchText)
            }
        }
    }

    private func categoryIcon(_ name: String) -> String {
        switch name {
        case "Nature": return "🌿"
        case "Abstract": return "🎨"
        case "Space": return "🚀"
        case "Dark": return "🌑"
        case "Animals": return "🦊"
        case "City": return "🏙️"
        case "Ocean": return "🌊"
        case "Minimal": return "◻️"
        case "Anime": return "⛩️"
        case "Mountains": return "🏔️"
        case "Flowers": return "🌸"
        case "Aesthetic": return "✨"
        default: return "📷"
        }
    }
}

// MARK: - Category Detail View
struct CategoryDetailView: View {
    let category: String
    @StateObject private var viewModel = WallpaperViewModel()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                ForEach(viewModel.photos) { photo in
                    NavigationLink(value: photo) {
                        WallpaperCard(photo: photo)
                    }
                }
            }
            .padding(.horizontal)

            if !viewModel.photos.isEmpty {
                Button {
                    Task { await viewModel.loadMore() }
                } label: {
                    Text("Load More")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .glassEffect(.regular, in: .capsule)
                }
                .padding()
                .padding(.bottom, 80)
            }

            if viewModel.isLoading {
                ProgressView().padding()
            }
        }
        .navigationTitle(category)
        .navigationDestination(for: PexelsPhoto.self) { photo in
            PhotoPreviewView(photo: photo)
        }
        .task {
            viewModel.selectCategory(category)
        }
    }
}
