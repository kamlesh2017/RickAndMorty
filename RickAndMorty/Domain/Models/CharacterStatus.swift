import Foundation

enum CharacterStatus: String, Equatable, Sendable, CaseIterable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "Unknown"

    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "alive": self = .alive
        case "dead": self = .dead
        default: self = .unknown
        }
    }
}
