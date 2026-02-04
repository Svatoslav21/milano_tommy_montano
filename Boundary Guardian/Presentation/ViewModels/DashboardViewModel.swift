// MARK: - DashboardViewModel.swift
// Boundary Guardian
// ViewModel for the main dashboard screen

import SwiftUI
import CoreData

// MARK: - Boundary Card Data
/// Safe snapshot of boundary data for display in cards
struct BoundaryCardData: Identifiable {
    let id: UUID
    let title: String
    let importance: Int
    let currentStreak: Int
    let isActive: Bool
    let status: BoundaryStatus
    let categoryName: String?
    let categoryIcon: String?
    let categoryColorHex: String?
    
    var categoryColor: Color {
        guard let hex = categoryColorHex else { return AppColors.metallicSilver }
        return Color(hex: hex)
    }
    
    init(from entity: BoundaryEntity) {
        self.id = entity.id
        self.title = entity.title
        self.importance = Int(entity.importance)
        self.currentStreak = Int(entity.currentStreak)
        self.isActive = entity.isActive
        self.status = entity.status
        self.categoryName = entity.category?.name
        self.categoryIcon = entity.category?.icon
        self.categoryColorHex = entity.category?.colorHex
    }
}

// MARK: - Dashboard View Model
/// Manages data for the Dashboard screen
@MainActor
@Observable
final class DashboardViewModel {
    
    // MARK: - Properties
    var boundaryCards: [BoundaryCardData] = []
    var statistics: BoundaryStatistics?
    var isLoading: Bool = false
    var showAddBoundary: Bool = false
    var animateStrength: Bool = false
    
    // MARK: - Error Handling
    var errorState = ErrorState()
    
    // MARK: - Repositories
    private let boundaryRepository: BoundaryRepository
    private let complianceRepository: ComplianceRepository
    
    // MARK: - Initialization
    init(
        boundaryRepository: BoundaryRepository = BoundaryRepository(),
        complianceRepository: ComplianceRepository = ComplianceRepository()
    ) {
        self.boundaryRepository = boundaryRepository
        self.complianceRepository = complianceRepository
    }
    
    // MARK: - Computed Properties
    
    /// Boundary strength (compliance percentage)
    var boundaryStrength: Int {
        statistics?.strengthPercentage ?? 100
    }
    
    /// Active boundaries
    var activeBoundaries: [BoundaryCardData] {
        boundaryCards.filter { $0.isActive }
    }
    
    /// Boundaries requiring attention (pending status)
    var pendingBoundaries: [BoundaryCardData] {
        activeBoundaries.filter { $0.status == .pending }
    }
    
    /// Boundaries kept today
    var keptTodayBoundaries: [BoundaryCardData] {
        activeBoundaries.filter { $0.status == .kept }
    }
    
    /// Boundaries breached today
    var breachedTodayBoundaries: [BoundaryCardData] {
        activeBoundaries.filter { $0.status == .breached }
    }
    
    /// Greeting based on time of day
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    /// Motivational message
    var motivationalMessage: String {
        if boundaryStrength >= 90 {
            return "Excellent control! You're a master of your finances."
        } else if boundaryStrength >= 70 {
            return "Great work! Keep up the momentum."
        } else if boundaryStrength >= 50 {
            return "You're on the right track. Every day is a new chance."
        } else {
            return "Don't give up. Boundaries protect your future."
        }
    }
    
    // MARK: - Load Data
    func loadData() {
        isLoading = true
        
        // Fetch entities and convert to snapshots immediately
        let entities: [BoundaryEntity] = boundaryRepository.fetchAll()
        boundaryCards = entities.map { BoundaryCardData(from: $0) }
        statistics = boundaryRepository.getStatistics()
        
        isLoading = false
        
        // Animate strength indicator
        withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
            animateStrength = true
        }
    }
    
    // MARK: - Refresh
    func refresh() {
        animateStrength = false
        loadData()
    }
    
    // MARK: - Clear Data (for reset)
    func clearData() {
        boundaryCards = []
        statistics = nil
        animateStrength = false
    }
}

// MARK: - Preview Helper
extension DashboardViewModel {
    static var preview: DashboardViewModel {
        let vm = DashboardViewModel(
            boundaryRepository: BoundaryRepository(
                context: PersistenceController.preview.container.viewContext
            ),
            complianceRepository: ComplianceRepository(
                context: PersistenceController.preview.container.viewContext
            )
        )
        vm.loadData()
        return vm
    }
}
