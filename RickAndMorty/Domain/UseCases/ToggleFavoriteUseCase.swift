import Foundation

struct ToggleFavoriteUseCase: Sendable {
    private let repository: FavoritesRepositoryProtocol

    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }

    func execute(characterID: Int) {
        repository.toggleFavorite(characterID: characterID)
    }

    func isFavorite(characterID: Int) -> Bool {
        repository.isFavorite(characterID: characterID)
    }
}
