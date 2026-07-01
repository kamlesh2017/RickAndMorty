import Foundation

protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable>(_ type: T.Type, url: URL) async throws -> T
}

final class NetworkService: NetworkServiceProtocol, @unchecked Sendable {
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder

    init(
        session: URLSessionProtocol,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ type: T.Type, url: URL) async throws -> T {
        let request = URLRequest(url: url)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.from(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        guard !data.isEmpty else {
            throw NetworkError.noData
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
