import Foundation

struct FetchCharacterDetailUseCase: Sendable {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> CharacterDetail {
        try await repository.fetchCharacterDetail(id: id)
    }
}
