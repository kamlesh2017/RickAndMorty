import Foundation
import Combine

@MainActor
final class CharacterListViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loadingMore
        case loaded
        case empty
        case error(String)
        case offlineCached
    }

    @Published private(set) var characters: [Character] = []
    @Published private(set) var state: ViewState = .idle
    @Published private(set) var hasNextPage = false
    @Published private(set) var favoriteIDs: Set<Int> = []

    @Published var searchText = "" {
        didSet {
            scheduleSearch()
        }
    }

    @Published var selectedStatus: CharacterStatus? {
        didSet {
            guard oldValue != selectedStatus else { return }
            Task { await reload() }
        }
    }

    private let fetchCharactersUseCase: FetchCharactersUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private var currentQuery = CharacterQuery.initial()
    private var searchTask: Task<Void, Never>?
    private var isFetching = false

    init(
        fetchCharactersUseCase: FetchCharactersUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase
    ) {
        self.fetchCharactersUseCase = fetchCharactersUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }

    func onAppear() async {
        guard characters.isEmpty else { return }
        await reload()
    }

    func reload() async {
        currentQuery = CharacterQuery.initial(
            name: normalizedSearchText,
            status: selectedStatus
        )
        characters = []
        hasNextPage = false
        await fetch(reset: true)
    }

    func loadNextPageIfNeeded(currentCharacter: Character) async {
        guard
            hasNextPage,
            !isFetching,
            currentCharacter.id == characters.last?.id
        else {
            return
        }

        currentQuery = currentQuery.nextPage()
        await fetch(reset: false)
    }

    func retry() async {
        await fetch(reset: characters.isEmpty)
    }

    func toggleFavorite(for characterID: Int) {
        toggleFavoriteUseCase.execute(characterID: characterID)
        favoriteIDs.formSymmetricDifference([characterID])
    }

    func isFavorite(_ characterID: Int) -> Bool {
        favoriteIDs.contains(characterID)
    }

    private var normalizedSearchText: String? {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await reload()
        }
    }

    private func fetch(reset: Bool) async {
        guard !isFetching else { return }
        isFetching = true
        state = reset ? .loading : .loadingMore

        do {
            let result = try await fetchCharactersUseCase.execute(query: currentQuery)

            if reset {
                characters = result.characters
            } else {
                characters.append(contentsOf: result.characters)
            }

            hasNextPage = result.hasNextPage
            refreshFavoriteState()

            if characters.isEmpty {
                state = .empty
            } else {
                state = .loaded
            }
        } catch {
            if characters.isEmpty, let cached = fetchCharactersUseCase.cachedResult() {
                characters = cached.characters
                hasNextPage = cached.hasNextPage
                refreshFavoriteState()
                state = .offlineCached
            } else if characters.isEmpty {
                state = .error(error.userFacingMessage)
            } else {
                state = .loaded
            }
        }

        isFetching = false
    }

    private func refreshFavoriteState() {
        favoriteIDs = Set(characters.map(\.id).filter { toggleFavoriteUseCase.isFavorite(characterID: $0) })
    }
}
