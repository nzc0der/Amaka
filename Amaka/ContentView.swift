//
//  ContentView.swift
//  Amaka
//
//  Created by Noah Zipor on 16/5/2026.
//

import SwiftUI
import Swift
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var sync = SyncService(container: PersistenceController.shared.container, baseURL: URL(string: "http://100.100.100.100:8080/")!)

    var body: some View {
        NavigationView {
            DashboardView()
                .environmentObject(sync)
                .environment(\.managedObjectContext, viewContext)
                .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { sync.start() }
        .onDisappear { sync.stop() }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
