import SwiftUI

@main
struct RickAndMortyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CharacterListView(viewModel: DependencyContainer.shared.makeCharacterListViewModel())
            }
        }
    }
}
