// MARK: - PersistenceController.swift
// Boundary Guardian
// Core Data persistence controller for data storage

import CoreData
import SwiftUI

// MARK: - Persistence Controller
/// Manages the Core Data stack
/// Provides fully offline data storage
struct PersistenceController {
    
    // MARK: - Shared Instance
    static let shared = PersistenceController()
    
    // MARK: - Error State
    static var initializationError: AppError?
    
    // MARK: - Preview Instance
    /// Used for SwiftUI Preview with mock data
    @MainActor
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create test categories
        let categories = [
            ("Lending", "banknote", "#D4AF37"),
            ("Spending", "cart", "#50C878"),
            ("Investments", "chart.line.uptrend.xyaxis", "#C0C0C0"),
            ("Subscriptions", "repeat", "#DC3545")
        ]
        
        var categoryEntities: [CategoryEntity] = []
        
        for (name, icon, color) in categories {
            let category = CategoryEntity(context: viewContext)
            category.id = UUID()
            category.name = name
            category.icon = icon
            category.colorHex = color
            category.createdAt = Date()
            categoryEntities.append(category)
        }
        
        // Create test boundaries
        let boundariesData: [(String, String, Int16, Int)] = [
            ("Never lend more than $500", "Protection from financial losses through personal loans", 4, 0),
            ("No impulse purchases over $200", "24-hour rule for major purchases", 5, 1),
            ("Invest at least 20% of income", "Building financial cushion", 5, 2),
            ("Cancel unused subscriptions", "Monthly subscription review", 3, 3)
        ]
        
        for (index, (title, consequence, importance, categoryIndex)) in boundariesData.enumerated() {
            let boundary = BoundaryEntity(context: viewContext)
            boundary.id = UUID()
            boundary.title = title
            boundary.consequenceText = consequence
            boundary.importance = importance
            boundary.category = categoryEntities[min(categoryIndex, categoryEntities.count - 1)]
            boundary.createdAt = Date().adding(days: -30 + index * 5)
            boundary.isActive = true
            boundary.currentStreak = Int32.random(in: 0...45)
            boundary.longestStreak = Int32.random(in: 10...60)
            
            // Create test compliance events
            for day in 0..<Int.random(in: 5...20) {
                let event = ComplianceEventEntity(context: viewContext)
                event.id = UUID()
                event.boundary = boundary
                event.date = Date().adding(days: -day)
                event.isKept = Bool.random() ? true : (day > 3)
                event.notes = event.isKept ? nil : "Test violation"
            }
        }
        
        // Create test reflections
        for week in 0..<4 {
            let reflection = ReflectionEntity(context: viewContext)
            reflection.id = UUID()
            reflection.weekStartDate = Date().adding(weeks: -week).startOfWeek
            reflection.strengths = "Good expense control this week"
            reflection.challenges = "Hard to refuse a friend's loan request"
            reflection.intentions = "Continue adhering to boundaries"
            reflection.moodRating = Int16.random(in: 3...5)
            reflection.createdAt = Date().adding(weeks: -week)
        }
        
        do {
            try viewContext.save()
        } catch {
            // Preview errors are acceptable - just log
            print("Preview data creation error: \(error.localizedDescription)")
        }
        
