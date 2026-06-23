import SwiftUI

struct StatusBadgeView: View {
    let status: CharacterStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(status.color, in: Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusBadgeView(status: .alive)
        StatusBadgeView(status: .dead)
        StatusBadgeView(status: .unknown)
    }
    .padding()
}
