import Foundation
import CoreData

@objc(FamilyMember)
public class FamilyMember: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var avatarURL: String?
    @NSManaged public var status: String?
    @NSManaged public var isCurrentUser: Bool
}

@objc(CalendarEvent)
public class CalendarEvent: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var date: Date
    @NSManaged public var personId: String?
}

@objc(ShoppingItem)
public class ShoppingItem: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var completed: Bool
}

@objc(SecureNote)
public class SecureNote: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var content: String?
}

@objc(PiStatus)
public class PiStatus: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var tailscaleConnected: Bool
    @NSManaged public var cpuUsage: Double
    @NSManaged public var storageUsage: Double
}
