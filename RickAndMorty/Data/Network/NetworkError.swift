import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
    case noData
    case noConnection
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
        case .noConnection:
            return "No internet connection."
        case .underlying:
            return "Something went wrong. Please try again later."
        }
    }
}

extension NetworkError {
    static func from(_ error: Error) -> NetworkError {
        guard let urlError = error as? URLError else {
            return .underlying(error.localizedDescription)
        }

        switch urlError.code {
        case .notConnectedToInternet,
             .networkConnectionLost,
             .dataNotAllowed,
             .cannotFindHost,
             .cannotConnectToHost,
             .dnsLookupFailed,
             .timedOut:
            return .noConnection
        default:
            return .underlying(urlError.localizedDescription)
        }
    }
}
