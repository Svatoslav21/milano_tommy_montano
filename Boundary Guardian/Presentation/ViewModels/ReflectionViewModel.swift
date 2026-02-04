// MARK: - ReflectionViewModel.swift
// Boundary Guardian
// ViewModel for the reflection screen

import SwiftUI
import CoreData

// MARK: - Reflection View Model
/// Manages reflections - can create multiple
@MainActor
@Observable
final class ReflectionViewModel {
    
    // MARK: - Properties
    var reflections: [ReflectionEntity] = []
    var selectedReflection: ReflectionEntity?
    var isLoading: Bool = false
    var showAddSheet: Bool = false
    var showEditSheet: Bool = false
    
    // MARK: - Edit Properties
    var editStrengths: String = ""
    var editChallenges: String = ""
    var editIntentions: String = ""
    var editMoodRating: Int16 = 3
    var isEditing: Bool = false
    
    // MARK: - Error Handling
    var errorState = ErrorState()
    
    // MARK: - Repository
    private let reflectionRepository: ReflectionRepository
    
    // MARK: - Initialization
    init(reflectionRepository: ReflectionRepository = ReflectionRepository()) {
        self.reflectionRepository = reflectionRepository
    }
    
    // MARK: - Computed Properties
    
    /// Average mood for all reflections
    var averageMood: Double {
        guard !reflections.isEmpty else { return 3.0 }
        let total = reflections.reduce(0) { $0 + Int($1.moodRating) }
        return Double(total) / Double(reflections.count)
    }
    
    /// Form is valid for saving
    var isFormValid: Bool {
        !editStrengths.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !editChallenges.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !editIntentions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Emoji for mood rating
    func moodEmoji(for rating: Int16) -> String {
        switch rating {
        case 1: return "😔"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
    
    // MARK: - Load Data
    func loadData() {
        isLoading = true
        reflections = reflectionRepository.fetchAll()
        isLoading = false
    }
    
    // MARK: - Show Add Sheet
    func showAdd() {
        resetForm()
        isEditing = false
        showAddSheet = true
    }
    
    // MARK: - Show Edit Sheet
    func showEdit(for reflection: ReflectionEntity) {
        selectedReflection = reflection
        editStrengths = reflection.strengths ?? ""
        editChallenges = reflection.challenges ?? ""
        editIntentions = reflection.intentions ?? ""
        editMoodRating = reflection.moodRating
        isEditing = true
        showEditSheet = true
    }
    
    // MARK: - Reset Form
    private func resetForm() {
        editStrengths = ""
        editChallenges = ""
        editIntentions = ""
        editMoodRating = 3
        selectedReflection = nil
    }
    
    // MARK: - Save
    func save() {
        if isEditing, let reflection = selectedReflection {
            // Update
            reflection.strengths = editStrengths.isEmpty ? nil : editStrengths
            reflection.challenges = editChallenges.isEmpty ? nil : editChallenges
            reflection.intentions = editIntentions.isEmpty ? nil : editIntentions
            reflection.moodRating = editMoodRating
            reflectionRepository.update(reflection)
        } else {
            // Create new
            let newReflection = reflectionRepository.create(for: Date().startOfWeek)
            newReflection.strengths = editStrengths.isEmpty ? nil : editStrengths
            newReflection.challenges = editChallenges.isEmpty ? nil : editChallenges
            newReflection.intentions = editIntentions.isEmpty ? nil : editIntentions
            newReflection.moodRating = editMoodRating
            reflectionRepository.update(newReflection)
        }
        
        showAddSheet = false
        showEditSheet = false
        resetForm()
        loadData()
    }
    
    // MARK: - Delete
    func delete(_ reflection: ReflectionEntity) {
        reflectionRepository.delete(reflection)
        loadData()
    }
    
    // MARK: - Dismiss
    func dismiss() {
        showAddSheet = false
        showEditSheet = false
        resetForm()
    }
}

// MARK: - Preview Helper
extension ReflectionViewModel {
    @MainActor
    static var preview: ReflectionViewModel {
        let vm = ReflectionViewModel(
            reflectionRepository: ReflectionRepository(
                context: PersistenceController.preview.container.viewContext
            )
        )
        vm.loadData()
        return vm
    }
}
