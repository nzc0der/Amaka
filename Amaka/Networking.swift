import Foundation
import CoreData
import Combine

struct DashboardResponse: Decodable {
    var family: [FamilyDTO]
    var events: [EventDTO]
    var shopping: [ShoppingDTO]
    var note: NoteDTO?
    var pi: PiDTO?
}

struct FamilyDTO: Decodable { let id: String; let name: String; let avatarURL: String?; let status: String?; let isCurrentUser: Bool? }
struct EventDTO: Decodable { let id: String; let title: String; let date: Date; let personId: String? }
struct ShoppingDTO: Decodable { let id: String; let title: String; let completed: Bool }
struct NoteDTO: Decodable { let id: String; let content: String? }
struct PiDTO: Decodable { let id: String; let tailscaleConnected: Bool; let cpuUsage: Double; let storageUsage: Double }

final class APIClient {
    let baseURL: URL
    let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchDashboard() async throws -> DashboardResponse {
        var request = URLRequest(url: baseURL.appendingPathComponent("api/dashboard"))
        request.timeoutInterval = 8
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DashboardResponse.self, from: data)
    }
}

final class SyncService: ObservableObject {
    @Published private(set) var lastSync: Date?
    @Published private(set) var lastError: String?

    private var isRunning = false
    private let client: APIClient
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer, baseURL: URL) {
        self.container = container
        self.client = APIClient(baseURL: baseURL)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        Task.detached { [weak self] in
            await self?.runLoop()
        }
    }

    private func sleepTenSeconds() async {
        try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
    }

    private func runLoop() async {
        while isRunning {
            await fetchAndMerge()
            await sleepTenSeconds()
        }
    }

    @MainActor
    func stop() { isRunning = false }

    private func fetchAndMerge() async {
        do {
            let response = try await client.fetchDashboard()
            let context = container.newBackgroundContext()
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            try await context.perform {
                // Family
                for item in response.family {
                    let fetch: NSFetchRequest<FamilyMember> = FamilyMember.fetchRequest()
                    fetch.predicate = NSPredicate(format: "id == %@", item.id)
                    let existing = try context.fetch(fetch).first
                    let obj = existing ?? FamilyMember(context: context)
                    obj.id = item.id
                    obj.name = item.name
                    obj.avatarURL = item.avatarURL
                    obj.status = item.status
                    obj.isCurrentUser = item.isCurrentUser ?? false
                }
                // Events
                for e in response.events {
                    let fetch: NSFetchRequest<CalendarEvent> = CalendarEvent.fetchRequest()
                    fetch.predicate = NSPredicate(format: "id == %@", e.id)
                    let existing = try context.fetch(fetch).first
                    let obj = existing ?? CalendarEvent(context: context)
                    obj.id = e.id
                    obj.title = e.title
                    obj.date = e.date
                    obj.personId = e.personId
                }
                // Shopping
                for s in response.shopping {
                    let fetch: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
                    fetch.predicate = NSPredicate(format: "id == %@", s.id)
                    let existing = try context.fetch(fetch).first
                    let obj = existing ?? ShoppingItem(context: context)
                    obj.id = s.id
                    obj.title = s.title
                    obj.completed = s.completed
                }
                // Note (single)
                if let n = response.note {
                    let fetch: NSFetchRequest<SecureNote> = SecureNote.fetchRequest()
                    fetch.predicate = NSPredicate(format: "id == %@", n.id)
                    let existing = try context.fetch(fetch).first
                    let obj = existing ?? SecureNote(context: context)
                    obj.id = n.id
                    obj.content = n.content
                }
                // Pi status (single)
                if let p = response.pi {
                    let fetch: NSFetchRequest<PiStatus> = PiStatus.fetchRequest()
                    fetch.predicate = NSPredicate(format: "id == %@", p.id)
                    let existing = try context.fetch(fetch).first
                    let obj = existing ?? PiStatus(context: context)
                    obj.id = p.id
                    obj.tailscaleConnected = p.tailscaleConnected
                    obj.cpuUsage = p.cpuUsage
                    obj.storageUsage = p.storageUsage
                }
                if context.hasChanges { try context.save() }
            }
            await MainActor.run {
                self.lastError = nil
                self.lastSync = Date()
            }
        } catch {
            await MainActor.run {
                self.lastError = error.localizedDescription
            }
        }
    }
}

extension FamilyMember {
    @nonobjc class func fetchRequest() -> NSFetchRequest<FamilyMember> {
        NSFetchRequest<FamilyMember>(entityName: "FamilyMember")
    }
}
extension CalendarEvent {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CalendarEvent> {
        NSFetchRequest<CalendarEvent>(entityName: "CalendarEvent")
    }
}
extension ShoppingItem {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ShoppingItem> {
        NSFetchRequest<ShoppingItem>(entityName: "ShoppingItem")
    }
}
extension SecureNote {
    @nonobjc class func fetchRequest() -> NSFetchRequest<SecureNote> {
        NSFetchRequest<SecureNote>(entityName: "SecureNote")
    }
}
extension PiStatus {
    @nonobjc class func fetchRequest() -> NSFetchRequest<PiStatus> {
        NSFetchRequest<PiStatus>(entityName: "PiStatus")
    }
}

