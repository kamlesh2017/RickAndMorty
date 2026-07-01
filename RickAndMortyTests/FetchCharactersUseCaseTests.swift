import XCTest
@testable import RickAndMorty

final class FetchCharactersUseCaseTests: XCTestCase {
    func testExecuteCallsRepositoryAndReturnsMappedResults() async throws {
        let repository = MockCharacterRepository()
        let expected = PaginatedCharacters(
            characters: [
                .sample(id: 1, name: "Rick Sanchez"),
                .sample(id: 2, name: "Morty Smith", status: .alive)
            ],
            nextPageURL: URL(string: "https://rickandmortyapi.com/api/character?page=2")
        )
        repository.fetchCharactersResult = .success(expected)

        let useCase = FetchCharactersUseCase(repository: repository)
        let url = APIEndpoint.characters(name: "Rick", status: nil)

        let result = try await useCase.execute(url: url)

        XCTAssertEqual(repository.fetchCharactersCalls, [url])
        XCTAssertEqual(result, expected)
    }
}
