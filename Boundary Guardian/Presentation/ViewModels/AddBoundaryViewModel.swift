// MARK: - AddBoundaryViewModel.swift
// Boundary Guardian
// ViewModel for creating/editing boundaries

import SwiftUI
import CoreData

// MARK: - Add Boundary View Model
/// Manages boundary creation and editing
@MainActor
@Observable
final class AddBoundaryViewModel {
    
    // MARK: - Properties
    var title: String = ""
    var consequenceText: String = ""
    var importance: Int16 = 3
    var selectedCategory: CategoryEntity?
    var isValid: Bool = false
    var isSaving: Bool = false
    
    // MARK: - Edit Mode
    var isEditMode: Bool = false
    var boundaryToEdit: BoundaryEntity?
    
    // MARK: - Categories
    var categories: [CategoryEntity] = []
    
    // MARK: - Error Handling
    var errorState = ErrorState()
    
    // MARK: - Repositories
    private let boundaryRepository: BoundaryRepository
    private let categoryRepository: CategoryRepository
    
    // MARK: - Initialization
    init(
        boundaryRepository: BoundaryRepository = BoundaryRepository(),
        categoryRepository: CategoryRepository = CategoryRepository(),
        boundaryToEdit: BoundaryEntity? = nil
    ) {
        self.boundaryRepository = boundaryRepository
        self.categoryRepository = categoryRepository
        self.boundaryToEdit = boundaryToEdit
        
        loadCategories()
        
        if let boundary = boundaryToEdit {
            setupForEditing(boundary)
        }
    }
    
    // MARK: - Computed Properties
    
    /// Screen title
    var screenTitle: String {
        isEditMode ? "Edit Boundary" : "New Boundary"
    }
    
    /// Save button text
    var saveButtonText: String {
        isEditMode ? "Save" : "Create Boundary"
    }
    
    /// Example boundaries
    static let exampleBoundaries = [
        "Never lend more than $500",
        "No impulse purchases over $200",
        "Invest at least 20% of income",
        "Cancel unused subscriptions monthly",
        "No consumer credit for goods",
        "Save for retirement every month"
    ]
    
    // MARK: - Validation
    private func validate() {
        isValid = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Load Categories
    func loadCategories() {
        categories = categoryRepository.fetchAll()
        
        // Create defaults if none exist
        if categories.isEmpty {
            categoryRepository.ensureDefaultCategoriesExist()
            categories = categoryRepository.fetchAll()
        }
    }
    
    // MARK: - Setup For Editing
    private func setupForEditing(_ boundary: BoundaryEntity) {
        isEditMode = true
        title = boundary.title
        consequenceText = boundary.consequenceText ?? ""
        importance = boundary.importance
        selectedCategory = boundary.category
        validate()
    }
    
    // MARK: - Update Title
    func updateTitle(_ newTitle: String) {
        title = newTitle
        validate()
    }
    
    // MARK: - Save
    func save() -> BoundaryEntity? {
        guard isValid else { return nil }
        
        isSaving = true
        defer { isSaving = false }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConsequence = consequenceText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isEditMode, let boundary = boundaryToEdit {
            // Update existing boundary
            boundary.title = trimmedTitle
            boundary.consequenceText = trimmedConsequence.isEmpty ? nil : trimmedConsequence
            boundary.importance = importance
            boundary.category = selectedCategory
            
            let result = boundaryRepository.update(boundary) as Result<Void, AppError>
            if case .failure(let error) = result {
                errorState.show(error)
                return nil
            }
            
            HapticManager.shared.trigger(.success)
            return boundary
        } else {
            // Create new boundary
            let boundary = boundaryRepository.create(
                title: trimmedTitle,
                consequence: trimmedConsequence.isEmpty ? nil : trimmedConsequence,
                importance: importance,
                category: selectedCategory
            )
            HapticManager.shared.achievement()
            return boundary
        }
    }
    
    // MARK: - Reset
    func reset() {
        title = ""
        consequenceText = ""
        importance = 3
        selectedCategory = nil
        isValid = false
        isEditMode = false
        boundaryToEdit = nil
    }
    
    // MARK: - Use Example
    func useExample(_ example: String) {
        title = example
        validate()
        HapticManager.shared.trigger(.light)
    }
}

// MARK: - Preview Helper
extension AddBoundaryViewModel {
    @MainActor
    static var preview: AddBoundaryViewModel {
        let vm = AddBoundaryViewModel(
            boundaryRepository: BoundaryRepository(
                context: PersistenceController.preview.container.viewContext
            ),
            categoryRepository: CategoryRepository(
                context: PersistenceController.preview.container.viewContext
            )
        )
        return vm
    }
}
