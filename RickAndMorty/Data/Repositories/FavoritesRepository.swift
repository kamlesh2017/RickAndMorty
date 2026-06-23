import Foundation

final class FavoritesRepository: FavoritesRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let storageKey = "favorite_character_ids"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func isFavorite(characterID: Int) -> Bool {
        favoriteCharacterIDs().contains(characterID)
    }

    func toggleFavorite(characterID: Int) {
        var favorites = favoriteCharacterIDs()
        if favorites.contains(characterID) {
            favorites.remove(characterID)
        } else {
            favorites.insert(characterID)
        }
        defaults.set(Array(favorites), forKey: storageKey)
    }

    func favoriteCharacterIDs() -> Set<Int> {
        Set(defaults.array(forKey: storageKey) as? [Int] ?? [])
    }
}
