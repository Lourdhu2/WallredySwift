import SwiftUI
import Photos

struct PhotoPreviewView: View {
    let photo: PexelsPhoto
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var shareURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            // Full-screen wallpaper
            AsyncImage(url: URL(string: photo.src.portrait)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } placeholder: {
                Color.black
                    .overlay(ProgressView())
            }
            .ignoresSafeArea()

            // Overlay controls
            VStack {
                Spacer()

                // Bottom bar with glass
                HStack {
                    // Photographer info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(photo.photographer)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Tap an action below")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassEffect(.regular, in: .capsule)

                    Spacer()

                    // Action buttons — Walli style, vertical on right
                    VStack(spacing: 12) {
                        // Favorite
                        Button {
                            favoritesManager.toggle(photo)
                        } label: {
                            Image(systemName: favoritesManager.isFavorite(photo) ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundStyle(favoritesManager.isFavorite(photo) ? .red : .white)
                                .frame(width: 50, height: 50)
                                .glassEffect(.regular, in: .circle)
                        }

                        // Save to Photos
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

                        // Share / Set as Wallpaper
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
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glassEffect(.regular, in: .circle)
                }
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ShareSheet(url: url)
            }
        }
    }

    private func savePhoto() async {
        isSaving = true
        do {
            // Request permission
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized || status == .limited else {
                alertTitle = "Permission Needed"
                alertMessage = "Please allow photo library access in Settings."
                showAlert = true
                isSaving = false
                return
            }

            try await PhotoSaver.saveToPhotos(url: photo.src.portrait)
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
            let url = try await PhotoSaver.shareImage(url: photo.src.portrait)
            shareURL = url
            showShareSheet = true
        } catch {
            alertTitle = "Share Failed"
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
