import Foundation

final class FavoritesRepository: FavoritesRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let storageKey = "favorite_character_ids"
    private var favorites: Set<Int>

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        favorites = Set(defaults.array(forKey: storageKey) as? [Int] ?? [])
    }

    func isFavorite(characterID: Int) -> Bool {
        favorites.contains(characterID)
    }

    func toggleFavorite(characterID: Int) {
        if favorites.contains(characterID) {
            favorites.remove(characterID)
        } else {
            favorites.insert(characterID)
        }
        save()
    }

    func favoriteCharacterIDs() -> Set<Int> {
        favorites
    }

    private func save() {
        defaults.set(Array(favorites), forKey: storageKey)
    }
}
