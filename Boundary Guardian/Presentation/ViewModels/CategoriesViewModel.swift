// MARK: - CategoriesViewModel.swift
// Boundary Guardian
// ViewModel for managing categories

import SwiftUI
import CoreData

// MARK: - Categories View Model
/// Manages boundary categories
@MainActor
@Observable
final class CategoriesViewModel {
    
    // MARK: - Properties
    var categories: [CategoryEntity] = []
    var isLoading: Bool = false
    var showAddCategory: Bool = false
    var categoryToEdit: CategoryEntity?
    
    // MARK: - Add/Edit Properties
    var editName: String = ""
    var editIcon: String = "banknote"
    var editColorHex: String = "D4AF37"
    var isEditing: Bool = false
    
    // MARK: - Error Handling
    var errorState = ErrorState()
    
    // MARK: - Repository
    private let categoryRepository: CategoryRepository
    
    // MARK: - Initialization
    init(categoryRepository: CategoryRepository = CategoryRepository()) {
        self.categoryRepository = categoryRepository
    }
    
    // MARK: - Available Icons
    var availableIcons: [String] {
        CategoryRepository.availableIcons
    }
    
    // MARK: - Available Colors
    var availableColors: [String] {
        CategoryRepository.availableColors
    }
    
    // MARK: - Computed Properties
    
    /// Form validity
    var isFormValid: Bool {
        !editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Modal title
    var sheetTitle: String {
        isEditing ? "Edit Category" : "New Category"
    }
    
    // MARK: - Load Data
    func loadData() {
        isLoading = true
        categories = categoryRepository.fetchAll()
        isLoading = false
    }
    
    // MARK: - Show Add Sheet
    func showAddSheet() {
        resetForm()
        isEditing = false
        showAddCategory = true
        HapticManager.shared.trigger(.light)
    }
    
    // MARK: - Show Edit Sheet
    func showEditSheet(for category: CategoryEntity) {
        categoryToEdit = category
        editName = category.name
        editIcon = category.icon
        editColorHex = category.colorHex
        isEditing = true
        showAddCategory = true
        HapticManager.shared.trigger(.light)
    }
    
    // MARK: - Reset Form
    private func resetForm() {
        editName = ""
        editIcon = "banknote"
        editColorHex = "D4AF37"
        categoryToEdit = nil
    }
    
    // MARK: - Save Category
    func saveCategory() {
        guard isFormValid else { return }
        
        let trimmedName = editName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isEditing, let category = categoryToEdit {
            // Update
            category.name = trimmedName
            category.icon = editIcon
            category.colorHex = editColorHex
            categoryRepository.update(category)
        } else {
            // Create
            categoryRepository.create(
                name: trimmedName,
                icon: editIcon,
                colorHex: editColorHex
            )
        }
        
        showAddCategory = false
        resetForm()
        loadData()
        HapticManager.shared.trigger(.success)
    }
    
    // MARK: - Delete Category
    func deleteCategory(_ category: CategoryEntity) {
        categoryRepository.delete(category)
        loadData()
        HapticManager.shared.trigger(.medium)
    }
    
    // MARK: - Dismiss Sheet
    func dismissSheet() {
        showAddCategory = false
        resetForm()
    }
    
    // MARK: - Add Category
    func addCategory(name: String, icon: String, colorHex: String) {
        categoryRepository.create(name: name, icon: icon, colorHex: colorHex)
        loadData()
        HapticManager.shared.trigger(.success)
    }
    
    // MARK: - Update Category
    func updateCategory(_ category: CategoryEntity) {
        categoryRepository.update(category)
        loadData()
        HapticManager.shared.trigger(.success)
    }
}

// MARK: - Preview Helper
extension CategoriesViewModel {
    @MainActor
    static var preview: CategoriesViewModel {
        let vm = CategoriesViewModel(
            categoryRepository: CategoryRepository(
                context: PersistenceController.preview.container.viewContext
            )
        )
        vm.loadData()
        return vm
    }
}
