// MARK: - BoundaryDetailViewModel.swift
// Boundary Guardian
// ViewModel for boundary detail view

import SwiftUI
import CoreData

// MARK: - Boundary Data Snapshot
/// Safe copy of boundary data that doesn't reference Core Data
struct BoundarySnapshot {
    let id: UUID
    var title: String
    var consequenceText: String?
    var importance: Int16
    var isActive: Bool
    var currentStreak: Int32
    var longestStreak: Int32
    var categoryName: String?
    var categoryIcon: String?
    var categoryColorHex: String?
    var status: BoundaryStatus
    var complianceRate: Double
    var keptCount: Int
    var breachedCount: Int
    
    init(from entity: BoundaryEntity) {
        self.id = entity.id
        self.title = entity.title
        self.consequenceText = entity.consequenceText
        self.importance = entity.importance
        self.isActive = entity.isActive
        self.currentStreak = entity.currentStreak
        self.longestStreak = entity.longestStreak
        self.categoryName = entity.category?.name
        self.categoryIcon = entity.category?.icon
        self.categoryColorHex = entity.category?.colorHex
        self.status = entity.status
        self.complianceRate = entity.complianceRate
        self.keptCount = entity.keptEvents.count
        self.breachedCount = entity.breachedEvents.count
    }
    
    var categoryColor: Color {
        guard let hex = categoryColorHex else { return AppColors.metallicSilver }
        return Color(hex: hex)
    }
}

// MARK: - Event Snapshot
struct EventSnapshot: Identifiable {
    let id: UUID
    let date: Date
    let isKept: Bool
    let notes: String?
    
    var icon: String {
        isKept ? "checkmark.circle.fill" : "xmark.circle.fill"
    }
    
    var color: Color {
        isKept ? AppColors.protectiveEmerald : AppColors.breachRed
    }
    
    var statusText: String {
        isKept ? "Kept" : "Breached"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    init(from entity: ComplianceEventEntity) {
        self.id = entity.id
        self.date = entity.date
        self.isKept = entity.isKept
        self.notes = entity.notes
    }
}

// MARK: - Boundary Detail View Model
/// Manages data for the boundary detail screen
@MainActor
@Observable
final class BoundaryDetailViewModel {
    
    // MARK: - Properties
    private let boundaryId: UUID
    private var boundaryEntity: BoundaryEntity?
    
    var snapshot: BoundarySnapshot?
    var events: [EventSnapshot] = []
    var isEditing: Bool = false
    var showDeleteConfirmation: Bool = false
    var streakAnimating: Bool = false
    var isLoading: Bool = false
    var isDeleted: Bool = false
    
    // MARK: - Edit Properties
    var editTitle: String = ""
    var editConsequence: String = ""
    var editImportance: Int16 = 3
    var editCategory: CategoryEntity?
    
    // MARK: - Error Handling
    var errorState = ErrorState()
    
    // MARK: - Repositories
    private let boundaryRepository: BoundaryRepository
    private let complianceRepository: ComplianceRepository
    private let categoryRepository: CategoryRepository
    
    // MARK: - Initialization
    init(
        boundary: BoundaryEntity,
        boundaryRepository: BoundaryRepository = BoundaryRepository(),
        complianceRepository: ComplianceRepository = ComplianceRepository(),
        categoryRepository: CategoryRepository = CategoryRepository()
    ) {
        self.boundaryId = boundary.id
        self.boundaryEntity = boundary
        self.boundaryRepository = boundaryRepository
        self.complianceRepository = complianceRepository
        self.categoryRepository = categoryRepository
        
        // Create snapshot immediately
        self.snapshot = BoundarySnapshot(from: boundary)
        
        loadEvents()
        setupEditFields()
    }
    
    // MARK: - Computed Properties
    
    var isBoundaryValid: Bool {
        !isDeleted && snapshot != nil
    }
    
    var complianceRate: Double {
        snapshot?.complianceRate ?? 0
    }
    
    var currentStreak: Int {
        Int(snapshot?.currentStreak ?? 0)
    }
    
    var longestStreak: Int {
        Int(snapshot?.longestStreak ?? 0)
    }
    
    var keptCount: Int {
        snapshot?.keptCount ?? 0
    }
    
    var breachedCount: Int {
        snapshot?.breachedCount ?? 0
    }
    
    var safeTitle: String {
        snapshot?.title ?? ""
    }
    
    var safeConsequence: String? {
        snapshot?.consequenceText
    }
    
    var safeImportance: Int {
        Int(snapshot?.importance ?? 0)
    }
    
    var safeStatus: BoundaryStatus {
        snapshot?.status ?? .inactive
    }
    
    var safeIsActive: Bool {
        snapshot?.isActive ?? false
    }
    
