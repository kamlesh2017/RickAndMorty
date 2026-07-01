import Foundation

enum APIEndpoint {
    static let baseURL = URL(string: "https://rickandmortyapi.com/api")!

    static func characters(name: String?, status: CharacterStatus?) -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent("character"), resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []

        if let name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }

        if let status {
            queryItems.append(URLQueryItem(name: "status", value: status.rawValue.lowercased()))
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        return components.url!
    }

    static func character(id: Int) -> URL {
        baseURL.appendingPathComponent("character/\(id)")
    }

    static func episodes(urls: [URL]) -> [URL] {
        urls.compactMap { url in
            guard let id = url.pathComponents.last, Int(id) != nil else { return nil }
            return baseURL.appendingPathComponent("episode/\(id)")
        }
    }
}
