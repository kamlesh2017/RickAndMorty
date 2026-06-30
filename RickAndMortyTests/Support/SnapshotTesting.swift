import CryptoKit
import Foundation
import SwiftUI
import UIKit
import XCTest

enum SnapshotTesting {
    static func assertSnapshot<V: View>(
        named name: String,
        for view: V,
        width: CGFloat = 375,
        height: CGFloat = 88,
        file: StaticString = #filePath
    ) throws {
        let snapshotView = view
            .padding(.horizontal, 16)
            .frame(width: width, height: height)
            .background(Color.white)

        let image = renderImage(from: snapshotView, size: CGSize(width: width, height: height))
        let hash = try sha256Hex(from: image)
        let snapshotURL = snapshotFileURL(named: "\(name).sha256", file: file)
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: snapshotURL.path) {
            try fileManager.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try (hash + "\n").write(to: snapshotURL, atomically: true, encoding: .utf8)
            return
        }

        let expectedHash = try String(contentsOf: snapshotURL, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(
            hash,
            expectedHash,
            "\(name) snapshot changed. Expected: \(expectedHash), Actual: \(hash). Delete the snapshot file to regenerate."
        )
    }

    static func snapshotFileURL(named fileName: String, file: StaticString) -> URL {
        URL(fileURLWithPath: file.description)
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__", isDirectory: true)
            .appendingPathComponent(fileName, isDirectory: false)
    }

    static func renderImage<V: View>(from view: V, size: CGSize) -> UIImage {
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(true) }

        let controller = UIHostingController(
            rootView: view.transaction { $0.disablesAnimations = true }
        )
        controller.overrideUserInterfaceStyle = .light
        controller.view.frame = CGRect(origin: .zero, size: size)
        controller.view.contentScaleFactor = 2
        controller.view.backgroundColor = .white
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        format.scale = 2

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            controller.view.layer.render(in: context.cgContext)
        }
    }

    static func sha256Hex(from image: UIImage) throws -> String {
        let cgImage = try XCTUnwrap(image.cgImage, "Failed to read CGImage from rendered snapshot.")
        let data = try XCTUnwrap(cgImage.dataProvider?.data, "Failed to read pixel buffer data.")
        let bytes = data as Data
        return SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }
}
