import Foundation

struct FetchCharactersUseCase: Sendable {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(url: URL) async throws -> PaginatedCharacters {
        try await repository.fetchCharacters(url: url)
    }

    func execute(name: String?, status: CharacterStatus?) async throws -> PaginatedCharacters {
        try await execute(url: APIEndpoint.characters(name: name, status: status))
    }

    func cachedResult() -> PaginatedCharacters? {
        repository.cachedCharacters()
    }
}
