import SwiftUI

@main
struct RickAndMortyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CharacterListView(viewModel: DependencyContainer.shared.makeCharacterListViewModel())
            }
        }
    }
}
