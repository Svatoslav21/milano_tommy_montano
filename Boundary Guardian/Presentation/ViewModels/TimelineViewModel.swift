// MARK: - TimelineViewModel.swift
// Boundary Guardian
// ViewModel for the timeline screen

import SwiftUI
import CoreData

// MARK: - Timeline View Model
/// Manages data for the timeline screen
@MainActor
@Observable
final class TimelineViewModel {
    
    // MARK: - Properties
    var dayEvents: [DayEvents] = []
    var allEvents: [ComplianceEventEntity] = []
    var isLoading: Bool = false
    var selectedFilter: TimelineFilter = .all
    
    // MARK: - Error Handling
    var errorState = ErrorState()
    
    // MARK: - Repositories
    private let complianceRepository: ComplianceRepository
    
    // MARK: - Initialization
    init(complianceRepository: ComplianceRepository = ComplianceRepository()) {
        self.complianceRepository = complianceRepository
    }
    
    // MARK: - Computed Properties
    
    /// Filtered events
    var filteredEvents: [DayEvents] {
        switch selectedFilter {
        case .all:
            return dayEvents
        case .kept:
            return dayEvents.compactMap { day in
                let filtered = day.events.filter { $0.isKept }
                return filtered.isEmpty ? nil : DayEvents(date: day.date, events: filtered)
            }
        case .breached:
            return dayEvents.compactMap { day in
                let filtered = day.events.filter { !$0.isKept }
                return filtered.isEmpty ? nil : DayEvents(date: day.date, events: filtered)
            }
        }
    }
    
    /// Current month statistics
    var monthStats: (kept: Int, breached: Int) {
        let events = allEvents.filter { $0.date.isThisMonth }
        let kept = events.filter { $0.isKept }.count
        let breached = events.count - kept
        return (kept, breached)
    }
    
    // MARK: - Load Data
    func loadData() {
        isLoading = true
        
        dayEvents = complianceRepository.fetchGroupedByDay(limit: 60)
        allEvents = complianceRepository.fetchAll()
        
        isLoading = false
    }
    
    // MARK: - Refresh
    func refresh() {
        loadData()
    }
    
    // MARK: - Clear Data (for reset)
    func clearData() {
        dayEvents = []
        allEvents = []
    }
    
    // MARK: - Delete Event
    func deleteEvent(_ event: ComplianceEventEntity) {
        complianceRepository.delete(event)
        loadData()
        HapticManager.shared.trigger(.medium)
    }
    
    // MARK: - Set Filter
    func setFilter(_ filter: TimelineFilter) {
        selectedFilter = filter
        HapticManager.shared.trigger(.selection)
    }
}

// MARK: - Timeline Filter
enum TimelineFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case kept = "Kept"
    case breached = "Breached"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .kept: return "checkmark.shield.fill"
        case .breached: return "xmark.shield.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return AppColors.metallicSilver
        case .kept: return AppColors.protectiveEmerald
        case .breached: return AppColors.breachRed
        }
    }
}

// MARK: - Preview Helper
extension TimelineViewModel {
    @MainActor
    static var preview: TimelineViewModel {
        let vm = TimelineViewModel(
            complianceRepository: ComplianceRepository(
                context: PersistenceController.preview.container.viewContext
            )
        )
        vm.loadData()
        return vm
    }
}
