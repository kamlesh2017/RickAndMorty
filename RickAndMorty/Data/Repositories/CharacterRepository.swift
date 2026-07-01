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

    func fetchCharacters(url: URL) async throws -> PaginatedCharacters {
        guard reachability.isConnected else {
            return try offlineFallback()
        }

        do {
            let response: CharactersResponseDTO = try await networkService.request(CharactersResponseDTO.self, url: url)
            let result = CharacterMapper.map(response)
            cacheCharacters(result)
            return result
        } catch let error as NetworkError where error == .httpError(statusCode: 404) {
            return PaginatedCharacters(characters: [], nextPageURL: nil)
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
            async let origin = fetchLocation(from: characterDTO.origin)
            async let location = fetchLocation(from: characterDTO.location)
            async let episodes = fetchEpisodes(from: characterDTO.episode)
            return CharacterMapper.mapDetail(
                characterDTO,
                origin: try await origin,
                location: try await location,
                episodes: try await episodes
            )
        } catch let error as NetworkError where error == .httpError(statusCode: 404) {
            throw DomainError.notFound
        } catch {
            throw mapError(error)
        }
    }

    func cachedCharacters() -> PaginatedCharacters? {
        CharacterCacheStore.load()
    }

    func cacheCharacters(_ result: PaginatedCharacters) {
        CharacterCacheStore.save(result)
    }

    private func offlineFallback() throws -> PaginatedCharacters {
        if let cached = cachedCharacters() {
            return cached
        }
        throw DomainError.networkUnavailable
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
