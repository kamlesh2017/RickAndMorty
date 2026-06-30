import SwiftUI
import XCTest
@testable import RickAndMorty

@MainActor
final class CharacterRowSnapshotTests: XCTestCase {
    func testCharacterRowAliveWithFavoriteSnapshot() throws {
        try SnapshotTesting.assertSnapshot(
            named: "CharacterRowAliveWithFavorite",
            for: CharacterRowView(
                character: .sample(id: 1, name: "Rick Sanchez", status: .alive),
                isFavorite: true
            )
        )
    }

    func testCharacterRowDeadSnapshot() throws {
        try SnapshotTesting.assertSnapshot(
            named: "CharacterRowDead",
            for: CharacterRowView(
                character: .sample(id: 2, name: "Birdperson", status: .dead),
                isFavorite: false
            )
        )
    }

    func testCharacterRowUnknownSnapshot() throws {
        try SnapshotTesting.assertSnapshot(
            named: "CharacterRowUnknown",
            for: CharacterRowView(
                character: .sample(id: 3, name: "Unknown Entity", status: .unknown),
                isFavorite: false
            )
        )
    }
}
