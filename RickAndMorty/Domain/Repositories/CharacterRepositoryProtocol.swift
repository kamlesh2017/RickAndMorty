import Foundation

protocol CharacterRepositoryProtocol: Sendable {
    func fetchCharacters(query: CharacterQuery) async throws -> PaginatedCharacters
    func fetchCharacterDetail(id: Int) async throws -> CharacterDetail
    func cachedCharacters() -> PaginatedCharacters?
    func cacheCharacters(_ result: PaginatedCharacters, query: CharacterQuery)
}
