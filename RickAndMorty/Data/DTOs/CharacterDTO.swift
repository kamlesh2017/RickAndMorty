import Foundation

struct CharactersResponseDTO: Decodable {
    let info: InfoDTO?
    let results: [CharacterDTO]?
}

struct InfoDTO: Decodable {
    let count: Int?
    let pages: Int?
    let next: String?
    let prev: String?
}

struct CharacterDTO: Decodable {
    let id: Int
    let name: String?
    let status: String?
    let species: String?
    let gender: String?
    let image: String?
    let origin: LocationDTO?
    let location: LocationDTO?
    let episode: [String]?
}

struct LocationDTO: Decodable {
    let name: String?
    let url: String?
}

struct LocationDetailDTO: Decodable {
    let name: String?
    let type: String?
}

struct EpisodeDTO: Decodable {
    let id: Int
    let name: String?
    let airDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case airDate = "air_date"
    }
}
