// MARK: - ComplianceRepository.swift
// Boundary Guardian
// Repository for compliance event operations

import CoreData
import SwiftUI

// MARK: - Compliance Repository Protocol
protocol ComplianceRepositoryProtocol {
    func fetchAll() -> [ComplianceEventEntity]
    func fetchRecent(limit: Int) -> [ComplianceEventEntity]
    func fetchForBoundary(_ boundary: BoundaryEntity) -> [ComplianceEventEntity]
    func fetchForPeriod(from: Date, to: Date) -> [ComplianceEventEntity]
    func logCompliance(boundary: BoundaryEntity, isKept: Bool, notes: String?) -> ComplianceEventEntity
    func delete(_ event: ComplianceEventEntity)
}

// MARK: - Compliance Repository
/// Repository for managing compliance/breach events
final class ComplianceRepository: @preconcurrency ComplianceRepositoryProtocol {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch all events
    func fetchAll() -> [ComplianceEventEntity] {
        let request = ComplianceEventEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ComplianceEventEntity.date, ascending: false)
        ]
        
        return performFetch(request)
    }
    
    /// Fetch recent N events
    func fetchRecent(limit: Int = 20) -> [ComplianceEventEntity] {
        let request = ComplianceEventEntity.recentFetchRequest(limit: limit)
        return performFetch(request)
    }
    
    /// Fetch events for boundary
    func fetchForBoundary(_ boundary: BoundaryEntity) -> [ComplianceEventEntity] {
        let request = ComplianceEventEntity.fetchRequest(for: boundary)
        return performFetch(request)
    }
    
    /// Fetch events for period
    func fetchForPeriod(from startDate: Date, to endDate: Date) -> [ComplianceEventEntity] {
        let request = ComplianceEventEntity.fetchRequest(from: startDate, to: endDate)
        return performFetch(request)
    }
    
    // MARK: - Log Compliance
    
    /// Log a compliance/breach event
    @MainActor @discardableResult
    func logCompliance(
        boundary: BoundaryEntity,
        isKept: Bool,
        notes: String? = nil
    ) -> ComplianceEventEntity {
        var event: ComplianceEventEntity!
        
        context.performAndWait {
            event = ComplianceEventEntity(context: context)
            event.id = UUID()
            event.boundary = boundary
            event.date = Date()
            event.isKept = isKept
            event.notes = notes
            
            // Update boundary streak
            boundary.updateStreak(isKept: isKept)
        }
        
        _ = save()
        
        // Haptic feedback
        if isKept {
            HapticManager.shared.boundaryKept()
        } else {
            HapticManager.shared.boundaryBreached()
        }
        
        return event
    }
    
    // MARK: - Delete
    
    /// Delete event
    func delete(_ event: ComplianceEventEntity) {
        let boundary = event.boundary
        
        context.performAndWait {
            context.delete(event)
        }
        
        _ = save()
        
        // Recalculate streak
        context.performAndWait {
            boundary.recalculateStreak()
        }
        
        _ = save()
    }
    
    // MARK: - Private Methods
    
    private func performFetch(_ request: NSFetchRequest<ComplianceEventEntity>) -> [ComplianceEventEntity] {
        var result: [ComplianceEventEntity] = []
        
        context.performAndWait {
            do {
                result = try context.fetch(request)
            } catch {
                print("Fetch error: \(error.localizedDescription)")
            }
        }
        
        return result
    }
    
    private func save() -> Result<Void, AppError> {
        var result: Result<Void, AppError> = .success(())
        
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    result = .failure(.coreDataSave(error.localizedDescription))
                }
            }
        }
        
        return result
    }
}

// MARK: - Timeline Extension
extension ComplianceRepository {
    /// Get events grouped by day for timeline
    func fetchGroupedByDay(limit: Int = 30) -> [DayEvents] {
        let events = fetchRecent(limit: 100)
        
        // Group by date
        let grouped = Dictionary(grouping: events) { event in
            event.date.startOfDay
        }
        
        // Sort and transform
        return grouped
            .map { DayEvents(date: $0.key, events: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
            .prefix(limit)
            .map { $0 }
    }
}

// MARK: - Day Events
struct DayEvents: Identifiable {
    let id = UUID()
    let date: Date
    let events: [ComplianceEventEntity]
    
    var keptCount: Int {
        events.filter { $0.isKept }.count
    }
    
    var breachedCount: Int {
        events.filter { !$0.isKept }.count
    }
    
    var isAllKept: Bool {
        breachedCount == 0
    }
    
    var dateFormatted: String {
        date.relative
    }
}

// MARK: - Statistics Extension
extension ComplianceRepository {
    /// Event statistics for a period
    func getStatistics(for period: StatisticsPeriod) -> ComplianceStatistics {
        let endDate = Date()
        let startDate: Date
        
        switch period {
        case .week:
            startDate = endDate.adding(days: -7)
        case .month:
            startDate = endDate.adding(months: -1)
        case .quarter:
            startDate = endDate.adding(months: -3)
        case .year:
            startDate = endDate.adding(months: -12)
        case .allTime:
            startDate = Date.distantPast
        }
        
        let events = fetchForPeriod(from: startDate, to: endDate)
        let keptCount = events.filter { $0.isKept }.count
        let breachedCount = events.count - keptCount
        
        return ComplianceStatistics(
            period: period,
            totalEvents: events.count,
            keptCount: keptCount,
            breachedCount: breachedCount
        )
    }
}

// MARK: - Statistics Period
enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    case allTime = "All Time"
    
    var id: String { rawValue }
}

// MARK: - Compliance Statistics
struct ComplianceStatistics {
    let period: StatisticsPeriod
    let totalEvents: Int
    let keptCount: Int
    let breachedCount: Int
    
    var complianceRate: Double {
        guard totalEvents > 0 else { return 100 }
        return Double(keptCount) / Double(totalEvents) * 100
    }
}
