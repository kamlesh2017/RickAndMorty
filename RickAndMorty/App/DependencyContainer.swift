import Foundation

@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()
    static let preview = DependencyContainer(isPreview: true)

    private let session: URLSessionProtocol
    private let networkService: NetworkServiceProtocol
    private let characterRepository: CharacterRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    private let fetchCharactersUseCase: FetchCharactersUseCase
    private let fetchCharacterDetailUseCase: FetchCharacterDetailUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase

    init(isPreview: Bool = false) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        session = URLSession(configuration: configuration)

        let reachability: NetworkReachabilityManaging = isPreview
            ? PreviewNetworkReachability()
            : NetworkReachabilityManager.shared
        networkService = NetworkService(session: session, reachability: reachability)
        characterRepository = CharacterRepository(networkService: networkService, reachability: reachability)
        favoritesRepository = FavoritesRepository(
            defaults: isPreview ? UserDefaults(suiteName: "preview")! : .standard
        )

        fetchCharactersUseCase = FetchCharactersUseCase(repository: characterRepository)
        fetchCharacterDetailUseCase = FetchCharacterDetailUseCase(repository: characterRepository)
        toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: favoritesRepository)
    }

    func makeCharacterListViewModel() -> CharacterListViewModel {
        CharacterListViewModel(
            fetchCharactersUseCase: fetchCharactersUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase
        )
    }

    func makeCharacterDetailViewModel(characterID: Int) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            characterID: characterID,
            fetchCharacterDetailUseCase: fetchCharacterDetailUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase
        )
    }
}

private struct PreviewNetworkReachability: NetworkReachabilityManaging {
    var isConnected: Bool { true }

    func startMonitoring() {}

    func stopMonitoring() {}
}
