import SwiftUI
import CoreData
import Combine

// MARK: - Design System
struct AppTheme {
    static let background = LinearGradient(
        colors: [Color(hex: "07080A"), Color(hex: "030304")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let accentBlue = Color(hex: "3B82F6")
    static let accentPink = Color(hex: "EC4899")
    static let accentGreen = Color(hex: "10B981")
    static let accentOrange = Color(hex: "F59E0B")
    
    static let cardGradient = LinearGradient(
        colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Components
struct PremiumBentoCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    
    var body: some View {
        content
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(AppTheme.cardGradient)
                    
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.12), .clear, .white.opacity(0.05)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Family Status Board
struct FamilyStatusBoard: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \FamilyMember.name, ascending: true)])
    private var members: FetchedResults<FamilyMember>
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        PremiumBentoCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                    Text("Family Status")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(members, id: \.objectID) { member in
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.accentBlue.opacity(0.1))
                                        .frame(width: 72, height: 72)
                                    
                                    if let urlString = member.avatarURL, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image.resizable().clipShape(Circle())
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 64, height: 64)
                                    } else {
                                        Text(String(member.name.prefix(1)))
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    
                                    // Status Indicator
                                    Circle()
                                        .stroke(Color.black, lineWidth: 3)
                                        .background(Circle().fill(AppTheme.accentGreen))
                                        .frame(width: 14, height: 14)
                                        .offset(x: 24, y: 24)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(member.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text(member.status ?? "Offline")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color.white.opacity(0.05)))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Calendar Widget
struct CalendarWidget: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CalendarEvent.date, ascending: true)],
        predicate: NSPredicate(format: "date >= %@", Date() as NSDate)
    ) private var events: FetchedResults<CalendarEvent>

    var body: some View {
        PremiumBentoCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.accentPink)
                    Text("Events")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(events.prefix(3), id: \.objectID) { ev in
                        HStack(spacing: 12) {
                            VStack {
                                Text(ev.date, format: .dateTime.day())
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text(ev.date, format: .dateTime.month(.abbreviated))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(AppTheme.accentPink)
                            }
                            .frame(width: 36, height: 40)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ev.title)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(ev.date, style: .time)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                    
                    if events.isEmpty {
                        Text("No upcoming events")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.top, 4)
                    }
                }
            }
        }
    }
}

// MARK: - Shopping Widget
struct ShoppingListWidget: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ShoppingItem.title, ascending: true)])
    private var items: FetchedResults<ShoppingItem>
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        PremiumBentoCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.accentOrange)
                    Text("Shopping")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(items.filter { !$0.completed }.count) items")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                VStack(spacing: 8) {
                    ForEach(items.prefix(4), id: \.objectID) { item in
                        HStack(spacing: 12) {
                            Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.completed ? AppTheme.accentGreen : .white.opacity(0.2))
                                .font(.system(size: 18))
                            
                            Text(item.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(item.completed ? .white.opacity(0.3) : .white)
                                .strikethrough(item.completed)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(item.completed ? 0.02 : 0.04))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

// MARK: - Server Status Widget
struct PiStatusWidget: View {
    @FetchRequest(sortDescriptors: []) private var statuses: FetchedResults<PiStatus>

    var body: some View {
        let status = statuses.first
        PremiumBentoCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "cpu")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.accentGreen)
                    Text("Server")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Circle()
                        .fill((status?.tailscaleConnected ?? false) ? AppTheme.accentGreen : .red)
                        .frame(width: 8, height: 8)
                        .shadow(color: (status?.tailscaleConnected ?? false) ? AppTheme.accentGreen.opacity(0.5) : .red.opacity(0.5), radius: 4)
                }
                
                VStack(spacing: 12) {
                    MetricRow(label: "CPU", value: status?.cpuUsage ?? 0, color: AppTheme.accentGreen)
                    MetricRow(label: "Disk", value: status?.storageUsage ?? 0, color: AppTheme.accentBlue)
                }
            }
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("\(Int(value * 100))%").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.05))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value))
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Shared Note Widget
struct SecureNotesWidget: View {
    @FetchRequest(sortDescriptors: []) private var notes: FetchedResults<SecureNote>
    
    var body: some View {
        PremiumBentoCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                    Text("Shared Note")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                Text(notes.first?.content ?? "No shared notes available yet. Tap to add.")
                    .font(.system(size: 13))
                    .lineSpacing(4)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var sync: SyncService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good Evening,")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        Text("Noah")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 44, height: 44)
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Status Board
                FamilyStatusBoard()
                    .padding(.horizontal, 20)
                
                // Two Column Grid
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 16) {
                        CalendarWidget()
                        PiStatusWidget()
                    }
                    VStack(spacing: 16) {
                        SecureNotesWidget()
                        ShoppingListWidget()
                    }
                }
                .padding(.horizontal, 20)
                
                // Footer / Sync Info
                HStack {
                    Circle()
                        .fill(sync.lastError == nil ? AppTheme.accentGreen : Color.red)
                        .frame(width: 6, height: 6)
                    Text(sync.lastSync != nil ? "Last synced at \(sync.lastSync!, format: .dateTime.hour().minute().second())" : "Syncing...")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.vertical, 20)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

