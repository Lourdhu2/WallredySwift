import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @StateObject private var viewModel = WallpaperViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                if isSearching && !viewModel.photos.isEmpty {
                    // Search results
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Results for \"\(viewModel.searchQuery)\"")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 14) {
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
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 80)
                } else if isSearching && viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else {
                    // Category grid
                    VStack(alignment: .leading, spacing: 20) {
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
            }
            .navigationTitle("Explore")
            .navigationDestination(for: PexelsPhoto.self) { photo in
                PhotoPreviewView(photo: photo, photos: viewModel.photos)
            }
            .searchable(text: $searchText, prompt: "Search wallpapers...")
            .onSubmit(of: .search) {
                isSearching = true
                viewModel.search(searchText)
            }
            .onChange(of: searchText) {
                if searchText.isEmpty {
                    isSearching = false
                }
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
            PhotoPreviewView(photo: photo, photos: viewModel.photos)
        }
        .task {
            viewModel.selectCategory(category)
        }
    }
}
