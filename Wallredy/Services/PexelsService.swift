import Foundation

class PexelsService {
    static let shared = PexelsService()
    private let apiKey = "9N6Fd5hCHabApihoFZl6mFWSH9IvPDpqAdCnnuwx7d2KLL8ZbLc996xw"
    private let baseURL = "https://api.pexels.com/v1"

    func searchPhotos(query: String, page: Int = 1, perPage: Int = 20) async throws -> PexelsResponse {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/search?query=\(encoded) wallpaper&per_page=\(perPage)&page=\(page)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(PexelsResponse.self, from: data)
    }
}
