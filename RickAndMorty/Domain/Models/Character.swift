import Foundation

struct Character: Equatable, Identifiable, Sendable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let gender: String
    let imageURL: URL?
    let origin: String
    let location: String
    let episodeURLs: [URL]
}

struct CharacterDetail: Equatable, Identifiable, Sendable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let gender: String
    let imageURL: URL?
    let origin: String
    let location: String
    let episodes: [Episode]
}

struct PaginatedCharacters: Equatable, Sendable {
    let characters: [Character]
    let nextPageURL: URL?
}
