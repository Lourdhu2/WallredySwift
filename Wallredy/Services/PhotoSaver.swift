import SwiftUI
import Photos

class PhotoSaver {
    static func saveToPhotos(url: String) async throws {
        guard let imageURL = URL(string: url) else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: imageURL)

        guard let image = UIImage(data: data) else {
            throw NSError(domain: "PhotoSaver", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create image from data"])
        }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }

    static func shareImage(url: String) async throws -> URL {
        guard let imageURL = URL(string: url) else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: imageURL)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("wallredy_\(Date().timeIntervalSince1970).jpg")
        try data.write(to: tempURL)
        return tempURL
    }
}
