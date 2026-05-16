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
    @StateObject private var sync = SyncService(container: PersistenceController.shared.container, baseURL: AppConfig.baseURL)

    @State private var showMenu = false
    @State private var selectedTab = "Dashboard"

    var body: some View {
        NavigationStack {
            ZStack {
                // Side Menu
                SideMenuView(showMenu: $showMenu, selectedTab: $selectedTab)

                // Main Content
                ZStack {
                    Color(red: 0.07, green: 0.08, blue: 0.10)
                        .ignoresSafeArea()

                    Group {
                        if selectedTab == "Dashboard" {
                            DashboardView()
                        } else if selectedTab == "Family" {
                            FamilyDetailView()
                        } else if selectedTab == "Shopping List" {
                            ShoppingListView()
                        }
                    }
                }
                .cornerRadius(showMenu ? 25 : 0)
                .offset(x: showMenu ? 260 : 0)
                .scaleEffect(showMenu ? 0.9 : 1)
                .rotationEffect(.degrees(showMenu ? -5 : 0))
                .ignoresSafeArea(edges: showMenu ? .all : [])
                .environmentObject(sync)
                .environment(\.managedObjectContext, viewContext)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                showMenu.toggle()
                            }
                        } label: {
                            Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                    }
                }
            }
        }
        .onAppear { sync.start() }
        .onDisappear { sync.stop() }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Detailed Views
struct FamilyDetailView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \FamilyMember.name, ascending: true)])
    private var members: FetchedResults<FamilyMember>

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                FamilyStatusBoard()

                VStack(alignment: .leading, spacing: 15) {
                    Text("Details")
                        .font(.headline)
                        .foregroundColor(.white)

                    ForEach(members, id: \.id) { member in
                        BentoCard {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)

                                VStack(alignment: .leading) {
                                    Text(member.name)
                                        .font(.subheadline)
                                        .bold()
                                    Text(member.status ?? "Offline")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(red: 0.07, green: 0.08, blue: 0.10).ignoresSafeArea())
        .navigationTitle("Family")
    }
}

struct ShoppingListView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ShoppingListWidget()

                BentoCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Recent Activity", systemImage: "clock")
                            .font(.headline)
                        Text("No recent changes to the shopping list.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .background(Color(red: 0.07, green: 0.08, blue: 0.10).ignoresSafeArea())
        .navigationTitle("Shopping List")
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
