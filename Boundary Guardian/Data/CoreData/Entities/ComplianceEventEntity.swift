// MARK: - ComplianceEventEntity.swift
// Boundary Guardian
// Core Data entity for compliance/breach events

import CoreData
import SwiftUI

// MARK: - Compliance Event Entity
/// Entity representing a compliance or breach event
/// Each logging creates a new record
@objc(ComplianceEventEntity)
public class ComplianceEventEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var isKept: Bool              // true = kept, false = breached
    @NSManaged public var notes: String?            // Notes (especially for breaches)
    @NSManaged public var boundary: BoundaryEntity
    
    // MARK: - Computed Properties
    
    /// Event status
    var status: EventStatus {
        isKept ? .kept : .breached
    }
    
    /// Event color
    var color: Color {
        isKept ? AppColors.protectiveEmerald : AppColors.breachRed
    }
    
    /// Event icon
    var icon: String {
        isKept ? "checkmark.shield.fill" : "xmark.shield.fill"
    }
    
    /// Status text
    var statusText: String {
        isKept ? "Kept" : "Breached"
    }
    
    /// Formatted date (relative)
    var formattedDate: String {
        date.relative
    }
    
    /// Detailed date
    var detailedDate: String {
        date.dateTime
    }
}

// MARK: - Event Status
enum EventStatus {
    case kept
    case breached
    
    var color: Color {
        switch self {
        case .kept: return AppColors.protectiveEmerald
        case .breached: return AppColors.breachRed
        }
    }
    
    var icon: String {
        switch self {
        case .kept: return "checkmark.shield.fill"
        case .breached: return "xmark.shield.fill"
        }
    }
    
    var text: String {
        switch self {
        case .kept: return "Kept"
        case .breached: return "Breached"
        }
    }
}

// MARK: - Fetch Requests
extension ComplianceEventEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComplianceEventEntity> {
        return NSFetchRequest<ComplianceEventEntity>(entityName: "ComplianceEventEntity")
    }
    
    /// Fetch request for events within a period
    static func fetchRequest(from startDate: Date, to endDate: Date) -> NSFetchRequest<ComplianceEventEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ComplianceEventEntity.date, ascending: false)
        ]
        return request
    }
    
    /// Fetch request for events of a boundary
    static func fetchRequest(for boundary: BoundaryEntity) -> NSFetchRequest<ComplianceEventEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "boundary == %@", boundary)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ComplianceEventEntity.date, ascending: false)
        ]
        return request
    }
    
    /// Fetch request for recent N events
    static func recentFetchRequest(limit: Int = 20) -> NSFetchRequest<ComplianceEventEntity> {
        let request = fetchRequest()
        request.fetchLimit = limit
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ComplianceEventEntity.date, ascending: false)
        ]
        return request
    }
}

// MARK: - Preview Helper
extension ComplianceEventEntity {
    @MainActor
    static var preview: ComplianceEventEntity {
        let context = PersistenceController.preview.container.viewContext
        let event = ComplianceEventEntity(context: context)
        event.id = UUID()
        event.date = Date()
        event.isKept = true
        event.notes = nil
        return event
    }
    
    @MainActor
    static var previewBreached: ComplianceEventEntity {
        let context = PersistenceController.preview.container.viewContext
        let event = ComplianceEventEntity(context: context)
        event.id = UUID()
        event.date = Date()
        event.isKept = false
        event.notes = "Lent $600 to a colleague"
        return event
    }
}
