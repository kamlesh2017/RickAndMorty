import XCTest
@testable import RickAndMorty

@MainActor
final class CharacterListViewModelTests: XCTestCase {
    private var repository: MockCharacterRepository!
    private var favoritesRepository: FavoritesRepository!
    private var viewModel: CharacterListViewModel!

    override func setUp() {
        super.setUp()
        repository = MockCharacterRepository()
        favoritesRepository = FavoritesRepository(defaults: UserDefaults(suiteName: "CharacterListViewModelTests")!)
        viewModel = CharacterListViewModel(
            fetchCharactersUseCase: FetchCharactersUseCase(repository: repository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: favoritesRepository)
        )
    }

    func testInitialLoadPopulatesCharacters() async {
        repository.fetchCharactersResult = .success(
            PaginatedCharacters(
                characters: [.sample(id: 1, name: "Rick"), .sample(id: 2, name: "Morty")],
                nextPageURL: URL(string: "https://rickandmortyapi.com/api/character?page=2")
            )
        )

        await viewModel.onAppear()

        XCTAssertEqual(viewModel.characters.count, 2)
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertTrue(viewModel.hasNextPage)
        XCTAssertEqual(repository.fetchCharactersCalls.count, 1)
        XCTAssertEqual(
            repository.fetchCharactersCalls.first,
            APIEndpoint.characters(name: nil, status: nil)
        )
    }

    func testPaginationAppendsNextPage() async {
        let page2URL = URL(string: "https://rickandmortyapi.com/api/character?page=2")!
        repository.fetchCharactersResult = .success(
            PaginatedCharacters(
                characters: [.sample(id: 1, name: "Rick")],
                nextPageURL: page2URL
            )
        )
        await viewModel.onAppear()

        repository.fetchCharactersResult = .success(
            PaginatedCharacters(
                characters: [.sample(id: 2, name: "Morty")],
                nextPageURL: nil
            )
        )

        await viewModel.loadNextPageIfNeeded(currentCharacter: viewModel.characters[0])

        XCTAssertEqual(viewModel.characters.map(\.id), [1, 2])
        XCTAssertEqual(repository.fetchCharactersCalls.count, 2)
        XCTAssertEqual(repository.fetchCharactersCalls.last, page2URL)
        XCTAssertFalse(viewModel.hasNextPage)
    }

    func testSearchTriggersReloadWithDebouncedQuery() async {
        repository.fetchCharactersResult = .success(
            PaginatedCharacters(
                characters: [.sample(id: 1, name: "Rick")],
                nextPageURL: nil
            )
        )
        await viewModel.onAppear()

        viewModel.searchText = "Rick"
        try? await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertEqual(repository.fetchCharactersCalls.count, 2)
        XCTAssertEqual(
            repository.fetchCharactersCalls.last,
            APIEndpoint.characters(name: "Rick", status: nil)
        )
    }

    func testInitialLoadUsesCachedDataWhenOffline() async {
        repository.fetchCharactersResult = .failure(DomainError.networkUnavailable)
        repository.cachedResultValue = PaginatedCharacters(
            characters: [.sample(id: 99, name: "Cached Character")],
            nextPageURL: nil
        )

        await viewModel.onAppear()

        XCTAssertEqual(viewModel.characters.count, 1)
        XCTAssertEqual(viewModel.state, .offlineCached)
    }
}
