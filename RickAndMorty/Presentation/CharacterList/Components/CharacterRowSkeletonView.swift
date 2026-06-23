import SwiftUI

struct CharacterRowSkeletonView: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonPlaceholder()
                .frame(width: 56, height: 56)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 8) {
                SkeletonPlaceholder()
                    .frame(width: 160, height: 16)
                SkeletonPlaceholder()
                    .frame(width: 100, height: 14)
                SkeletonPlaceholder()
                    .frame(width: 70, height: 20)
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ForEach(0 ..< 5, id: \.self) { _ in
            CharacterRowSkeletonView()
        }
    }
}
