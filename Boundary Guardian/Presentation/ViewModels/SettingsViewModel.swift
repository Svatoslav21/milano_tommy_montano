// MARK: - SettingsViewModel.swift
// Boundary Guardian
// ViewModel for the settings screen

import SwiftUI
import CoreData

// MARK: - Settings View Model
/// Manages application settings
@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Properties
    var showResetConfirmation: Bool = false
    var showExportSheet: Bool = false
    var showBackupSheet: Bool = false
    var exportedPDFData: Data?
    var backupData: Data?
    var isExporting: Bool = false
    var isLoading: Bool = false
    
    // MARK: - Error Handling
    var errorState = ErrorState()
    
    // MARK: - Use Cases
    private let exportPDFUseCase = ExportPDFUseCase()
    private let backupUseCase = BackupUseCase()
    
    // MARK: - Repositories
    private let boundaryRepository: BoundaryRepository
    private let categoryRepository: CategoryRepository
    private let complianceRepository: ComplianceRepository
    private let reflectionRepository: ReflectionRepository
    
    // MARK: - Initialization
    init(
        boundaryRepository: BoundaryRepository = BoundaryRepository(),
        categoryRepository: CategoryRepository = CategoryRepository(),
        complianceRepository: ComplianceRepository = ComplianceRepository(),
        reflectionRepository: ReflectionRepository = ReflectionRepository()
    ) {
        self.boundaryRepository = boundaryRepository
        self.categoryRepository = categoryRepository
        self.complianceRepository = complianceRepository
        self.reflectionRepository = reflectionRepository
    }
    
    // MARK: - Statistics
    var totalBoundaries: Int {
        boundaryRepository.fetchAll().count
    }
    
    var totalEvents: Int {
        complianceRepository.fetchAll().count
    }
    
    var totalReflections: Int {
        reflectionRepository.fetchAll().count
    }
    
    // MARK: - App Info
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Export PDF
    func exportPDF() {
        isExporting = true
        
        Task {
            exportedPDFData = exportPDFUseCase.execute()
            isExporting = false
            
            if exportedPDFData != nil {
                showExportSheet = true
                HapticManager.shared.trigger(.success)
            } else {
                errorState.show(.exportError("Failed to generate PDF report"))
                HapticManager.shared.trigger(.error)
            }
        }
    }
    
    // MARK: - Create Backup
    func createBackup() {
        backupData = backupUseCase.createBackup()
        
        if backupData != nil {
            showBackupSheet = true
            HapticManager.shared.trigger(.success)
        } else {
            errorState.show(.exportError("Failed to create backup"))
            HapticManager.shared.trigger(.error)
        }
    }
    
    // MARK: - Reset All Data
    func resetAllData() {
        isLoading = true
        let context = PersistenceController.shared.container.viewContext
        
        // Fetch all data first to avoid mutation during iteration
        let allBoundaries: [BoundaryEntity] = boundaryRepository.fetchAll()
        let allCategories: [CategoryEntity] = categoryRepository.fetchAll()
        let allReflections: [ReflectionEntity] = reflectionRepository.fetchAll()
        
        // Delete all boundaries (cascades to events)
        for boundary in allBoundaries {
            context.delete(boundary)
        }
        
        // Delete all categories
        for category in allCategories {
            context.delete(category)
        }
        
        // Delete all reflections
        for reflection in allReflections {
            context.delete(reflection)
        }
        
        // Save
        do {
            try context.save()
        } catch {
            print("Error resetting data: \(error)")
        }
        
        // Recreate default categories
        categoryRepository.ensureDefaultCategoriesExist()
        
        showResetConfirmation = false
        isLoading = false
        HapticManager.shared.trigger(.heavy)
        
        // Notify all ViewModels about data reset
        AppNotifications.postDataReset()
    }
}

// MARK: - Settings Section
enum SettingsSection: String, CaseIterable, Identifiable {
    case data = "Data"
    case about = "About"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .data: return "externaldrive.fill"
        case .about: return "info.circle.fill"
        }
    }
}

// MARK: - Preview Helper
extension SettingsViewModel {
    @MainActor
    static var preview: SettingsViewModel {
        SettingsViewModel(
            boundaryRepository: BoundaryRepository(
                context: PersistenceController.preview.container.viewContext
            ),
            categoryRepository: CategoryRepository(
                context: PersistenceController.preview.container.viewContext
            ),
            complianceRepository: ComplianceRepository(
                context: PersistenceController.preview.container.viewContext
            ),
            reflectionRepository: ReflectionRepository(
                context: PersistenceController.preview.container.viewContext
            )
        )
    }
}
