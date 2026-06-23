import Foundation
@testable import RickAndMorty

final class MockURLSession: URLSessionProtocol, @unchecked Sendable {
    var result: Result<(Data, URLResponse), Error> = .failure(URLError(.notConnectedToInternet))

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try result.get()
    }
}

extension MockURLSession {
    static func success(data: Data, statusCode: Int = 200) -> MockURLSession {
        let session = MockURLSession()
        let response = HTTPURLResponse(
            url: URL(string: "https://rickandmortyapi.com/api/character")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        session.result = .success((data, response))
        return session
    }

    static func failure(_ error: Error) -> MockURLSession {
        let session = MockURLSession()
        session.result = .failure(error)
        return session
    }
}
