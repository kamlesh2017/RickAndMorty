import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()
    static let preview = DependencyContainer(isPreview: true)

    let modelContainer: ModelContainer

    private let session: URLSessionProtocol
    private let networkService: NetworkServiceProtocol
    private let characterRepository: CharacterRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    private let fetchCharactersUseCase: FetchCharactersUseCase
    private let fetchCharacterDetailUseCase: FetchCharacterDetailUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase

    init(isPreview: Bool = false) {
        let schema = Schema([CachedCharacterPage.self, CachedCharacterEntity.self])
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: isPreview)
        modelContainer = try! ModelContainer(for: schema, configurations: modelConfiguration)

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 30
        session = URLSession(configuration: sessionConfiguration)

        let reachability: NetworkReachabilityManaging = isPreview
            ? PreviewNetworkReachability()
            : NetworkReachabilityManager.shared
        networkService = NetworkService(session: session, reachability: reachability)
        let cacheStore = CharacterCacheStore(modelContainer: modelContainer)
        characterRepository = CharacterRepository(
            networkService: networkService,
            reachability: reachability,
            cacheStore: cacheStore
        )
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
