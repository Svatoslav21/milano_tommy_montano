// MARK: - VictoryViewModel.swift
// Boundary Guardian
// ViewModel for the achievements gallery

import SwiftUI
import CoreData

// MARK: - Victory View Model
/// Manages the achievements gallery
@MainActor
@Observable
final class VictoryViewModel {
    
    // MARK: - Properties
    var achievements: [Achievement] = []
    var longestStreaks: [BoundaryEntity] = []
    var isLoading: Bool = false
    
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
    
    /// Unlocked achievements
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    /// Locked achievements
    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    /// Unlock percentage
    var unlockPercentage: Int {
        guard !achievements.isEmpty else { return 0 }
        return Int(Double(unlockedAchievements.count) / Double(achievements.count) * 100)
    }
    
    // MARK: - Load Data
    func loadData() {
        isLoading = true
        
        let boundaries: [BoundaryEntity] = boundaryRepository.fetchAll()
        let statistics = boundaryRepository.getStatistics()
        
        // Load boundaries with best streaks
        let sortedByStreak = boundaries.sorted { $0.longestStreak > $1.longestStreak }
        longestStreaks = Array(sortedByStreak.prefix(5))
        
        // Generate achievements
        achievements = generateAchievements(boundaries: boundaries, statistics: statistics)
        
        isLoading = false
    }
    
    // MARK: - Generate Achievements
    private func generateAchievements(boundaries: [BoundaryEntity], statistics: BoundaryStatistics) -> [Achievement] {
        var result: [Achievement] = []
        
        // Streak achievements
        let maxStreak = boundaries.map { Int($0.longestStreak) }.max() ?? 0
        result.append(Achievement(
            id: "streak_7",
            title: "Week of Power",
            description: "7 consecutive days without violations",
            icon: "flame.fill",
            color: AppColors.warmGold,
            requirement: 7,
            currentValue: maxStreak,
            type: .streak
        ))
        
        result.append(Achievement(
            id: "streak_30",
            title: "Month of Control",
            description: "30 consecutive days without violations",
            icon: "flame.circle.fill",
            color: AppColors.protectiveEmerald,
            requirement: 30,
            currentValue: maxStreak,
            type: .streak
        ))
        
        result.append(Achievement(
            id: "streak_100",
            title: "Boundary Master",
            description: "100 consecutive days without violations",
            icon: "crown.fill",
            color: AppColors.warmGold,
            requirement: 100,
            currentValue: maxStreak,
            type: .streak
        ))
        
        // Boundaries achievements
        let boundaryCount = boundaries.filter { $0.isActive }.count
        result.append(Achievement(
            id: "boundaries_5",
            title: "Boundary Builder",
            description: "Create 5 active boundaries",
            icon: "shield.fill",
            color: AppColors.metallicSilver,
            requirement: 5,
            currentValue: boundaryCount,
            type: .boundaries
        ))
        
        result.append(Achievement(
            id: "boundaries_10",
            title: "Protection Architect",
            description: "Create 10 active boundaries",
            icon: "shield.checkered",
            color: AppColors.warmGold,
            requirement: 10,
            currentValue: boundaryCount,
            type: .boundaries
        ))
        
        // Compliance achievements
        let complianceRate = Int(statistics.overallComplianceRate)
        result.append(Achievement(
            id: "compliance_80",
            title: "Reliable Guardian",
            description: "Maintain 80% compliance rate",
            icon: "checkmark.shield.fill",
            color: AppColors.protectiveEmerald,
            requirement: 80,
            currentValue: complianceRate,
            type: .compliance
        ))
        
        result.append(Achievement(
            id: "compliance_95",
            title: "Unbreakable",
            description: "Maintain 95% compliance rate",
            icon: "bolt.shield.fill",
            color: AppColors.warmGold,
            requirement: 95,
            currentValue: complianceRate,
            type: .compliance
        ))
        
        // Events achievements
        let keptCount = statistics.totalKeptEvents
        result.append(Achievement(
            id: "kept_50",
            title: "First Victories",
            description: "Keep boundaries 50 times",
            icon: "star.fill",
            color: AppColors.metallicSilver,
            requirement: 50,
            currentValue: keptCount,
            type: .events
        ))
        
        result.append(Achievement(
            id: "kept_200",
            title: "Self-Control Veteran",
            description: "Keep boundaries 200 times",
            icon: "star.circle.fill",
            color: AppColors.warmGold,
            requirement: 200,
            currentValue: keptCount,
            type: .events
        ))
        
        return result
    }
    
    // MARK: - Refresh
    func refresh() {
        loadData()
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let requirement: Int
    let currentValue: Int
    let type: AchievementType
    
    var isUnlocked: Bool {
        currentValue >= requirement
    }
    
    var progress: Double {
        min(Double(currentValue) / Double(requirement), 1.0)
    }
    
    var progressText: String {
        if isUnlocked {
            return "Completed!"
        }
        return "\(currentValue) / \(requirement)"
    }
}

// MARK: - Achievement Type
enum AchievementType {
    case streak
    case boundaries
    case compliance
    case events
}

// MARK: - Preview Helper
extension VictoryViewModel {
    @MainActor
    static var preview: VictoryViewModel {
        let vm = VictoryViewModel(
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
