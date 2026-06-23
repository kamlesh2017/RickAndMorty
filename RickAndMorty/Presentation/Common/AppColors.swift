import SwiftUI

enum AppColors {
    static let alive = Color("StatusAlive")
    static let dead = Color("StatusDead")
    static let unknown = Color("StatusUnknown")
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
}

extension CharacterStatus {
    var color: Color {
        switch self {
        case .alive: return AppColors.alive
        case .dead: return AppColors.dead
        case .unknown: return AppColors.unknown
        }
    }
}
