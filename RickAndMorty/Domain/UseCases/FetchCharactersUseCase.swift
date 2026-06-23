import Foundation

struct FetchCharactersUseCase: Sendable {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: CharacterQuery) async throws -> PaginatedCharacters {
        try await repository.fetchCharacters(query: query)
    }

    func cachedResult() -> PaginatedCharacters? {
        repository.cachedCharacters()
    }
}
