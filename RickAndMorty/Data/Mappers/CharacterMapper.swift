import Foundation

enum CharacterMapper {
    static func map(_ dto: CharacterDTO) -> Character {
        Character(
            id: dto.id,
            name: dto.name,
            status: dto.status.map(CharacterStatus.init(rawValue:)),
            species: dto.species,
            gender: dto.gender,
            imageURL: dto.image.flatMap(URL.init(string:)),
            origin: dto.origin?.name,
            location: dto.location?.name,
            episodeURLs: (dto.episode ?? []).compactMap(URL.init(string:))
        )
    }

    static func map(_ dto: LocationDetailDTO) -> Location {
        Location(name: dto.name, type: dto.type)
    }

    static func mapDetail(
        _ dto: CharacterDTO,
        origin: Location?,
        location: Location?,
        episodes: [Episode]
    ) -> CharacterDetail {
        CharacterDetail(
            id: dto.id,
            name: dto.name,
            status: dto.status.map(CharacterStatus.init(rawValue:)),
            species: dto.species,
            gender: dto.gender,
            imageURL: dto.image.flatMap(URL.init(string:)),
            origin: origin,
            location: location,
            episodes: episodes
        )
    }

    static func map(_ dto: EpisodeDTO) -> Episode {
        Episode(id: dto.id, name: dto.name, airDate: dto.airDate)
    }

    static func map(_ response: CharactersResponseDTO) -> PaginatedCharacters {
        PaginatedCharacters(
            characters: (response.results ?? []).map(map),
            nextPageURL: response.info?.next.flatMap(URL.init(string:))
        )
    }
}
