import Foundation

enum CharacterMapper {
    static func map(_ dto: CharacterDTO) -> Character {
        Character(
            id: dto.id,
            name: dto.name,
            status: CharacterStatus(rawValue: dto.status),
            species: dto.species,
            gender: dto.gender,
            imageURL: URL(string: dto.image),
            origin: dto.origin.name,
            location: dto.location.name,
            episodeURLs: dto.episode.compactMap(URL.init(string:))
        )
    }

    static func mapDetail(_ dto: CharacterDTO, episodes: [Episode]) -> CharacterDetail {
        CharacterDetail(
            id: dto.id,
            name: dto.name,
            status: CharacterStatus(rawValue: dto.status),
            species: dto.species,
            gender: dto.gender,
            imageURL: URL(string: dto.image),
            origin: dto.origin.name,
            location: dto.location.name,
            episodes: episodes
        )
    }

    static func map(_ dto: EpisodeDTO) -> Episode {
        Episode(id: dto.id, name: dto.name, airDate: dto.airDate)
    }

    static func map(_ response: CharactersResponseDTO, page: Int) -> PaginatedCharacters {
        PaginatedCharacters(
            characters: response.results.map(map),
            currentPage: page,
            hasNextPage: response.info.next != nil
        )
    }
}
