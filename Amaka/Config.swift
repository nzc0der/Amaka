import Foundation

struct AppConfig {
    // The Tailscale IP of your home server
    static let serverIP = "100.x.y.z"
    static let serverPort = "8080"

    static var baseURL: URL {
        URL(string: "http://\(serverIP):\(serverPort)/")!
    }

    // Tailscale Auth Key (optional if using pre-authorized nodes)
    static let tailscaleAuthKey = "tskey-auth-..."
}
