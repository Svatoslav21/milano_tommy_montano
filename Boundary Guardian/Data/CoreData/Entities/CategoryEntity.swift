// MARK: - CategoryEntity.swift
// Boundary Guardian
// Core Data entity for category

import CoreData
import SwiftUI

// MARK: - Category Entity
/// Entity representing a category for financial boundaries
/// Categories: Lending, Spending, Investments, etc.
@objc(CategoryEntity)
public class CategoryEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var icon: String
    @NSManaged public var colorHex: String
    @NSManaged public var createdAt: Date
    @NSManaged public var boundaries: NSSet?
    
    // MARK: - Computed Properties
    
    /// Category color from HEX
    var color: Color {
        Color(hex: colorHex)
    }
    
    /// Number of boundaries in category
    var boundariesCount: Int {
        boundaries?.count ?? 0
    }
    
    /// Array of category boundaries
    var boundariesArray: [BoundaryEntity] {
        let set = boundaries as? Set<BoundaryEntity> ?? []
        return set.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Active boundaries
    var activeBoundaries: [BoundaryEntity] {
        boundariesArray.filter { $0.isActive }
    }
}

// MARK: - Fetch Requests
extension CategoryEntity {
    /// Fetch all categories
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }
    
    /// Fetch categories sorted by creation date
    static func sortedFetchRequest() -> NSFetchRequest<CategoryEntity> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.createdAt, ascending: true)]
        return request
    }
}

// MARK: - Default Categories
extension CategoryEntity {
    /// Creates default categories
    @MainActor
    static func createDefaultCategories(in context: NSManagedObjectContext) {
        let defaults: [(name: String, icon: String, color: String)] = [
            ("Lending", "banknote", "D4AF37"),          // Warm Gold
            ("Spending", "cart.fill", "50C878"),        // Protective Emerald
            ("Investments", "chart.line.uptrend.xyaxis", "C0C0C0"), // Metallic Silver
            ("Subscriptions", "repeat.circle.fill", "FF6B6B"),
            ("Savings", "building.columns.fill", "4ECDC4"),
            ("Debt", "creditcard.fill", "DC3545")
        ]
        
        for (name, icon, color) in defaults {
            let category = CategoryEntity(context: context)
            category.id = UUID()
            category.name = name
            category.icon = icon
            category.colorHex = color
            category.createdAt = Date()
        }
        
        do {
            try context.save()
        } catch {
            print("Error creating default categories: \(error)")
        }
    }
}

// MARK: - Preview Helper
extension CategoryEntity {
    /// Mock category for Preview
    @MainActor
    static var preview: CategoryEntity {
        let context = PersistenceController.preview.container.viewContext
        let category = CategoryEntity(context: context)
        category.id = UUID()
        category.name = "Lending"
        category.icon = "banknote"
        category.colorHex = "D4AF37"
        category.createdAt = Date()
        return category
    }
}
