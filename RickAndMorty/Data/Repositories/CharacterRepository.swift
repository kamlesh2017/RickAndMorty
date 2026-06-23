import Foundation

final class CharacterRepository: CharacterRepositoryProtocol, @unchecked Sendable {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchCharacters(query: CharacterQuery) async throws -> PaginatedCharacters {
        let url = APIEndpoint.characters(page: query.page, name: query.name, status: query.status)

        do {
            let response: CharactersResponseDTO = try await networkService.request(CharactersResponseDTO.self, url: url)
            let result = CharacterMapper.map(response, page: query.page)
            cacheCharacters(result, query: query)
            return result
        } catch let error as NetworkError where error == .httpError(statusCode: 404) {
            return PaginatedCharacters(characters: [], currentPage: query.page, hasNextPage: false)
        } catch {
            if let cached = cachedCharacters() {
                return cached
            }
            throw mapError(error)
        }
    }

    func fetchCharacterDetail(id: Int) async throws -> CharacterDetail {
        let url = APIEndpoint.character(id: id)

        do {
            let characterDTO: CharacterDTO = try await networkService.request(CharacterDTO.self, url: url)
            let episodes = try await fetchEpisodes(from: characterDTO.episode)
            return CharacterMapper.mapDetail(characterDTO, episodes: episodes)
        } catch {
            throw mapError(error)
        }
    }

    func cachedCharacters() -> PaginatedCharacters? {
        CharacterCacheStore.load()
    }

    func cacheCharacters(_ result: PaginatedCharacters, query: CharacterQuery) {
        CharacterCacheStore.save(result, query: query)
    }

    private func fetchEpisodes(from urls: [String]) async throws -> [Episode] {
        let episodeURLs = urls.compactMap(URL.init(string:))
        let endpoints = APIEndpoint.episodes(urls: episodeURLs)

        return try await withThrowingTaskGroup(of: Episode.self) { group in
            for endpoint in endpoints {
                group.addTask {
                    let dto: EpisodeDTO = try await self.networkService.request(EpisodeDTO.self, url: endpoint)
                    return CharacterMapper.map(dto)
                }
            }

            var episodes: [Episode] = []
            for try await episode in group {
                episodes.append(episode)
            }
            return episodes.sorted { $0.id < $1.id }
        }
    }

    private func mapError(_ error: Error) -> DomainError {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpError(404):
                return .notFound
            case .underlying(let message) where message.localizedCaseInsensitiveContains("offline")
                || message.localizedCaseInsensitiveContains("network"):
                return .networkUnavailable
            default:
                return .unknown(networkError.localizedDescription)
            }
        }
        return .unknown(error.localizedDescription)
    }
}
