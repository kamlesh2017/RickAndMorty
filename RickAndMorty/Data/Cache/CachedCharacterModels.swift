import Foundation
import SwiftData

@Model
final class CachedCharacterPage {
    @Attribute(.unique) var cacheKey: String
    var nextPageURL: String?
    var expirationDate: Date
    var fetchedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \CachedCharacterEntity.page)
    var characters: [CachedCharacterEntity]

    init(
        cacheKey: String,
        nextPageURL: String?,
        expirationDate: Date,
        fetchedAt: Date = .now,
        characters: [CachedCharacterEntity] = []
    ) {
        self.cacheKey = cacheKey
        self.nextPageURL = nextPageURL
        self.expirationDate = expirationDate
        self.fetchedAt = fetchedAt
        self.characters = characters
    }
}

@Model
final class CachedCharacterEntity {
    var id: Int
    var name: String?
    var status: String?
    var species: String?
    var gender: String?
    var imageURL: String?
    var origin: String?
    var location: String?
    var episodeURLs: [String]
    var page: CachedCharacterPage?

    init(from character: Character) {
        id = character.id
        name = character.name
        status = character.status?.rawValue
        species = character.species
        gender = character.gender
        imageURL = character.imageURL?.absoluteString
        origin = character.origin
        location = character.location
        episodeURLs = character.episodeURLs.map(\.absoluteString)
    }

    func toDomain() -> Character {
        Character(
            id: id,
            name: name,
            status: status.flatMap(CharacterStatus.init(rawValue:)),
            species: species,
            gender: gender,
            imageURL: imageURL.flatMap(URL.init(string:)),
            origin: origin,
            location: location,
            episodeURLs: episodeURLs.compactMap(URL.init(string:))
        )
    }
}
