// MARK: - ReflectionRepository.swift
// Boundary Guardian
// Repository for reflection operations

import CoreData
import SwiftUI

// MARK: - Reflection Repository Protocol
protocol ReflectionRepositoryProtocol {
    func fetchAll() -> [ReflectionEntity]
    func fetchRecent(limit: Int) -> [ReflectionEntity]
    func fetchCurrentWeek() -> ReflectionEntity?
    func create(for weekStart: Date) -> ReflectionEntity
    func update(_ reflection: ReflectionEntity)
    func delete(_ reflection: ReflectionEntity)
}

// MARK: - Reflection Repository
/// Repository for managing weekly reflections
final class ReflectionRepository: ReflectionRepositoryProtocol {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch all reflections
    func fetchAll() -> [ReflectionEntity] {
        let request = ReflectionEntity.sortedFetchRequest()
        return performFetch(request)
    }
    
    /// Fetch recent N reflections
    func fetchRecent(limit: Int = 12) -> [ReflectionEntity] {
        let request = ReflectionEntity.recentFetchRequest(limit: limit)
        return performFetch(request)
    }
    
    /// Fetch current week's reflection
    func fetchCurrentWeek() -> ReflectionEntity? {
        let request = ReflectionEntity.currentWeekFetchRequest()
        return performFetch(request).first
    }
    
    /// Fetch or create current week's reflection
    func fetchOrCreateCurrentWeek() -> ReflectionEntity {
        if let existing = fetchCurrentWeek() {
            return existing
        }
        return create(for: Date().startOfWeek)
    }
    
    // MARK: - Create
    
    /// Create new reflection
    @discardableResult
    func create(for weekStart: Date) -> ReflectionEntity {
        var reflection: ReflectionEntity!
        
        context.performAndWait {
            reflection = ReflectionEntity(context: context)
            reflection.id = UUID()
            reflection.weekStartDate = weekStart.startOfWeek
            reflection.moodRating = 3
            reflection.createdAt = Date()
        }
        
        _ = save()
        return reflection
    }
    
    // MARK: - Update
    
    /// Update reflection
    func update(_ reflection: ReflectionEntity) {
        _ = save()
    }
    
    // MARK: - Delete
    
    /// Delete reflection
    func delete(_ reflection: ReflectionEntity) {
        context.performAndWait {
            context.delete(reflection)
        }
        _ = save()
    }
    
    // MARK: - Private Methods
    
    private func performFetch(_ request: NSFetchRequest<ReflectionEntity>) -> [ReflectionEntity] {
        var result: [ReflectionEntity] = []
        
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

// MARK: - Statistics Extension
extension ReflectionRepository {
    /// Average mood for period
    func averageMood(for months: Int = 3) -> Double {
        let startDate = Date().adding(months: -months)
        let reflections = fetchAll().filter { $0.weekStartDate >= startDate }
        
        guard !reflections.isEmpty else { return 3.0 }
        
        let total = reflections.reduce(0) { $0 + Int($1.moodRating) }
        return Double(total) / Double(reflections.count)
    }
    
    /// Number of completed reflections for year
    func completedReflectionsCount(for year: Int = Calendar.current.component(.year, from: Date())) -> Int {
        fetchAll()
            .filter { $0.year == year && $0.isCompleted }
            .count
    }
}
