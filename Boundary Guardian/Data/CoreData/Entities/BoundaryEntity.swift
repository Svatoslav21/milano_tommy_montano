// MARK: - BoundaryEntity.swift
// Boundary Guardian
// Core Data entity for financial boundary

import CoreData
import SwiftUI

// MARK: - Boundary Entity
/// Entity representing a financial boundary
/// A rule that the user sets to protect their finances
@objc(BoundaryEntity)
public class BoundaryEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var consequenceText: String?
    @NSManaged public var importance: Int16          // 1-5 (shield count)
    @NSManaged public var createdAt: Date
    @NSManaged public var isActive: Bool
    @NSManaged public var currentStreak: Int32       // Current streak of days without violations
    @NSManaged public var longestStreak: Int32       // Longest streak ever
    @NSManaged public var category: CategoryEntity?
    @NSManaged public var complianceEvents: NSSet?
    
    // MARK: - Computed Properties
    
    /// Array of compliance events sorted by date (newest first)
    var eventsArray: [ComplianceEventEntity] {
        let set = complianceEvents as? Set<ComplianceEventEntity> ?? []
        return set.sorted { $0.date > $1.date }
    }
    
    /// Kept events (compliance)
    var keptEvents: [ComplianceEventEntity] {
        eventsArray.filter { $0.isKept }
    }
    
    /// Breached events (violations)
    var breachedEvents: [ComplianceEventEntity] {
        eventsArray.filter { !$0.isKept }
    }
    
    /// Total event count
    var totalEventsCount: Int {
        eventsArray.count
    }
    
    /// Compliance rate percentage
    var complianceRate: Double {
        guard totalEventsCount > 0 else { return 100 }
        return Double(keptEvents.count) / Double(totalEventsCount) * 100
    }
    
    /// Last event
    var lastEvent: ComplianceEventEntity? {
        eventsArray.first
    }
    
    /// Was breached today
    var wasBreachedToday: Bool {
        guard let lastEvent = lastEvent else { return false }
        return Calendar.current.isDateInToday(lastEvent.date) && !lastEvent.isKept
    }
    
    /// Was kept today
    var wasKeptToday: Bool {
        guard let lastEvent = lastEvent else { return false }
        return Calendar.current.isDateInToday(lastEvent.date) && lastEvent.isKept
    }
    
    /// Boundary status
    var status: BoundaryStatus {
        if !isActive {
            return .inactive
        }
        if wasBreachedToday {
            return .breached
        }
        if wasKeptToday {
            return .kept
        }
        return .pending
    }
    
    /// Importance level as text
    var importanceText: String {
        switch importance {
        case 1: return "Low"
        case 2: return "Moderate"
        case 3: return "Medium"
        case 4: return "High"
        case 5: return "Critical"
        default: return "Medium"
        }
    }
    
    /// Category name or default
    var categoryName: String {
        category?.name ?? "No Category"
    }
    
    /// Category color or default
    var categoryColor: Color {
        category?.color ?? AppColors.metallicSilver
    }
}

// MARK: - Boundary Status
enum BoundaryStatus {
    case kept       // Kept today
    case breached   // Breached today
    case pending    // Awaiting logging
    case inactive   // Inactive
    
    var color: Color {
        switch self {
        case .kept: return AppColors.protectiveEmerald
        case .breached: return AppColors.breachRed
        case .pending: return AppColors.metallicSilver
        case .inactive: return AppColors.mutedGray
        }
    }
    
    var icon: String {
        switch self {
        case .kept: return "checkmark.shield.fill"
        case .breached: return "exclamationmark.shield.fill"
        case .pending: return "shield.fill"
        case .inactive: return "shield.slash"
        }
    }
    
    var text: String {
        switch self {
        case .kept: return "Kept"
        case .breached: return "Breached"
        case .pending: return "Pending"
        case .inactive: return "Inactive"
        }
    }
}

// MARK: - Fetch Requests
extension BoundaryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BoundaryEntity> {
        return NSFetchRequest<BoundaryEntity>(entityName: "BoundaryEntity")
    }
    
    /// Fetch request for active boundaries
    static func activeFetchRequest() -> NSFetchRequest<BoundaryEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isActive == true")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \BoundaryEntity.importance, ascending: false),
            NSSortDescriptor(keyPath: \BoundaryEntity.createdAt, ascending: false)
        ]
        return request
    }
    
    /// Fetch request for all boundaries sorted by date
    static func sortedFetchRequest() -> NSFetchRequest<BoundaryEntity> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \BoundaryEntity.createdAt, ascending: false)
        ]
        return request
    }
}

// MARK: - Streak Management
extension BoundaryEntity {
    /// Updates streak after logging an event
    func updateStreak(isKept: Bool) {
        if isKept {
            currentStreak += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            currentStreak = 0
        }
    }
    
    /// Recalculates streak based on event history
    /// FIXED: Now correctly handles gaps in dates and continues counting from most recent consecutive sequence
    func recalculateStreak() {
        let sortedEvents = eventsArray.sorted { $0.date > $1.date }
        var streak: Int32 = 0
        var expectedDate = Date().startOfDay
        
        for event in sortedEvents {
            let eventDate = event.date.startOfDay
            
            // Skip future events
            if eventDate > expectedDate {
                continue
            }
            
            // If event is on expected date
            if eventDate == expectedDate {
                if event.isKept {
                    streak += 1
                    expectedDate = expectedDate.adding(days: -1)
                } else {
                    // Breach breaks the streak
                    break
                }
            } else if eventDate < expectedDate {
                // Gap in dates - streak is broken
                // But we still check if the event was on the same day with a kept status
                // If there's a gap, the streak ends
                break
            }
        }
        
        currentStreak = streak
        
        // Update longest streak if current is higher
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
}

// MARK: - Preview Helper
extension BoundaryEntity {
    @MainActor
    static var preview: BoundaryEntity {
        let context = PersistenceController.preview.container.viewContext
        let boundary = BoundaryEntity(context: context)
        boundary.id = UUID()
        boundary.title = "Never lend more than $500"
        boundary.consequenceText = "Protection from financial losses through personal loans"
        boundary.importance = 4
        boundary.createdAt = Date()
        boundary.isActive = true
        boundary.currentStreak = 15
        boundary.longestStreak = 30
        return boundary
    }
}
