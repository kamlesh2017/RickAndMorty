import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
    case noData
    case underlying(String)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpError(let statusCode):
            return "Request failed with status code \(statusCode)."
        case .decodingFailed:
            return "Unable to decode the server response."
        case .noData:
            return "No data was returned from the server."
        case .underlying(let message):
            return message
        }
    }
}
