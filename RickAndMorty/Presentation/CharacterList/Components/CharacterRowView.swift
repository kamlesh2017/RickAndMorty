import SwiftUI

struct CharacterRowView: View {
    let character: Character
    var isFavorite: Bool = false
    var showsFavoriteButton: Bool = true
    var onFavoriteToggle: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            RemoteImageView(url: character.imageURL)
                .frame(width: 56, height: 56)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(character.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                StatusBadgeView(status: character.status)
            }

            Spacer(minLength: 0)

            if showsFavoriteButton {
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    List {
        CharacterRowView(
            character: Character(
                id: 1,
                name: "Rick Sanchez",
                status: .alive,
                species: "Human",
                gender: "Male",
                imageURL: nil,
                origin: "Earth",
                location: "Citadel of Ricks",
                episodeURLs: []
            ),
            isFavorite: true
        )
    }
}
