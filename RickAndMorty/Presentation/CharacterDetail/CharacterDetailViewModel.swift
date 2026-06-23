import Foundation
import Combine

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    @Published private(set) var character: CharacterDetail?
    @Published private(set) var state: ViewState = .idle
    @Published private(set) var isFavorite = false

    private let characterID: Int
    private let fetchCharacterDetailUseCase: FetchCharacterDetailUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase

    init(
        characterID: Int,
        fetchCharacterDetailUseCase: FetchCharacterDetailUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase
    ) {
        self.characterID = characterID
        self.fetchCharacterDetailUseCase = fetchCharacterDetailUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.isFavorite = toggleFavoriteUseCase.isFavorite(characterID: characterID)
    }

    func onAppear() async {
        guard character == nil else { return }
        await load()
    }

    func retry() async {
        await load()
    }

    func toggleFavorite() {
        isFavorite = toggleFavoriteUseCase.execute(characterID: characterID)
    }

    private func load() async {
        state = .loading

        do {
            character = try await fetchCharacterDetailUseCase.execute(id: characterID)
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
