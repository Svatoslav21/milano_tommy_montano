// MARK: - BoundaryRepository.swift
// Boundary Guardian
// Repository for boundary operations

import CoreData
import SwiftUI

// MARK: - Boundary Repository Protocol
protocol BoundaryRepositoryProtocol {
    func fetchAll() -> Result<[BoundaryEntity], AppError>
    func fetchActive() -> Result<[BoundaryEntity], AppError>
    func fetch(by id: UUID) -> Result<BoundaryEntity?, AppError>
    func create(title: String, consequence: String?, importance: Int16, category: CategoryEntity?) -> BoundaryEntity
    func update(_ boundary: BoundaryEntity) -> Result<Void, AppError>
    func delete(_ boundary: BoundaryEntity) -> Result<Void, AppError>
    func toggleActive(_ boundary: BoundaryEntity) -> Result<Void, AppError>
}

// MARK: - Boundary Repository
/// Repository for managing financial boundaries
final class BoundaryRepository: BoundaryRepositoryProtocol {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch all boundaries with error handling
    func fetchAll() -> Result<[BoundaryEntity], AppError> {
        let request = BoundaryEntity.sortedFetchRequest()
        return performFetch(request)
    }
    
    /// Fetch all boundaries (legacy support - returns empty on error)
    func fetchAll() -> [BoundaryEntity] {
        switch fetchAll() as Result<[BoundaryEntity], AppError> {
        case .success(let boundaries):
            return boundaries
        case .failure(let error):
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Fetch active boundaries with error handling
    func fetchActive() -> Result<[BoundaryEntity], AppError> {
        let request = BoundaryEntity.activeFetchRequest()
        return performFetch(request)
    }
    
    /// Fetch active boundaries (legacy support)
    func fetchActive() -> [BoundaryEntity] {
        switch fetchActive() as Result<[BoundaryEntity], AppError> {
        case .success(let boundaries):
            return boundaries
        case .failure:
            return []
        }
    }
    
    /// Fetch boundary by ID with error handling
    func fetch(by id: UUID) -> Result<BoundaryEntity?, AppError> {
        let request = BoundaryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        request.fetchLimit = 1
        
        switch performFetch(request) {
        case .success(let boundaries):
            return .success(boundaries.first)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Fetch boundary by ID (legacy support)
    func fetch(by id: UUID) -> BoundaryEntity? {
        switch fetch(by: id) as Result<BoundaryEntity?, AppError> {
        case .success(let boundary):
            return boundary
        case .failure:
            return nil
        }
    }
    
    // MARK: - Create
    
    /// Create new boundary
    @discardableResult
    func create(
        title: String,
        consequence: String?,
        importance: Int16,
        category: CategoryEntity?
    ) -> BoundaryEntity {
        var boundary: BoundaryEntity!
        
        context.performAndWait {
            boundary = BoundaryEntity(context: context)
            boundary.id = UUID()
            boundary.title = title
            boundary.consequenceText = consequence
            boundary.importance = importance
            boundary.category = category
            boundary.createdAt = Date()
            boundary.isActive = true
            boundary.currentStreak = 0
            boundary.longestStreak = 0
        }
        
        _ = save()
        return boundary
    }
    
    // MARK: - Update
    
    /// Update boundary with error handling
    func update(_ boundary: BoundaryEntity) -> Result<Void, AppError> {
        return save()
    }
    
    /// Update boundary (legacy support)
    func update(_ boundary: BoundaryEntity) {
        _ = save()
    }
    
    // MARK: - Delete
    
    /// Delete boundary with error handling
    func delete(_ boundary: BoundaryEntity) -> Result<Void, AppError> {
        context.performAndWait {
            context.delete(boundary)
        }
        return save()
    }
    
    /// Delete boundary (legacy support)
    func delete(_ boundary: BoundaryEntity) {
        _ = delete(boundary) as Result<Void, AppError>
    }
    
    // MARK: - Toggle Active
    
    /// Toggle boundary active status with error handling
    func toggleActive(_ boundary: BoundaryEntity) -> Result<Void, AppError> {
        context.performAndWait {
            boundary.isActive.toggle()
        }
        return save()
    }
    
    /// Toggle active (legacy support)
    func toggleActive(_ boundary: BoundaryEntity) {
        _ = toggleActive(boundary) as Result<Void, AppError>
    }
    
    // MARK: - Private Methods
    
    private func performFetch(_ request: NSFetchRequest<BoundaryEntity>) -> Result<[BoundaryEntity], AppError> {
        var result: Result<[BoundaryEntity], AppError>!
        
        context.performAndWait {
            do {
                let boundaries = try context.fetch(request)
                result = .success(boundaries)
            } catch {
                result = .failure(.coreDataFetch(error.localizedDescription))
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

// MARK: - Statistics Extension
extension BoundaryRepository {
    /// Overall boundary statistics
    func getStatistics() -> BoundaryStatistics {
        let all = fetchAll() as [BoundaryEntity]
        let active = all.filter { $0.isActive }
        
        let totalEvents = active.flatMap { $0.eventsArray }
        let keptEvents = totalEvents.filter { $0.isKept }
        
        let complianceRate = totalEvents.isEmpty ? 100.0 :
            Double(keptEvents.count) / Double(totalEvents.count) * 100
        
        let totalCurrentStreak = active.reduce(0) { $0 + Int($1.currentStreak) }
        let avgStreak = active.isEmpty ? 0 : totalCurrentStreak / active.count
        
        let longestStreak = active.map { Int($0.longestStreak) }.max() ?? 0
        
        return BoundaryStatistics(
            totalBoundaries: all.count,
            activeBoundaries: active.count,
            overallComplianceRate: complianceRate,
            averageStreak: avgStreak,
            longestStreak: longestStreak,
            totalKeptEvents: keptEvents.count,
            totalBreachedEvents: totalEvents.count - keptEvents.count
        )
    }
}

// MARK: - Boundary Statistics
struct BoundaryStatistics {
    let totalBoundaries: Int
    let activeBoundaries: Int
    let overallComplianceRate: Double
    let averageStreak: Int
    let longestStreak: Int
    let totalKeptEvents: Int
    let totalBreachedEvents: Int
    
    var strengthPercentage: Int {
        Int(overallComplianceRate)
    }
}
