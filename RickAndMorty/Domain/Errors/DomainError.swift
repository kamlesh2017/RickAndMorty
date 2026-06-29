import Foundation

enum DomainError: Error, Equatable, Sendable {
    case notFound
    case networkUnavailable
    case noDataAvailable
    case unknown
}

extension DomainError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFound, .noDataAvailable:
            return "No data available."
        case .networkUnavailable:
            return "No internet connection. Please check your network and try again."
        case .unknown:
            return "Something went wrong. Please try again later."
        }
    }
}
