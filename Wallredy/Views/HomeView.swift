import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = WallpaperViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Featured carousel
                    if !viewModel.featured.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Featured")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 12) {
                                    ForEach(viewModel.featured) { photo in
                                        NavigationLink(value: photo) {
                                            FeaturedCard(photo: photo)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Categories
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Categories")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(WallpaperViewModel.categories, id: \.self) { category in
                                    CategoryChip(
                                        name: category,
                                        isSelected: viewModel.selectedCategory == category
                                    ) {
                                        viewModel.selectCategory(category)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.selectedCategory)
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
                    }

                    // Load more
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
                        .padding(.bottom, 80)
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.top, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Wallredy")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            .navigationDestination(for: PexelsPhoto.self) { photo in
                PhotoPreviewView(photo: photo)
            }
            .task {
                if viewModel.photos.isEmpty {
                    await viewModel.loadPhotos()
                }
            }
        }
    }
}

// MARK: - Featured Card
struct FeaturedCard: View {
    let photo: PexelsPhoto

    var body: some View {
        AsyncImage(url: URL(string: photo.src.large)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 180)
                .clipped()
        } placeholder: {
            Rectangle()
                .fill(.ultraThinMaterial)
                .frame(width: 300, height: 180)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .bottomLeading) {
            Text(photo.photographer)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 16, bottomTrailingRadius: 16))
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .white : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .glassEffect(.regular, in: .capsule)
        }
    }
}

// MARK: - Wallpaper Card
struct WallpaperCard: View {
    let photo: PexelsPhoto
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        GeometryReader { geo in
            AsyncImage(url: URL(string: photo.src.portrait)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
            } placeholder: {
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .topTrailing) {
            Button {
                favoritesManager.toggle(photo)
            } label: {
                Image(systemName: favoritesManager.isFavorite(photo) ? "heart.fill" : "heart")
                    .foregroundStyle(favoritesManager.isFavorite(photo) ? .red : .white)
                    .font(.body)
                    .padding(8)
                    .glassEffect(.regular, in: .circle)
            }
            .padding(8)
        }
        .overlay(alignment: .bottomLeading) {
            Text(photo.photographer)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(8)
        }
    }
}
