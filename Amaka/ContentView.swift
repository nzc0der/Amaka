//
//  ContentView.swift
//  Amaka
//
//  Created by Noah Zipor on 16/5/2026.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("server_url") private var serverURL: String = "http://amaka-hub/"
    @StateObject private var sync: SyncService
    @State private var showingSettings = false

    init() {
        let urlString = UserDefaults.standard.string(forKey: "server_url") ?? "http://amaka-hub/"
        let url = URL(string: urlString) ?? URL(string: "http://amaka-hub/")!
        _sync = StateObject(wrappedValue: SyncService(container: PersistenceController.shared.container, baseURL: url))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            DashboardView()
                .environmentObject(sync)
                .environment(\.managedObjectContext, viewContext)
            
            Button(action: { showingSettings.toggle() }) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.white.opacity(0.3))
                    .padding(24)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(serverURL: $serverURL, sync: sync)
        }
        .onAppear { sync.start() }
        .onDisappear { sync.stop() }
        .preferredColorScheme(.dark)
    }
}

struct SettingsView: View {
    @Binding var serverURL: String
    let sync: SyncService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Connection")) {
                    TextField("Server URL", text: $serverURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section {
                    Button("Save & Restart Sync") {
                        if let url = URL(string: serverURL) {
                            sync.updateBaseURL(url)
                        }
                        dismiss()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
        .preferredColorScheme(.dark)
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

