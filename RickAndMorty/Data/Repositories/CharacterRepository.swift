import Foundation

final class CharacterRepository: CharacterRepositoryProtocol, @unchecked Sendable {
    private let networkService: NetworkServiceProtocol
    private let reachability: NetworkReachabilityManaging
    private let cacheStore: CharacterCacheStore

    init(
        networkService: NetworkServiceProtocol,
        reachability: NetworkReachabilityManaging = NetworkReachabilityManager.shared,
        cacheStore: CharacterCacheStore
    ) {
        self.networkService = networkService
        self.reachability = reachability
        self.cacheStore = cacheStore
    }

    func fetchCharacters(url: URL) async throws -> PaginatedCharacters {
        guard reachability.isConnected else {
            throw DomainError.networkUnavailable
        }

        do {
            let response: CharactersResponseDTO = try await networkService.request(CharactersResponseDTO.self, url: url)
            let result = CharacterMapper.map(response)
            await cacheCharacters(result)
            return result
        } catch let error as NetworkError where error == .httpError(statusCode: 404) {
            return PaginatedCharacters(characters: [], nextPageURL: nil)
        } catch {
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
            async let origin = fetchLocation(from: characterDTO.origin)
            async let location = fetchLocation(from: characterDTO.location)
            async let episodes = fetchEpisodes(from: characterDTO.episode)
            return CharacterMapper.mapDetail(
                characterDTO,
                origin: await origin,
                location: await location,
                episodes: try await episodes
            )
        } catch let error as NetworkError where error == .httpError(statusCode: 404) {
            throw DomainError.notFound
        } catch {
            throw mapError(error)
        }
    }

    func cachedCharacters() async -> PaginatedCharacters? {
        await cacheStore.load()
    }

    func cacheCharacters(_ result: PaginatedCharacters) async {
        await cacheStore.save(result)
    }

    private func fetchLocation(from reference: LocationDTO?) async -> Location? {
        guard let reference else { return nil }

        let resolved: Location
        if let urlString = reference.url, let url = URL(string: urlString) {
            do {
                let dto: LocationDetailDTO = try await networkService.request(LocationDetailDTO.self, url: url)
                resolved = CharacterMapper.map(dto)
            } catch {
                resolved = Location(name: reference.name, type: nil)
            }
        } else {
            resolved = Location(name: reference.name, type: nil)
        }

        if resolved.name == nil && resolved.type == nil {
            return nil
        }
        return resolved
    }

    private func fetchEpisodes(from urls: [String]?) async throws -> [Episode] {
        let episodeURLs = (urls ?? []).compactMap(URL.init(string:))
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
