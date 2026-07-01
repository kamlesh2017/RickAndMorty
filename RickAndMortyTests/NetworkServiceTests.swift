import XCTest
@testable import RickAndMorty

final class NetworkServiceTests: XCTestCase {
    func testSuccessfulDecodeReturnsDTO() async throws {
        let json = """
        {
          "info": { "count": 1, "pages": 1, "next": null, "prev": null },
          "results": [{
            "id": 1,
            "name": "Rick Sanchez",
            "status": "Alive",
            "species": "Human",
            "gender": "Male",
            "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            "origin": { "name": "Earth (C-137)", "url": "https://rickandmortyapi.com/api/location/1" },
            "location": { "name": "Citadel of Ricks", "url": "https://rickandmortyapi.com/api/location/3" },
            "episode": ["https://rickandmortyapi.com/api/episode/1"]
          }]
        }
        """.data(using: .utf8)!

        let session = MockURLSession.success(data: json)
        let service = NetworkService(session: session)

        let response: CharactersResponseDTO = try await service.request(CharactersResponseDTO.self, url: URL(string: "https://rickandmortyapi.com/api/character")!)

        XCTAssertEqual(response.results?.count, 1)
        XCTAssertEqual(response.results?.first?.name, "Rick Sanchez")
    }

    func testHTTPErrorIsMapped() async {
        let session = MockURLSession.success(data: Data(), statusCode: 500)
        let service = NetworkService(session: session)

        do {
            _ = try await service.request(CharactersResponseDTO.self, url: URL(string: "https://rickandmortyapi.com/api/character")!)
            XCTFail("Expected http error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .httpError(statusCode: 500))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testDecodingFailureIsMapped() async {
        let session = MockURLSession.success(data: Data("not-json".utf8))
        let service = NetworkService(session: session)

        do {
            _ = try await service.request(CharactersResponseDTO.self, url: URL(string: "https://rickandmortyapi.com/api/character")!)
            XCTFail("Expected decoding error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .decodingFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testUnderlyingNetworkErrorIsMapped() async {
        let session = MockURLSession.failure(URLError(.notConnectedToInternet))
        let service = NetworkService(session: session)

        do {
            _ = try await service.request(CharactersResponseDTO.self, url: URL(string: "https://rickandmortyapi.com/api/character")!)
            XCTFail("Expected underlying error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noConnection)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
