import Foundation

struct ToggleFavoriteUseCase: Sendable {
    private let repository: FavoritesRepositoryProtocol

    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }

    func execute(characterID: Int) -> Bool {
        repository.toggleFavorite(characterID: characterID)
        return repository.isFavorite(characterID: characterID)
    }

    func isFavorite(characterID: Int) -> Bool {
        repository.isFavorite(characterID: characterID)
    }
}
