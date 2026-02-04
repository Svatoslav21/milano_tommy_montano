// MARK: - InsightsViewModel.swift
// Boundary Guardian
// ViewModel for the analytics screen

import SwiftUI
import CoreData

// MARK: - Boundary Ranking Data
/// Safe snapshot for ranking display
struct BoundaryRankingData: Identifiable {
    let id: UUID
    let title: String
    let complianceRate: Double
    let status: BoundaryStatus
    
    init(from entity: BoundaryEntity) {
        self.id = entity.id
        self.title = entity.title
        self.complianceRate = entity.complianceRate
        self.status = entity.status
    }
}

// MARK: - Insights View Model
/// Manages data for the analytics and insights screen
@MainActor
@Observable
final class InsightsViewModel {
    
    // MARK: - Properties
    var selectedPeriod: StatisticsPeriod = .month
    var complianceStatistics: ComplianceStatistics?
    var boundaryStatistics: BoundaryStatistics?
    var monthlyData: [MonthlyInsight] = []
    var topPerformers: [BoundaryRankingData] = []
    var needsAttention: [BoundaryRankingData] = []
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
    
    /// Compliance rate
    var complianceRate: Double {
        complianceStatistics?.complianceRate ?? 100
    }
    
    /// Trend (positive if improving)
    var trend: Double {
        // Compare current period with previous
        guard monthlyData.count >= 2 else { return 0 }
        let current = monthlyData[0].complianceRate
        let previous = monthlyData[1].complianceRate
        return current - previous
    }
    
    /// Trend text
    var trendText: String {
        if trend > 0 {
            return "+\(String(format: "%.1f", trend))%"
        } else if trend < 0 {
            return "\(String(format: "%.1f", trend))%"
        } else {
            return "Stable"
        }
    }
    
    /// Trend color
    var trendColor: Color {
        if trend > 0 {
            return AppColors.protectiveEmerald
        } else if trend < 0 {
            return AppColors.breachRed
        } else {
            return AppColors.metallicSilver
        }
    }
    
    // MARK: - Load Data
    func loadData() {
        isLoading = true
        
        // Load statistics
        complianceStatistics = complianceRepository.getStatistics(for: selectedPeriod)
        boundaryStatistics = boundaryRepository.getStatistics()
        
        // Load chart data
        loadMonthlyData()
        
        // Load top performers and problem boundaries
        loadBoundaryRankings()
        
        isLoading = false
    }
    
