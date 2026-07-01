import Foundation
@testable import RickAndMorty

final class MockCharacterRepository: CharacterRepositoryProtocol, @unchecked Sendable {
    var fetchCharactersCalls: [URL] = []
    var fetchCharactersResult: Result<PaginatedCharacters, Error> = .success(.empty)
    var cachedResultValue: PaginatedCharacters?

    func fetchCharacters(url: URL) async throws -> PaginatedCharacters {
        fetchCharactersCalls.append(url)
        return try fetchCharactersResult.get()
    }

    func fetchCharacterDetail(id: Int) async throws -> CharacterDetail {
        throw DomainError.notFound
    }

    func cachedCharacters() -> PaginatedCharacters? {
        cachedResultValue
    }

    func cacheCharacters(_ result: PaginatedCharacters) {}
}

extension PaginatedCharacters {
    static var empty: PaginatedCharacters {
        PaginatedCharacters(characters: [], nextPageURL: nil)
    }
}

extension Character {
    static func sample(
        id: Int,
        name: String,
        status: CharacterStatus = .alive,
        imageURL: URL? = nil
    ) -> Character {
        Character(
            id: id,
            name: name,
            status: status,
            species: "Human",
            gender: "Male",
            imageURL: imageURL,
            origin: "Earth",
            location: "Citadel of Ricks",
            episodeURLs: []
        )
    }
}
