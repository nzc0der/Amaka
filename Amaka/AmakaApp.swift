//
//  AmakaApp.swift
//  Amaka
//
//  Created by Noah Zipor on 16/5/2026.
//

import SwiftUI
import CoreData

@main
struct AmakaApp: App {
    init() {
        // Initialize Tailscale if an auth key is provided
        if !AppConfig.tailscaleAuthKey.isEmpty && AppConfig.tailscaleAuthKey != "tskey-auth-..." {
            TailscaleManager.shared.start(authKey: AppConfig.tailscaleAuthKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
