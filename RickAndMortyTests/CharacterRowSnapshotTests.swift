import SwiftUI
import UIKit
import XCTest
@testable import RickAndMorty

@MainActor
final class CharacterRowSnapshotTests: XCTestCase {
    func testCharacterRowRendersAliveState() {
        assertSnapshot(
            for: CharacterRowView(
                character: .sample(id: 1, name: "Rick Sanchez", status: .alive),
                isFavorite: true
            )
        )
    }

    func testCharacterRowRendersDeadState() {
        assertSnapshot(
            for: CharacterRowView(
                character: .sample(id: 2, name: "Birdperson", status: .dead),
                isFavorite: false
            )
        )
    }

    func testCharacterRowRendersUnknownState() {
        assertSnapshot(
            for: CharacterRowView(
                character: .sample(id: 3, name: "Unknown Entity", status: .unknown),
                isFavorite: false
            )
        )
    }

    private func assertSnapshot<V: View>(for view: V, width: CGFloat = 375, height: CGFloat = 88) {
        let host = UIHostingController(
            rootView: view
                .padding(.horizontal, 16)
                .frame(width: width, height: height)
                .background(Color(.systemBackground))
        )
        host.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        host.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: host.view.bounds.size)
        let image = renderer.image { _ in
            host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
        }

        XCTAssertGreaterThan(image.size.width, 0)
        XCTAssertGreaterThan(image.size.height, 0)
    }
}
