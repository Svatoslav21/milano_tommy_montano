// MARK: - CategoryRepository.swift
// Boundary Guardian
// Repository for category operations

import CoreData
import SwiftUI

// MARK: - Category Repository Protocol
protocol CategoryRepositoryProtocol {
    func fetchAll() -> [CategoryEntity]
    func fetch(by id: UUID) -> CategoryEntity?
    func create(name: String, icon: String, colorHex: String) -> CategoryEntity
    func update(_ category: CategoryEntity)
    func delete(_ category: CategoryEntity)
    func ensureDefaultCategoriesExist()
}

// MARK: - Category Repository
/// Repository for managing boundary categories
final class CategoryRepository: CategoryRepositoryProtocol {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch all categories
    func fetchAll() -> [CategoryEntity] {
        let request = CategoryEntity.sortedFetchRequest()
        return performFetch(request)
    }
    
    /// Fetch category by ID
    func fetch(by id: UUID) -> CategoryEntity? {
        let request = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        request.fetchLimit = 1
        
        return performFetch(request).first
    }
    
    // MARK: - Create
    
    /// Create new category
    @discardableResult
    func create(name: String, icon: String, colorHex: String) -> CategoryEntity {
        var category: CategoryEntity!
        
        context.performAndWait {
            category = CategoryEntity(context: context)
            category.id = UUID()
            category.name = name
            category.icon = icon
            category.colorHex = colorHex
            category.createdAt = Date()
        }
        
        _ = save()
        return category
    }
    
    // MARK: - Update
    
    /// Update category
    func update(_ category: CategoryEntity) {
        _ = save()
    }
    
    // MARK: - Delete
    
    /// Delete category
    func delete(_ category: CategoryEntity) {
        context.performAndWait {
            context.delete(category)
        }
        _ = save()
    }
    
    // MARK: - Default Categories
    
    /// Create default categories if none exist
    func ensureDefaultCategoriesExist() {
        let existing = fetchAll()
        guard existing.isEmpty else { return }
        
        let defaults: [(name: String, icon: String, color: String)] = [
            ("Lending", "banknote", "D4AF37"),
            ("Spending", "cart.fill", "50C878"),
            ("Investments", "chart.line.uptrend.xyaxis", "C0C0C0"),
            ("Subscriptions", "repeat.circle.fill", "FF6B6B"),
            ("Savings", "building.columns.fill", "4ECDC4"),
            ("Debt", "creditcard.fill", "DC3545")
        ]
        
        for (name, icon, color) in defaults {
            create(name: name, icon: icon, colorHex: color)
        }
    }
    
    // MARK: - Private Methods
    
    private func performFetch(_ request: NSFetchRequest<CategoryEntity>) -> [CategoryEntity] {
        var result: [CategoryEntity] = []
        
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

// MARK: - Available Icons
extension CategoryRepository {
    /// Available icons for categories
    static let availableIcons = [
        "banknote", "creditcard.fill", "cart.fill", "bag.fill",
        "building.columns.fill", "chart.line.uptrend.xyaxis", "chart.pie.fill",
        "repeat.circle.fill", "calendar", "gift.fill",
        "car.fill", "house.fill", "airplane", "fork.knife",
        "tshirt.fill", "heart.fill", "cross.case.fill", "book.fill",
        "graduationcap.fill", "gamecontroller.fill", "music.note",
        "film.fill", "sportscourt.fill", "figure.walk",
        "pawprint.fill", "leaf.fill", "drop.fill"
    ]
    
    /// Available colors for categories
    static let availableColors = [
        "D4AF37", // Warm Gold
        "50C878", // Protective Emerald
        "C0C0C0", // Metallic Silver
        "DC3545", // Breach Red
        "FF6B6B", // Coral
        "4ECDC4", // Teal
        "45B7D1", // Sky Blue
        "96CEB4", // Sage
        "FFEAA7", // Pale Yellow
        "DDA0DD", // Plum
        "98D8C8", // Mint
        "F7DC6F"  // Soft Yellow
    ]
}
