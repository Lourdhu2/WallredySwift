import SwiftUI
import Photos

struct PhotoPreviewView: View {
    let photos: [PexelsPhoto]
    @State var currentPhoto: PexelsPhoto
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var shareURL: URL?
    @State private var showShareSheet = false

    init(photo: PexelsPhoto, photos: [PexelsPhoto]) {
        self.photos = photos
        self._currentPhoto = State(initialValue: photo)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Vertically swipeable full-screen wallpapers
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(photos) { photo in
                        GeometryReader { geo in
                            AsyncImage(url: URL(string: photo.src.large2x)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .clipped()
                            } placeholder: {
                                Color.black
                                    .overlay(ProgressView())
                            }
                        }
                        .id(photo.id)
                        .containerRelativeFrame([.horizontal, .vertical])
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: Binding(
                get: { currentPhoto.id },
                set: { newID in
                    if let id = newID, let photo = photos.first(where: { $0.id == id }) {
                        currentPhoto = photo
                    }
                }
            ))
            .ignoresSafeArea()

            // Overlay controls
            VStack {
                // Back button
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 60)
                    Spacer()
                }

                Spacer()

                HStack {
                    // Photographer credit
                    HStack(spacing: 6) {
                        Image(systemName: "camera.fill")
                            .font(.caption)
                        Text(currentPhoto.photographer)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.white.opacity(0.55))
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                    .padding(.horizontal, 4)

                    Spacer()

                    // Action buttons
                    VStack(spacing: 12) {
                        Button {
                            favoritesManager.toggle(currentPhoto)
                        } label: {
                            Image(systemName: favoritesManager.isFavorite(currentPhoto) ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundStyle(favoritesManager.isFavorite(currentPhoto) ? .red : .white)
                                .frame(width: 50, height: 50)
                                .glassEffect(.regular, in: .circle)
                        }

                        Button {
                            Task { await savePhoto() }
                        } label: {
                            Group {
                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "arrow.down.to.line")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(width: 50, height: 50)
                            .glassEffect(.regular, in: .circle)
                        }
                        .disabled(isSaving)

                        Button {
                            Task { await sharePhoto() }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .glassEffect(.regular, in: .circle)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
        .onChange(of: showShareSheet) {
            if showShareSheet, let url = shareURL {
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    var presenter = rootVC
                    while let presented = presenter.presentedViewController {
                        presenter = presented
                    }
                    activityVC.completionWithItemsHandler = { _, _, _, _ in
                        showShareSheet = false
                    }
                    presenter.present(activityVC, animated: true)
                }
            }
        }
    }

    private func savePhoto() async {
        isSaving = true
        do {
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized || status == .limited else {
                alertTitle = "Permission Needed"
                alertMessage = "Please allow photo library access in Settings."
                showAlert = true
                isSaving = false
                return
            }

            try await PhotoSaver.saveToPhotos(url: currentPhoto.src.portrait)
            alertTitle = "Saved!"
            alertMessage = "Wallpaper saved to your photo library."
        } catch {
            alertTitle = "Save Failed"
            alertMessage = error.localizedDescription
        }
        showAlert = true
        isSaving = false
    }

    private func sharePhoto() async {
        do {
            let url = try await PhotoSaver.shareImage(url: currentPhoto.src.portrait)
            shareURL = url
            showShareSheet = true
        } catch {
            alertTitle = "Share Failed"
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
