import SwiftUI
import CoreData
import Combine

// MARK: - Styling
private let slateBackground = LinearGradient(
    colors: [Color(red: 0.07, green: 0.08, blue: 0.10), Color(red: 0.03, green: 0.03, blue: 0.04)],
    startPoint: .topLeading, endPoint: .bottomTrailing
)

struct BentoCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .blendMode(.overlay)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 12)
    }
}

// MARK: - Weather Widget
struct WeatherWidget: View {
    @StateObject private var weatherManager = WeatherManager()

    var body: some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "cloud.sun.fill")
                        .symbolRenderingMode(.multicolor)
                        .font(.title2)
                    Spacer()
                    Text("\(weatherManager.temperature)°")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }

                Text(weatherManager.condition)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))

                HStack {
                    Text("H:\(weatherManager.high)°")
                    Text("L:\(weatherManager.low)°")
                }
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))

                Text(weatherManager.location)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
        }
    }
}

// MARK: - Family Status Board
struct FamilyStatusBoard: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \FamilyMember.name, ascending: true)])
    private var members: FetchedResults<FamilyMember>
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "person.3.fill").foregroundColor(.white)
                    Text("Family").foregroundColor(.white).font(.headline)
                    Spacer()
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(members, id: \.objectID) { member in
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle().fill(Color.white.opacity(0.10)).frame(width: 64, height: 64)
                                    Image(systemName: "person.crop.circle.fill").resizable().foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                }
                                Text(member.name).font(.footnote).foregroundColor(.white.opacity(0.95))
                                Text(member.status ?? "Unknown")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Capsule().fill(Color.blue.opacity(0.28)))
                            }
                        }
                    }
                }
                if let me = members.first(where: { $0.isCurrentUser }) {
                    Button(action: { toggleStatus(for: me) }) {
                        Label("Toggle My Status", systemImage: "arrow.2.circlepath")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Capsule().fill(Color.blue.opacity(0.35)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func toggleStatus(for member: FamilyMember) {
        let options = ["At Home", "At Work", "Gym", "Away"]
        let current = member.status ?? options.first!
        let nextIndex = (options.firstIndex(of: current).map { (options.index(after: $0)) % options.count } ?? 0)
        member.status = options[nextIndex]
        try? context.save()
    }
}

// MARK: - Calendar Widget
struct CalendarWidget: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CalendarEvent.date, ascending: true)],
        predicate: NSPredicate(format: "date >= %@", Date() as NSDate),
        animation: .default
    ) private var events: FetchedResults<CalendarEvent>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \FamilyMember.name, ascending: true)])
    private var members: FetchedResults<FamilyMember>

    private func color(for personId: String?) -> Color {
        guard let id = personId, let index = members.firstIndex(where: { $0.id == id }) else { return .teal }
        let palette: [Color] = [.pink, .orange, .purple, .blue, .green, .mint, .yellow]
        return palette[index % palette.count]
    }

    var body: some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack { Label("Upcoming", systemImage: "calendar").foregroundColor(.white.opacity(0.95)); Spacer() }
                ForEach(events.prefix(3), id: \.objectID) { ev in
                    HStack(spacing: 10) {
                        Circle().fill(color(for: ev.personId).opacity(0.9)).frame(width: 8, height: 8)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ev.title).foregroundColor(.white)
                            Text(ev.date, style: .date).font(.caption2).foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                    }
                }
                if events.isEmpty { Text("No events").foregroundColor(.white.opacity(0.6)).font(.caption) }
            }
        }
    }
}

// MARK: - Shopping List
struct ShoppingListWidget: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ShoppingItem.title, ascending: true)])
    private var items: FetchedResults<ShoppingItem>
    @State private var newItem: String = ""

    var body: some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack { Label("Shopping", systemImage: "cart").foregroundColor(.white.opacity(0.95)); Spacer() }
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(items, id: \.objectID) { item in
                            Button(action: { toggle(item) }) {
                                HStack(spacing: 10) {
                                    Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.completed ? .green : .white.opacity(0.7))
                                    Text(item.title)
                                        .strikethrough(item.completed, color: .white.opacity(0.7))
                                        .foregroundColor(.white)
                                        .animation(.easeInOut(duration: 0.2), value: item.completed)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                HStack(spacing: 8) {
                    TextField("Quick Add", text: $newItem)
                        .textFieldStyle(.roundedBorder)
                    Button(action: add) { Image(systemName: "plus.circle.fill").font(.title3) }
                        .tint(.blue)
                }
            }
        }
    }

    private func toggle(_ item: ShoppingItem) {
        item.completed.toggle()
        try? context.save()
    }

    private func add() {
        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let obj = ShoppingItem(context: context)
        obj.id = UUID().uuidString
        obj.title = trimmed
        obj.completed = false
        try? context.save()
        newItem = ""
    }
}

// MARK: - Secure Notes
struct SecureNotesWidget: View {
    @FetchRequest(sortDescriptors: []) private var notes: FetchedResults<SecureNote>
    var body: some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill").foregroundColor(.green)
                    Text("End-to-End Encrypted").foregroundColor(.white.opacity(0.85)).font(.subheadline)
                    Spacer()
                }
                Text(notes.first?.content ?? "No shared note yet.")
                    .foregroundColor(.white)
                    .lineLimit(5)
            }
        }
    }
}

// MARK: - Pi Status
struct PiStatusWidget: View {
    @FetchRequest(sortDescriptors: []) private var statuses: FetchedResults<PiStatus>

    var body: some View {
        let status = statuses.first
        return BentoCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Circle().fill((status?.tailscaleConnected ?? false) ? Color.green : Color.red).frame(width: 10, height: 10)
                    Text("Tailscale Connected").foregroundColor(.white.opacity(0.95))
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("CPU").font(.caption2).foregroundColor(.white.opacity(0.7))
                    ProgressView(value: status?.cpuUsage ?? 0.0).tint(.green)
                    Text("Storage").font(.caption2).foregroundColor(.white.opacity(0.7))
                    ProgressView(value: status?.storageUsage ?? 0.0).tint(.blue)
                }
            }
        }
    }
}

// MARK: - Greeting Header
struct GreetingHeader: View {
    @EnvironmentObject var sync: SyncService

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            HStack {
                Text(dateString)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))

                Circle()
                    .fill(sync.lastSync != nil ? Color.green : Color.orange)
                    .frame(width: 6, height: 6)

                Text(sync.lastSync != nil ? "Synced" : "Connecting...")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Dashboard Grid
struct DashboardView: View {
    @EnvironmentObject var sync: SyncService

    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GreetingHeader()
                    .padding(.top, 10)

                // Weather and Pi status in a row
                HStack(spacing: 16) {
                    WeatherWidget()
                    PiStatusWidget()
                }

                // Full-width Family status
                FamilyStatusBoard()

                // Grid for other widgets
                LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                    CalendarWidget()
                    SecureNotesWidget()
                }

                // Full-width tall card
                ShoppingListWidget()
            }
            .padding(16)
        }
        .background(slateBackground.ignoresSafeArea())
    }
}
