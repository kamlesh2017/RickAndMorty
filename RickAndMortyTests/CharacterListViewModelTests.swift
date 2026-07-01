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
}
