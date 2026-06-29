import Foundation
import Network

final class NetworkReachabilityManager: NetworkReachabilityManaging, @unchecked Sendable {
    static let shared = NetworkReachabilityManager()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.rickandmorty.networkmonitor")
    private let lock = NSLock()
    private var connected = true

    private init() {}

    var isConnected: Bool {
        lock.lock()
        defer { lock.unlock() }
        return connected
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            lock.lock()
            connected = path.status == .satisfied
            lock.unlock()
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
