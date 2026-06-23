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
    let currentPage: Int
    let hasNextPage: Bool
}

struct CharacterQuery: Equatable, Sendable {
    let page: Int
    let name: String?
    let status: CharacterStatus?

    static func initial(name: String? = nil, status: CharacterStatus? = nil) -> CharacterQuery {
        CharacterQuery(page: 1, name: name, status: status)
    }

    func nextPage() -> CharacterQuery {
        CharacterQuery(page: page + 1, name: name, status: status)
    }

    func resettingPage(name: String?, status: CharacterStatus?) -> CharacterQuery {
        CharacterQuery(page: 1, name: name, status: status)
    }
}
