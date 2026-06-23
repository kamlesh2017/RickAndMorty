import Foundation

protocol FavoritesRepositoryProtocol: Sendable {
    func isFavorite(characterID: Int) -> Bool
    func toggleFavorite(characterID: Int)
    func favoriteCharacterIDs() -> Set<Int>
}
