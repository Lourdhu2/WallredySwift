import Foundation

struct PexelsResponse: Codable {
    let photos: [PexelsPhoto]
    let page: Int
    let perPage: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case photos, page
        case perPage = "per_page"
        case totalResults = "total_results"
    }
}

struct PexelsPhoto: Codable, Identifiable, Hashable {
    let id: Int
    let width: Int
    let height: Int
    let photographer: String
    let src: PhotoSources
    let avgColor: String?

    enum CodingKeys: String, CodingKey {
        case id, width, height, photographer, src
        case avgColor = "avg_color"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PexelsPhoto, rhs: PexelsPhoto) -> Bool {
        lhs.id == rhs.id
    }
}

struct PhotoSources: Codable, Hashable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}
