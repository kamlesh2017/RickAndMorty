import SwiftUI
import SwiftData

@main
struct RickAndMortyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let container = DependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CharacterListView(viewModel: container.makeCharacterListViewModel())
            }
        }
        .modelContainer(container.modelContainer)
    }
}
