import Foundation

extension Error {
    var userFacingMessage: String {
        (self as? LocalizedError)?.errorDescription
            ?? "Something went wrong. Please try again later."
    }
}
