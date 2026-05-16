import SwiftUI

struct SideMenuView: View {
    @Binding var showMenu: Bool
    @Binding var selectedTab: String
    @StateObject private var tailscale = TailscaleManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "house.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                Text("Amaka")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top, 50)

            VStack(alignment: .leading, spacing: 20) {
                MenuButton(title: "Dashboard", icon: "square.grid.2x2.fill", isSelected: selectedTab == "Dashboard") {
                    selectedTab = "Dashboard"
                    withAnimation(.spring()) { showMenu = false }
                }

                MenuButton(title: "Family", icon: "person.3.fill", isSelected: selectedTab == "Family") {
                    selectedTab = "Family"
                    withAnimation(.spring()) { showMenu = false }
                }

                MenuButton(title: "Shopping List", icon: "cart.fill", isSelected: selectedTab == "Shopping List") {
                    selectedTab = "Shopping List"
                    withAnimation(.spring()) { showMenu = false }
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 15) {
                Divider().background(Color.white.opacity(0.2))

                HStack {
                    Image(systemName: tailscale.isConnected ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                        .foregroundColor(tailscale.isConnected ? .green : .red)
                    Text(tailscale.isConnected ? "Tailscale Active" : "Tailscale Disconnected")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.05, green: 0.05, blue: 0.07))
        .edgesIgnoringSafeArea(.all)
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .white.opacity(0.6))
                    .frame(width: 30)

                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
            .cornerRadius(12)
        }
    }
}
