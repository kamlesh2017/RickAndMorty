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

    func testExecuteWithFiltersBuildsInitialURL() async throws {
        let repository = MockCharacterRepository()
        repository.fetchCharactersResult = .success(.empty)

        let useCase = FetchCharactersUseCase(repository: repository)

        _ = try await useCase.execute(name: "Rick", status: .alive)

        XCTAssertEqual(
            repository.fetchCharactersCalls,
            [APIEndpoint.characters(name: "Rick", status: .alive)]
        )
    }

    func testCachedResultReturnsRepositoryCache() {
        let repository = MockCharacterRepository()
        let cached = PaginatedCharacters(
            characters: [.sample(id: 5, name: "Summer")],
            nextPageURL: nil
        )
        repository.cachedResultValue = cached

        let useCase = FetchCharactersUseCase(repository: repository)

        XCTAssertEqual(useCase.cachedResult(), cached)
    }
}