        return controller
    }()
    
    // MARK: - Container
    let container: NSPersistentContainer
    
    // MARK: - Initialization
    init(inMemory: Bool = false) {
        // Create model programmatically
        let model = Self.createManagedObjectModel()
        container = NSPersistentContainer(name: "BoundaryGuardian", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Capture container before closure to avoid escaping self issue
        let persistentContainer = container
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // Graceful error handling instead of fatalError
                Self.initializationError = .coreDataLoad(error.localizedDescription)
                print("Core Data loading error: \(error), \(error.userInfo)")
                
                // Attempt recovery by deleting corrupt store
                if let storeURL = description.url {
                    do {
                        try FileManager.default.removeItem(at: storeURL)
                        // Retry loading
                        persistentContainer.loadPersistentStores { _, retryError in
                            if let retryError = retryError {
                                print("Failed to recover Core Data store: \(retryError)")
                            }
                        }
                    } catch {
                        print("Failed to delete corrupt store: \(error)")
                    }
                }
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Create Managed Object Model
    /// Creates the data model programmatically with indexes for better performance
    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // MARK: Category Entity
        let categoryEntity = NSEntityDescription()
        categoryEntity.name = "CategoryEntity"
        categoryEntity.managedObjectClassName = "CategoryEntity"
        
        let categoryId = NSAttributeDescription()
        categoryId.name = "id"
        categoryId.attributeType = .UUIDAttributeType
        categoryId.isOptional = false
        
        let categoryName = NSAttributeDescription()
        categoryName.name = "name"
        categoryName.attributeType = .stringAttributeType
        categoryName.isOptional = false
        
        let categoryIcon = NSAttributeDescription()
        categoryIcon.name = "icon"
        categoryIcon.attributeType = .stringAttributeType
        categoryIcon.isOptional = false
        
        let categoryColorHex = NSAttributeDescription()
        categoryColorHex.name = "colorHex"
        categoryColorHex.attributeType = .stringAttributeType
        categoryColorHex.isOptional = false
        
        let categoryCreatedAt = NSAttributeDescription()
        categoryCreatedAt.name = "createdAt"
        categoryCreatedAt.attributeType = .dateAttributeType
        categoryCreatedAt.isOptional = false
        
        categoryEntity.properties = [categoryId, categoryName, categoryIcon, categoryColorHex, categoryCreatedAt]
        
        // MARK: Boundary Entity
        let boundaryEntity = NSEntityDescription()
        boundaryEntity.name = "BoundaryEntity"
        boundaryEntity.managedObjectClassName = "BoundaryEntity"
        
        let boundaryId = NSAttributeDescription()
        boundaryId.name = "id"
        boundaryId.attributeType = .UUIDAttributeType
        boundaryId.isOptional = false
        
        let boundaryTitle = NSAttributeDescription()
        boundaryTitle.name = "title"
        boundaryTitle.attributeType = .stringAttributeType
        boundaryTitle.isOptional = false
        
        let boundaryConsequenceText = NSAttributeDescription()
        boundaryConsequenceText.name = "consequenceText"
        boundaryConsequenceText.attributeType = .stringAttributeType
        boundaryConsequenceText.isOptional = true
        
        let boundaryImportance = NSAttributeDescription()
        boundaryImportance.name = "importance"
        boundaryImportance.attributeType = .integer16AttributeType
        boundaryImportance.isOptional = false
        boundaryImportance.defaultValue = 3
        
        let boundaryCreatedAt = NSAttributeDescription()
        boundaryCreatedAt.name = "createdAt"
        boundaryCreatedAt.attributeType = .dateAttributeType
        boundaryCreatedAt.isOptional = false
        
        let boundaryIsActive = NSAttributeDescription()
        boundaryIsActive.name = "isActive"
        boundaryIsActive.attributeType = .booleanAttributeType
        boundaryIsActive.isOptional = false
        boundaryIsActive.defaultValue = true
        
        let boundaryCurrentStreak = NSAttributeDescription()
        boundaryCurrentStreak.name = "currentStreak"
        boundaryCurrentStreak.attributeType = .integer32AttributeType
        boundaryCurrentStreak.isOptional = false
        boundaryCurrentStreak.defaultValue = 0
        
        let boundaryLongestStreak = NSAttributeDescription()
        boundaryLongestStreak.name = "longestStreak"
        boundaryLongestStreak.attributeType = .integer32AttributeType
        boundaryLongestStreak.isOptional = false
        boundaryLongestStreak.defaultValue = 0
        
        boundaryEntity.properties = [
            boundaryId, boundaryTitle, boundaryConsequenceText, boundaryImportance,
            boundaryCreatedAt, boundaryIsActive, boundaryCurrentStreak, boundaryLongestStreak
        ]
        
        // MARK: Boundary Indexes for Performance
        let isActiveIndex = NSFetchIndexDescription(name: "byIsActive", elements: [
            NSFetchIndexElementDescription(property: boundaryIsActive, collationType: .binary)
        ])
        let createdAtIndex = NSFetchIndexDescription(name: "byCreatedAt", elements: [
            NSFetchIndexElementDescription(property: boundaryCreatedAt, collationType: .binary)
        ])
        boundaryEntity.indexes = [isActiveIndex, createdAtIndex]
        
        // MARK: Compliance Event Entity
        let complianceEntity = NSEntityDescription()
        complianceEntity.name = "ComplianceEventEntity"
        complianceEntity.managedObjectClassName = "ComplianceEventEntity"
        
        let complianceId = NSAttributeDescription()
        complianceId.name = "id"
        complianceId.attributeType = .UUIDAttributeType
        complianceId.isOptional = false
        
        let complianceDate = NSAttributeDescription()
        complianceDate.name = "date"
        complianceDate.attributeType = .dateAttributeType
        complianceDate.isOptional = false
        
        let complianceIsKept = NSAttributeDescription()
        complianceIsKept.name = "isKept"
        complianceIsKept.attributeType = .booleanAttributeType
        complianceIsKept.isOptional = false
        
        let complianceNotes = NSAttributeDescription()
        complianceNotes.name = "notes"
        complianceNotes.attributeType = .stringAttributeType
        complianceNotes.isOptional = true
        
        complianceEntity.properties = [complianceId, complianceDate, complianceIsKept, complianceNotes]
        
        // MARK: Compliance Event Indexes for Performance
        let dateIndex = NSFetchIndexDescription(name: "byDate", elements: [
            NSFetchIndexElementDescription(property: complianceDate, collationType: .binary)
        ])
        let isKeptIndex = NSFetchIndexDescription(name: "byIsKept", elements: [
            NSFetchIndexElementDescription(property: complianceIsKept, collationType: .binary)
        ])
        complianceEntity.indexes = [dateIndex, isKeptIndex]
        
        // MARK: Reflection Entity
        let reflectionEntity = NSEntityDescription()
        reflectionEntity.name = "ReflectionEntity"
        reflectionEntity.managedObjectClassName = "ReflectionEntity"
        
        let reflectionId = NSAttributeDescription()
        reflectionId.name = "id"
        reflectionId.attributeType = .UUIDAttributeType
        reflectionId.isOptional = false
        
        let reflectionWeekStartDate = NSAttributeDescription()
        reflectionWeekStartDate.name = "weekStartDate"
        reflectionWeekStartDate.attributeType = .dateAttributeType
        reflectionWeekStartDate.isOptional = false
        
        let reflectionStrengths = NSAttributeDescription()
        reflectionStrengths.name = "strengths"
        reflectionStrengths.attributeType = .stringAttributeType
        reflectionStrengths.isOptional = true
        
        let reflectionChallenges = NSAttributeDescription()
        reflectionChallenges.name = "challenges"
        reflectionChallenges.attributeType = .stringAttributeType
        reflectionChallenges.isOptional = true
        
        let reflectionIntentions = NSAttributeDescription()
        reflectionIntentions.name = "intentions"
        reflectionIntentions.attributeType = .stringAttributeType
        reflectionIntentions.isOptional = true
        
        let reflectionMoodRating = NSAttributeDescription()
        reflectionMoodRating.name = "moodRating"
        reflectionMoodRating.attributeType = .integer16AttributeType
        reflectionMoodRating.isOptional = false
        reflectionMoodRating.defaultValue = 3
        
        let reflectionCreatedAt = NSAttributeDescription()
        reflectionCreatedAt.name = "createdAt"
        reflectionCreatedAt.attributeType = .dateAttributeType
        reflectionCreatedAt.isOptional = false
        
        reflectionEntity.properties = [
            reflectionId, reflectionWeekStartDate, reflectionStrengths,
            reflectionChallenges, reflectionIntentions, reflectionMoodRating, reflectionCreatedAt
        ]
        
        // MARK: Reflection Indexes
        let weekStartDateIndex = NSFetchIndexDescription(name: "byWeekStartDate", elements: [
            NSFetchIndexElementDescription(property: reflectionWeekStartDate, collationType: .binary)
        ])
        reflectionEntity.indexes = [weekStartDateIndex]
        
        // MARK: Relationships
        
        // Category -> Boundaries (one-to-many)
        let categoryBoundariesRelation = NSRelationshipDescription()
        categoryBoundariesRelation.name = "boundaries"
        categoryBoundariesRelation.destinationEntity = boundaryEntity
        categoryBoundariesRelation.isOptional = true
        categoryBoundariesRelation.deleteRule = .nullifyDeleteRule
        
        // Boundary -> Category (many-to-one)
        let boundaryCategoryRelation = NSRelationshipDescription()
        boundaryCategoryRelation.name = "category"
        boundaryCategoryRelation.destinationEntity = categoryEntity
        boundaryCategoryRelation.maxCount = 1
        boundaryCategoryRelation.isOptional = true
        boundaryCategoryRelation.deleteRule = .nullifyDeleteRule
        
        categoryBoundariesRelation.inverseRelationship = boundaryCategoryRelation
        boundaryCategoryRelation.inverseRelationship = categoryBoundariesRelation
        
        // Boundary -> ComplianceEvents (one-to-many)
        let boundaryEventsRelation = NSRelationshipDescription()
        boundaryEventsRelation.name = "complianceEvents"
        boundaryEventsRelation.destinationEntity = complianceEntity
        boundaryEventsRelation.isOptional = true
        boundaryEventsRelation.deleteRule = .cascadeDeleteRule
        
        // ComplianceEvent -> Boundary (many-to-one)
        let eventBoundaryRelation = NSRelationshipDescription()
        eventBoundaryRelation.name = "boundary"
        eventBoundaryRelation.destinationEntity = boundaryEntity
        eventBoundaryRelation.maxCount = 1
        eventBoundaryRelation.isOptional = false
        eventBoundaryRelation.deleteRule = .nullifyDeleteRule
        
        boundaryEventsRelation.inverseRelationship = eventBoundaryRelation
        eventBoundaryRelation.inverseRelationship = boundaryEventsRelation
        
        // Add relationships to entities
        categoryEntity.properties.append(categoryBoundariesRelation)
        boundaryEntity.properties.append(contentsOf: [boundaryCategoryRelation, boundaryEventsRelation])
        complianceEntity.properties.append(eventBoundaryRelation)
        
        model.entities = [categoryEntity, boundaryEntity, complianceEntity, reflectionEntity]
        
        return model
    }
    
    // MARK: - Background Context
    /// Creates a new background context for thread-safe operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Perform Background Task
    /// Performs a task on a background context with proper thread safety
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
    
    // MARK: - Save Context
    /// Saves changes in the context with error handling
    @discardableResult
    func save() -> Result<Void, AppError> {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                return .success(())
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
                return .failure(.coreDataSave(nsError.localizedDescription))
            }
        }
        return .success(())
    }
    
    // MARK: - Save Context with Completion
    /// Saves changes with a completion handler for error handling
    func save(completion: @escaping (Result<Void, AppError>) -> Void) {
        let result = save()
        completion(result)
    }
}

// MARK: - Environment Key
private struct PersistenceControllerKey: EnvironmentKey {
    static let defaultValue = PersistenceController.shared
}

extension EnvironmentValues {
    var persistenceController: PersistenceController {
        get { self[PersistenceControllerKey.self] }
        set { self[PersistenceControllerKey.self] = newValue }
    }
}
