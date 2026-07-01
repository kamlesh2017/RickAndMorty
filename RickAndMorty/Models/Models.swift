import Foundation

struct PaginatedCharacters: Equatable, Sendable {
    let characters: [Character]
    let nextPageURL: URL?
}

struct Character: Equatable, Identifiable, Sendable {
    let id: Int
    let name: String?
    let status: CharacterStatus?
    let species: String?
    let gender: String?
    let imageURL: URL?
    let origin: String?
    let location: String?
    let episodeURLs: [URL]
}

enum CharacterStatus: String, Equatable, Sendable, CaseIterable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "Unknown"

    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "alive": self = .alive
        case "dead": self = .dead
        default: self = .unknown
        }
    }
}

struct CharacterDetail: Equatable, Identifiable, Sendable {
    let id: Int
    let name: String?
    let status: CharacterStatus?
    let species: String?
    let gender: String?
    let imageURL: URL?
    let origin: Location?
    let location: Location?
    let episodes: [Episode]
}

struct Episode: Equatable, Identifiable, Sendable {
    let id: Int
    let name: String?
    let airDate: String?
}

struct Location: Equatable, Sendable {
    let name: String?
    let type: String?
}
