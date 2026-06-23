import Foundation

enum DomainError: Error, Equatable, Sendable {
    case notFound
    case networkUnavailable
    case unknown(String)
}
