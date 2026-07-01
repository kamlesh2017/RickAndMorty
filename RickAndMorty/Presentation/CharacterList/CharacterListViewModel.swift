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
    private var nextPageURL: URL?
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
        nextPageURL = nil
        characters = []
        hasNextPage = false
        await fetch(reset: true, name: normalizedSearchText, status: selectedStatus)
    }

    func loadNextPageIfNeeded(currentCharacter: Character) async {
        guard
            let nextPageURL,
            hasNextPage,
            !isFetching,
            currentCharacter.id == characters.last?.id
        else {
            return
        }

        await fetch(reset: false, url: nextPageURL)
    }

    func retry() async {
        if characters.isEmpty {
            await fetch(reset: true, name: normalizedSearchText, status: selectedStatus)
        } else if let nextPageURL {
            await fetch(reset: false, url: nextPageURL)
        }
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

    private func fetch(reset: Bool, name: String? = nil, status: CharacterStatus? = nil, url: URL? = nil) async {
        guard !isFetching else { return }
        isFetching = true
        state = reset ? .loading : .loadingMore

        do {
            let result: PaginatedCharacters
            if let url {
                result = try await fetchCharactersUseCase.execute(url: url)
            } else {
                result = try await fetchCharactersUseCase.execute(name: name, status: status)
            }

            if reset {
                characters = result.characters
            } else {
                characters.append(contentsOf: result.characters)
            }

            nextPageURL = result.nextPageURL
            hasNextPage = result.nextPageURL != nil
            refreshFavoriteState()

            if characters.isEmpty {
                state = .empty
            } else {
                state = .loaded
            }
        } catch {
            if reset, let cached = await fetchCharactersUseCase.cachedResult() {
                let filtered = applyLocalFilters(
                    to: cached,
                    name: name,
                    status: status
                )
                characters = filtered.characters
                nextPageURL = nil
                hasNextPage = false
                refreshFavoriteState()
                state = filtered.characters.isEmpty ? .empty : .offlineCached
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

    private func applyLocalFilters(
        to cached: PaginatedCharacters,
        name: String?,
        status: CharacterStatus?
    ) -> PaginatedCharacters {
        var filtered = cached.characters

        if let status {
            filtered = filtered.filter { $0.status == status }
        }

        if let name, !name.isEmpty {
            filtered = filtered.filter { ($0.name ?? "").localizedCaseInsensitiveContains(name) }
        }

        return PaginatedCharacters(characters: filtered, nextPageURL: nil)
    }
}