    // MARK: - Load Chart Data
    private func loadMonthlyData() {
        var data: [MonthlyInsight] = []
        
        switch selectedPeriod {
        case .week:
            // Show by days for last 7 days
            for i in 0..<7 {
                let date = Date().adding(days: -i)
                let startOfDay = date.startOfDay
                let endOfDay = date.endOfDay
                
                let events = complianceRepository.fetchForPeriod(from: startOfDay, to: endOfDay)
                let keptCount = events.filter { $0.isKept }.count
                let rate = events.isEmpty ? 0.0 : Double(keptCount) / Double(events.count) * 100
                
                data.append(MonthlyInsight(
                    month: startOfDay,
                    complianceRate: rate,
                    totalEvents: events.count,
                    keptEvents: keptCount,
                    displayFormat: .day
                ))
            }
            
        case .month:
            // Show by weeks for last 4 weeks
            for i in 0..<4 {
                let endDate = Date().adding(days: -i * 7)
                let startDate = endDate.adding(days: -6)
                
                let events = complianceRepository.fetchForPeriod(from: startDate.startOfDay, to: endDate.endOfDay)
                let keptCount = events.filter { $0.isKept }.count
                let rate = events.isEmpty ? 0.0 : Double(keptCount) / Double(events.count) * 100
                
                data.append(MonthlyInsight(
                    month: startDate,
                    complianceRate: rate,
                    totalEvents: events.count,
                    keptEvents: keptCount,
                    displayFormat: .week
                ))
            }
            
        case .quarter:
            // Show by months for last 3 months
            for i in 0..<3 {
                let endDate = Date().adding(months: -i)
                let startDate = endDate.startOfMonth
                let monthEnd = startDate.adding(months: 1).adding(days: -1)
                
                let events = complianceRepository.fetchForPeriod(from: startDate, to: monthEnd)
                let keptCount = events.filter { $0.isKept }.count
                let rate = events.isEmpty ? 0.0 : Double(keptCount) / Double(events.count) * 100
                
                data.append(MonthlyInsight(
                    month: startDate,
                    complianceRate: rate,
                    totalEvents: events.count,
                    keptEvents: keptCount,
                    displayFormat: .month
                ))
            }
            
        case .year:
            // Show by months for last 12 months
            for i in 0..<12 {
                let endDate = Date().adding(months: -i)
                let startDate = endDate.startOfMonth
                let monthEnd = startDate.adding(months: 1).adding(days: -1)
                
                let events = complianceRepository.fetchForPeriod(from: startDate, to: monthEnd)
                let keptCount = events.filter { $0.isKept }.count
                let rate = events.isEmpty ? 0.0 : Double(keptCount) / Double(events.count) * 100
                
                data.append(MonthlyInsight(
                    month: startDate,
                    complianceRate: rate,
                    totalEvents: events.count,
                    keptEvents: keptCount,
                    displayFormat: .month
                ))
            }
            
        case .allTime:
            // Show by months for last 6 months
            for i in 0..<6 {
                let endDate = Date().adding(months: -i)
                let startDate = endDate.startOfMonth
                let monthEnd = startDate.adding(months: 1).adding(days: -1)
                
                let events = complianceRepository.fetchForPeriod(from: startDate, to: monthEnd)
                let keptCount = events.filter { $0.isKept }.count
                let rate = events.isEmpty ? 0.0 : Double(keptCount) / Double(events.count) * 100
                
                data.append(MonthlyInsight(
                    month: startDate,
                    complianceRate: rate,
                    totalEvents: events.count,
                    keptEvents: keptCount,
                    displayFormat: .month
                ))
            }
        }
        
        monthlyData = data.reversed()
    }
    
    // MARK: - Load Boundary Rankings
    private func loadBoundaryRankings() {
        let boundaries: [BoundaryEntity] = boundaryRepository.fetchActive()
        
        // Top performers (best compliance rate) - convert to snapshots
        let sortedByBest = boundaries.sorted { $0.complianceRate > $1.complianceRate }
        topPerformers = sortedByBest.prefix(3).map { BoundaryRankingData(from: $0) }
        
        // Needs attention (worst compliance rate or many breaches) - convert to snapshots
        let needsAttentionFiltered = boundaries.filter { (boundary: BoundaryEntity) -> Bool in
            boundary.complianceRate < 70 || boundary.status == .breached
        }
        let sortedByWorst = needsAttentionFiltered.sorted { $0.complianceRate < $1.complianceRate }
        needsAttention = sortedByWorst.prefix(3).map { BoundaryRankingData(from: $0) }
    }
    
    // MARK: - Clear Data (for reset)
    func clearData() {
        complianceStatistics = nil
        boundaryStatistics = nil
        monthlyData = []
        topPerformers = []
        needsAttention = []
    }
    
    // MARK: - Set Period
    func setPeriod(_ period: StatisticsPeriod) {
        guard selectedPeriod != period else { return }
        selectedPeriod = period
        loadData()
        HapticManager.shared.trigger(.selection)
    }
    
    // MARK: - Refresh
    func refresh() {
        loadData()
    }
}

// MARK: - Display Format
enum ChartDisplayFormat {
    case day
    case week
    case month
}

// MARK: - Monthly Insight
struct MonthlyInsight: Identifiable {
    let id = UUID()
    let month: Date
    let complianceRate: Double
    let totalEvents: Int
    let keptEvents: Int
    var displayFormat: ChartDisplayFormat = .month
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        
        switch displayFormat {
        case .day:
            formatter.dateFormat = "EEE"  // Mon, Tue, Wed...
            return formatter.string(from: month)
        case .week:
            formatter.dateFormat = "MM/dd"  // 01/02
            return formatter.string(from: month)
        case .month:
            formatter.dateFormat = "MMM"  // Jan, Feb...
            return formatter.string(from: month)
        }
    }
    
    var fullMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month).capitalized
    }
}

// MARK: - Preview Helper
extension InsightsViewModel {
    @MainActor
    static var preview: InsightsViewModel {
        let vm = InsightsViewModel(
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
