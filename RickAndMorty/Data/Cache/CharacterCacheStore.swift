import Foundation

// MARK: - Cache Models

struct CachedCharacterList: Codable {
    let characters: [CachedCharacter]
    let nextPageURL: String?
    let expirationDate: Date
}

struct CachedCharacter: Codable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let imageURL: String?
    let origin: String
    let location: String
    let episodeURLs: [String]
}

// MARK: - Memory Cache Entry

private final class CacheEntry {
    let value: PaginatedCharacters
    let expirationDate: Date
    
    init(
        value: PaginatedCharacters,
        expirationDate: Date
    ) {
        self.value = value
        self.expirationDate = expirationDate
    }
    
    var isExpired: Bool {
        Date() > expirationDate
    }
    
}

// MARK: - Cache Store

enum CharacterCacheStore {
    
    private static let memoryCache = NSCache<NSString, CacheEntry>()
    
    private static let cacheFileName = "character_cache.json"
    
    private static let expiryInterval: TimeInterval = 30 * 60
    
    // MARK: Save
    
    static func save(_ result: PaginatedCharacters) {
        
        let expiryDate = Date().addingTimeInterval(expiryInterval)
        
        // 1. Memory Cache
        
        let memoryEntry = CacheEntry(
            value: result,
            expirationDate: expiryDate
        )
        
        memoryCache.setObject(
            memoryEntry,
            forKey: cacheKey as NSString
        )
        
        // 2. File Cache
        
        let fileCache = CachedCharacterList(
            characters: result.characters.map {
                CachedCharacter(
                    id: $0.id,
                    name: $0.name,
                    status: $0.status.rawValue,
                    species: $0.species,
                    gender: $0.gender,
                    imageURL: $0.imageURL?.absoluteString,
                    origin: $0.origin,
                    location: $0.location,
                    episodeURLs: $0.episodeURLs.map(\.absoluteString)
                )
            },
            nextPageURL: result.nextPageURL?.absoluteString,
            expirationDate: expiryDate
        )
        
        do {
            let data = try JSONEncoder().encode(fileCache)
            
            try data.write(
                to: cacheFileURL,
                options: .atomic
            )
        } catch {
            print("Failed to save cache: \(error)")
        }
    }
    
    // MARK: Load
    
    static func load() -> PaginatedCharacters? {
        
        // 1. Memory Cache First
        
        if let entry = memoryCache.object(
            forKey: cacheKey as NSString
        ) {
            
            if !entry.isExpired {
                return entry.value
            }
            
            memoryCache.removeObject(
                forKey: cacheKey as NSString
            )
        }
        
        // 2. File Cache Fallback
        
        guard
            let data = try? Data(contentsOf: cacheFileURL),
            let cached = try? JSONDecoder().decode(
                CachedCharacterList.self,
                from: data
            )
        else {
            return nil
        }
        
        guard cached.expirationDate > Date() else {
            
            try? FileManager.default.removeItem(
                at: cacheFileURL
            )
            
            return nil
        }
        
        let characters = cached.characters.map {
            Character(
                id: $0.id,
                name: $0.name,
                status: CharacterStatus(rawValue: $0.status),
                species: $0.species,
                gender: $0.gender,
                imageURL: $0.imageURL.flatMap(URL.init(string:)),
                origin: $0.origin,
                location: $0.location,
                episodeURLs: $0.episodeURLs.compactMap(URL.init(string:))
            )
        }
        
        let result = PaginatedCharacters(
            characters: characters,
            nextPageURL: cached.nextPageURL.flatMap(URL.init(string:))
        )
        
        // Rehydrate Memory Cache
        
        let memoryEntry = CacheEntry(
            value: result,
            expirationDate: cached.expirationDate
        )
        
        memoryCache.setObject(
            memoryEntry,
            forKey: cacheKey as NSString
        )
        
        return result
    }
    
    // MARK: Clear
    
    static func clear() {
        
        memoryCache.removeAllObjects()
        
        try? FileManager.default.removeItem(
            at: cacheFileURL
        )
    }
    
}

// MARK: - Helpers

private extension CharacterCacheStore {
    
    static var cacheKey: String {
        "character_list_cache"
    }
    
    static var cacheFileURL: URL {
        
        FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0]
            .appendingPathComponent(cacheFileName)
    }
    
}
