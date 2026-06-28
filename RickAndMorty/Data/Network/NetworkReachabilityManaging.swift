import Foundation

protocol NetworkReachabilityManaging: Sendable {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
}
