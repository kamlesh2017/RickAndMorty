import Foundation

final class CharacterRepository: CharacterRepositoryProtocol, @unchecked Sendable {
    private let networkService: NetworkServiceProtocol
    private let reachability: NetworkReachabilityManaging

    init(
        networkService: NetworkServiceProtocol,
        reachability: NetworkReachabilityManaging = NetworkReachabilityManager.shared
    ) {
        self.networkService = networkService
        self.reachability = reachability
    }

    func fetchCharacters(query: CharacterQuery) async throws -> PaginatedCharacters {
        guard reachability.isConnected else {
            return try offlineFallback()
        }

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
        guard reachability.isConnected else {
            throw DomainError.networkUnavailable
        }

        let url = APIEndpoint.character(id: id)

        do {
            let characterDTO: CharacterDTO = try await networkService.request(CharacterDTO.self, url: url)
            let episodes = try await fetchEpisodes(from: characterDTO.episode)
            return CharacterMapper.mapDetail(characterDTO, episodes: episodes)
        } catch let error as NetworkError where error == .httpError(statusCode: 404) {
            throw DomainError.notFound
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

    private func offlineFallback() throws -> PaginatedCharacters {
        if let cached = cachedCharacters() {
            return cached
        }
        throw DomainError.networkUnavailable
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
        if let domainError = error as? DomainError {
            return domainError
        }

        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpError(404):
                return .notFound
            case .noConnection:
                return .networkUnavailable
            case .noData:
                return .noDataAvailable
            case .underlying where !reachability.isConnected:
                return .networkUnavailable
            default:
                return .unknown
            }
        }

        if !reachability.isConnected {
            return .networkUnavailable
        }

        return .unknown
    }
}
