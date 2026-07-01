import Foundation

protocol CharacterRepositoryProtocol: Sendable {
    func fetchCharacters(url: URL) async throws -> PaginatedCharacters
    func fetchCharacterDetail(id: Int) async throws -> CharacterDetail
    func cachedCharacters() async -> PaginatedCharacters?
    func cacheCharacters(_ result: PaginatedCharacters) async
}
