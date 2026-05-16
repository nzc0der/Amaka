import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    // Programmatic model so this compiles without an .xcdatamodeld file
    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // FamilyMember entity
        let familyMember = NSEntityDescription()
        familyMember.name = "FamilyMember"
        familyMember.managedObjectClassName = NSStringFromClass(FamilyMember.self)
        var fmProps: [NSAttributeDescription] = []
        let fmId = NSAttributeDescription()
        fmId.name = "id"
        fmId.attributeType = .stringAttributeType
        fmId.isOptional = false
        fmProps.append(fmId)
        let fmName = NSAttributeDescription()
        fmName.name = "name"
        fmName.attributeType = .stringAttributeType
        fmName.isOptional = false
        fmProps.append(fmName)
        let fmAvatar = NSAttributeDescription()
        fmAvatar.name = "avatarURL"
        fmAvatar.attributeType = .stringAttributeType
        fmAvatar.isOptional = true
        fmProps.append(fmAvatar)
        let fmStatus = NSAttributeDescription()
        fmStatus.name = "status"
        fmStatus.attributeType = .stringAttributeType
        fmStatus.isOptional = true
        fmProps.append(fmStatus)
        let fmCurrent = NSAttributeDescription()
        fmCurrent.name = "isCurrentUser"
        fmCurrent.attributeType = .booleanAttributeType
        fmCurrent.isOptional = false
        fmCurrent.defaultValue = false
        fmProps.append(fmCurrent)
        familyMember.properties = fmProps

        // CalendarEvent entity
        let calendarEvent = NSEntityDescription()
        calendarEvent.name = "CalendarEvent"
        calendarEvent.managedObjectClassName = NSStringFromClass(CalendarEvent.self)
        var ceProps: [NSAttributeDescription] = []
        let ceId = NSAttributeDescription()
        ceId.name = "id"
        ceId.attributeType = .stringAttributeType
        ceId.isOptional = false
        ceProps.append(ceId)
        let ceTitle = NSAttributeDescription()
        ceTitle.name = "title"
        ceTitle.attributeType = .stringAttributeType
        ceTitle.isOptional = false
        ceProps.append(ceTitle)
        let ceDate = NSAttributeDescription()
        ceDate.name = "date"
        ceDate.attributeType = .dateAttributeType
        ceDate.isOptional = false
        ceProps.append(ceDate)
        let cePersonId = NSAttributeDescription()
        cePersonId.name = "personId"
        cePersonId.attributeType = .stringAttributeType
        cePersonId.isOptional = true
        ceProps.append(cePersonId)
        calendarEvent.properties = ceProps

        // ShoppingItem entity
        let shoppingItem = NSEntityDescription()
        shoppingItem.name = "ShoppingItem"
        shoppingItem.managedObjectClassName = NSStringFromClass(ShoppingItem.self)
        var siProps: [NSAttributeDescription] = []
        let siId = NSAttributeDescription()
        siId.name = "id"
        siId.attributeType = .stringAttributeType
        siId.isOptional = false
        siProps.append(siId)
        let siTitle = NSAttributeDescription()
        siTitle.name = "title"
        siTitle.attributeType = .stringAttributeType
        siTitle.isOptional = false
        siProps.append(siTitle)
        let siCompleted = NSAttributeDescription()
        siCompleted.name = "completed"
        siCompleted.attributeType = .booleanAttributeType
        siCompleted.isOptional = false
        siCompleted.defaultValue = false
        siProps.append(siCompleted)
        shoppingItem.properties = siProps

        // SecureNote entity
        let secureNote = NSEntityDescription()
        secureNote.name = "SecureNote"
        secureNote.managedObjectClassName = NSStringFromClass(SecureNote.self)
        var snProps: [NSAttributeDescription] = []
        let snId = NSAttributeDescription()
        snId.name = "id"
        snId.attributeType = .stringAttributeType
        snId.isOptional = false
        snProps.append(snId)
        let snContent = NSAttributeDescription()
        snContent.name = "content"
        snContent.attributeType = .stringAttributeType
        snContent.isOptional = true
        snProps.append(snContent)
        secureNote.properties = snProps

        // PiStatus entity
        let piStatus = NSEntityDescription()
        piStatus.name = "PiStatus"
        piStatus.managedObjectClassName = NSStringFromClass(PiStatus.self)
        var psProps: [NSAttributeDescription] = []
        let psId = NSAttributeDescription()
        psId.name = "id"
        psId.attributeType = .stringAttributeType
        psId.isOptional = false
        psProps.append(psId)
        let psTailscale = NSAttributeDescription()
        psTailscale.name = "tailscaleConnected"
        psTailscale.attributeType = .booleanAttributeType
        psTailscale.isOptional = false
        psTailscale.defaultValue = false
        psProps.append(psTailscale)
        let psCPU = NSAttributeDescription()
        psCPU.name = "cpuUsage"
        psCPU.attributeType = .doubleAttributeType
        psCPU.isOptional = false
        psCPU.defaultValue = 0.0
        psProps.append(psCPU)
        let psStorage = NSAttributeDescription()
        psStorage.name = "storageUsage"
        psStorage.attributeType = .doubleAttributeType
        psStorage.isOptional = false
        psStorage.defaultValue = 0.0
        psProps.append(psStorage)
        piStatus.properties = psProps

        model.entities = [familyMember, calendarEvent, shoppingItem, secureNote, piStatus]
        return model
    }

    init(inMemory: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "FamilyHub", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
}
