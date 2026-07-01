import Foundation
import SwiftData

@ModelActor
actor CharacterCacheStore {
    private let cacheKey = "character_list_cache"
    private let expiryInterval: TimeInterval = 30 * 60

    func save(_ result: PaginatedCharacters) {
        clearStoredPages()

        let expiryDate = Date().addingTimeInterval(expiryInterval)
        let entities = result.characters.map(CachedCharacterEntity.init(from:))
        let page = CachedCharacterPage(
            cacheKey: cacheKey,
            nextPageURL: result.nextPageURL?.absoluteString,
            expirationDate: expiryDate,
            characters: entities
        )

        modelContext.insert(page)
        try? modelContext.save()
    }

    func load() -> PaginatedCharacters? {
        let key = cacheKey
        var descriptor = FetchDescriptor<CachedCharacterPage>(
            predicate: #Predicate { $0.cacheKey == key }
        )
        descriptor.fetchLimit = 1

        guard
            let page = try? modelContext.fetch(descriptor).first,
            page.expirationDate > .now
        else {
            clearStoredPages()
            return nil
        }

        return PaginatedCharacters(
            characters: page.characters.map { $0.toDomain() },
            nextPageURL: page.nextPageURL.flatMap(URL.init(string:))
        )
    }

    private func clearStoredPages() {
        let key = cacheKey
        let descriptor = FetchDescriptor<CachedCharacterPage>(
            predicate: #Predicate { $0.cacheKey == key }
        )

        guard let pages = try? modelContext.fetch(descriptor) else { return }

        pages.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }
}
