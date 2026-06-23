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
            currentPage: 1,
            hasNextPage: true
        )
        repository.fetchCharactersResult = .success(expected)

        let useCase = FetchCharactersUseCase(repository: repository)
        let query = CharacterQuery.initial(name: "Rick")

        let result = try await useCase.execute(query: query)

        XCTAssertEqual(repository.fetchCharactersCalls, [query])
        XCTAssertEqual(result, expected)
    }

    func testCachedResultReturnsRepositoryCache() {
        let repository = MockCharacterRepository()
        let cached = PaginatedCharacters(
            characters: [.sample(id: 5, name: "Summer")],
            currentPage: 1,
            hasNextPage: false
        )
        repository.cachedResultValue = cached

        let useCase = FetchCharactersUseCase(repository: repository)

        XCTAssertEqual(useCase.cachedResult(), cached)
    }
}