    var safeCategoryName: String? {
        snapshot?.categoryName
    }
    
    var safeCategoryIcon: String? {
        snapshot?.categoryIcon
    }
    
    var safeCategoryColor: Color {
        snapshot?.categoryColor ?? AppColors.metallicSilver
    }
    
    var categories: [CategoryEntity] {
        categoryRepository.fetchAll()
    }
    
    var recentEvents: [EventSnapshot] {
        Array(events.prefix(7))
    }
    
    // MARK: - Load Events
    func loadEvents() {
        guard !isDeleted, let entity = boundaryEntity, !entity.isDeleted else {
            events = []
            return
        }
        
        isLoading = true
        let fetchedEvents = complianceRepository.fetchForBoundary(entity)
        events = fetchedEvents.map { EventSnapshot(from: $0) }
        isLoading = false
        
        // Refresh snapshot
        snapshot = BoundarySnapshot(from: entity)
        
        // Animate streak
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5)) {
            streakAnimating = true
        }
    }
    
    // MARK: - Setup Edit Fields
    private func setupEditFields() {
        guard let snap = snapshot else { return }
        editTitle = snap.title
        editConsequence = snap.consequenceText ?? ""
        editImportance = snap.importance
        editCategory = boundaryEntity?.category
    }
    
    // MARK: - Start Editing
    func startEditing() {
        setupEditFields()
        isEditing = true
        HapticManager.shared.trigger(.light)
    }
    
    // MARK: - Save Changes
    func saveChanges() {
        guard !isDeleted, let entity = boundaryEntity, !entity.isDeleted else { return }
        
        entity.title = editTitle
        entity.consequenceText = editConsequence.isEmpty ? nil : editConsequence
        entity.importance = editImportance
        entity.category = editCategory
        
        let result = boundaryRepository.update(entity) as Result<Void, AppError>
        if case .failure(let error) = result {
            errorState.show(error)
        }
        
        // Update snapshot
        snapshot = BoundarySnapshot(from: entity)
        
        isEditing = false
        HapticManager.shared.trigger(.success)
    }
    
    // MARK: - Cancel Editing
    func cancelEditing() {
        setupEditFields()
        isEditing = false
    }
    
    // MARK: - Toggle Active
    func toggleActive() {
        guard !isDeleted, let entity = boundaryEntity, !entity.isDeleted else { return }
        
        let result = boundaryRepository.toggleActive(entity) as Result<Void, AppError>
        if case .failure(let error) = result {
            errorState.show(error)
        }
        
        // Update snapshot
        snapshot = BoundarySnapshot(from: entity)
        
        HapticManager.shared.trigger(.medium)
    }
    
    // MARK: - Delete Boundary
    func deleteBoundary() {
        // Mark as deleted FIRST before any Core Data operations
        isDeleted = true
        snapshot = nil
        events = []
        
        // Now safely delete from Core Data
        if let entity = boundaryEntity {
            boundaryEntity = nil // Clear reference
            _ = boundaryRepository.delete(entity) as Result<Void, AppError>
        }
        
        HapticManager.shared.trigger(.heavy)
    }
    
    // MARK: - Log Compliance
    func logCompliance(isKept: Bool, notes: String? = nil) {
        guard !isDeleted, let entity = boundaryEntity, !entity.isDeleted else { return }
        
        complianceRepository.logCompliance(
            boundary: entity,
            isKept: isKept,
            notes: notes
        )
        loadEvents()
        
        // Reset streak animation
        streakAnimating = false
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            streakAnimating = true
        }
    }
}

// MARK: - Preview Helper
extension BoundaryDetailViewModel {
    @MainActor
    static var preview: BoundaryDetailViewModel {
        let context = PersistenceController.preview.container.viewContext
        
        // Create test boundary
        let boundary = BoundaryEntity(context: context)
        boundary.id = UUID()
        boundary.title = "Never lend more than $500"
        boundary.consequenceText = "Protection from financial losses through personal loans"
        boundary.importance = 4
        boundary.createdAt = Date().adding(days: -30)
        boundary.isActive = true
        boundary.currentStreak = 15
        boundary.longestStreak = 30
        
        // Create test events
        for i in 0..<10 {
            let event = ComplianceEventEntity(context: context)
            event.id = UUID()
            event.boundary = boundary
            event.date = Date().adding(days: -i)
            event.isKept = i < 7 // First 7 days kept
            event.notes = event.isKept ? nil : "Test violation"
        }
        
        return BoundaryDetailViewModel(
            boundary: boundary,
            boundaryRepository: BoundaryRepository(context: context),
            complianceRepository: ComplianceRepository(context: context),
            categoryRepository: CategoryRepository(context: context)
        )
    }
}
