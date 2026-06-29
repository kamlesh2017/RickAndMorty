import SwiftUI

struct CharacterDetailView: View {
    @StateObject private var viewModel: CharacterDetailViewModel

    init(viewModel: CharacterDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading, .idle:
                ProgressView("Loading character…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let message):
                EmptyStateView(
                    title: "Unable to Load",
                    systemImage: "exclamationmark.triangle",
                    message: message,
                    actionTitle: "Retry"
                ) {
                    Task { await viewModel.retry() }
                }
            case .loaded:
                if let character = viewModel.character {
                    detailContent(for: character)
                }
            }
        }
        .background(AppColors.groupedBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite ? .red : .primary)
                }
                .accessibilityLabel(viewModel.isFavorite ? "Remove from favorites" : "Add to favorites")
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }

    @ViewBuilder
    private func detailContent(for character: CharacterDetail) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                RemoteImageView(url: character.imageURL)
                    .frame(width: 180, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(spacing: 8) {
                    Text(character.name)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    StatusBadgeView(status: character.status)
                }

                infoCard(title: "Details") {
                    detailRow(title: "Species", value: character.species)
                    detailRow(title: "Gender", value: character.gender)
                    detailRow(title: "Origin", value: character.origin)
                    detailRow(title: "Location", value: character.location)
                }

                infoCard(title: "Episodes (\(character.episodes.count))") {
                    if character.episodes.isEmpty {
                        Text("No episodes available")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(character.episodes, id: \.id) { episode in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(episode.name)
                                    .font(.subheadline.weight(.medium))
                                Text(episode.airDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)

                            if episode.id != character.episodes.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func infoCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        CharacterDetailView(
            viewModel: CharacterDetailViewModel(
                characterID: 1,
                fetchCharacterDetailUseCase: FetchCharacterDetailUseCase(
                    repository: PreviewCharacterRepository()
                ),
                toggleFavoriteUseCase: ToggleFavoriteUseCase(
                    repository: FavoritesRepository(defaults: UserDefaults(suiteName: "preview")!)
                )
            )
        )
    }
}

private final class PreviewCharacterRepository: CharacterRepositoryProtocol, @unchecked Sendable {
    func fetchCharacters(query: CharacterQuery) async throws -> PaginatedCharacters {
        PaginatedCharacters(characters: [], currentPage: 1, hasNextPage: false)
    }

    func fetchCharacterDetail(id: Int) async throws -> CharacterDetail {
        CharacterDetail(
            id: id,
            name: "Rick Sanchez",
            status: .alive,
            species: "Human",
            gender: "Male",
            imageURL: nil,
            origin: "Earth (C-137)",
            location: "Citadel of Ricks",
            episodes: [
                Episode(id: 1, name: "Pilot", airDate: "December 2, 2013")
            ]
        )
    }

    func cachedCharacters() -> PaginatedCharacters? { nil }
    func cacheCharacters(_ result: PaginatedCharacters, query: CharacterQuery) {}
}
