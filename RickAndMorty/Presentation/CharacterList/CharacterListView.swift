import SwiftUI

struct CharacterListView: View {
    @StateObject private var viewModel: CharacterListViewModel

    init(viewModel: CharacterListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(text: $viewModel.searchText, prompt: "Search by name")

            filterBar

            listContent
        }
        .background(AppColors.groupedBackground)
        .navigationTitle("Characters")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if viewModel.state == .offlineCached {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Label("Offline", systemImage: "wifi.slash")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationDestination(for: Int.self) { characterID in
            CharacterDetailView(
                viewModel: DependencyContainer.shared.makeCharacterDetailViewModel(characterID: characterID)
            )
        }
        .task {
            await viewModel.onAppear()
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChipView(
                    title: "All",
                    isSelected: viewModel.selectedStatus == nil
                ) {
                    viewModel.selectedStatus = nil
                }

                ForEach(CharacterStatus.allCases, id: \.self) { status in
                    FilterChipView(
                        title: status.rawValue,
                        isSelected: viewModel.selectedStatus == status
                    ) {
                        viewModel.selectedStatus = viewModel.selectedStatus == status ? nil : status
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    private var listContent: some View {
        List {
            if viewModel.state == .loading {
                loadingSection
            } else {
                characterSection

                if viewModel.state == .loadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            overlayContent
        }
    }

    private var loadingSection: some View {
        Section {
            ForEach(0 ..< 8, id: \.self) { _ in
                CharacterRowSkeletonView()
            }
        }
    }

    private var characterSection: some View {
        Section {
            ForEach(viewModel.characters) { character in
                HStack(spacing: 0) {
                    NavigationLink(value: character.id) {
                        CharacterRowView(
                            character: character,
                            isFavorite: viewModel.isFavorite(character.id),
                            showsFavoriteButton: false
                        )
                    }

                    Button {
                        viewModel.toggleFavorite(for: character.id)
                    } label: {
                        Image(systemName: viewModel.isFavorite(character.id) ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.isFavorite(character.id) ? .red : .secondary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        viewModel.isFavorite(character.id) ? "Remove from favorites" : "Add to favorites"
                    )
                }
                .task {
                    await viewModel.loadNextPageIfNeeded(currentCharacter: character)
                }
            }
        }
    }

    @ViewBuilder
    private var overlayContent: some View {
        switch viewModel.state {
        case .empty:
            EmptyStateView(
                title: "No Characters Found",
                systemImage: "magnifyingglass",
                message: "Try adjusting your search or filters."
            )
        case .error(let message):
            EmptyStateView(
                title: "Something Went Wrong",
                systemImage: "exclamationmark.triangle",
                message: message,
                actionTitle: "Retry"
            ) {
                Task { await viewModel.retry() }
            }
        default:
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        CharacterListView(viewModel: DependencyContainer.preview.makeCharacterListViewModel())
    }
}
