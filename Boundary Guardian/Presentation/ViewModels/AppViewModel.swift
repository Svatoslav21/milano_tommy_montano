// MARK: - AppViewModel.swift
// Boundary Guardian
// Main application ViewModel

import SwiftUI
import CoreData

// MARK: - App State
enum AppState {
    case splash
    case ready
}

// MARK: - App View Model
/// Manages global application state
@MainActor
@Observable
final class AppViewModel {
    
    // MARK: - Properties
    var appState: AppState = .splash
    var selectedTab: TabItem = .dashboard
    var showQuickLogSheet: Bool = false
    var selectedBoundaryForLog: BoundaryEntity?
    
    // MARK: - Error Handling
    var errorState = ErrorState()
    
    // MARK: - Initialization
    init() {
        // Check first launch
        if !UserDefaults.standard.bool(forKey: "hasLaunched") {
            UserDefaults.standard.set(true, forKey: "hasLaunched")
            // Create default categories
            CategoryRepository().ensureDefaultCategoriesExist()
        }
        
        // Check for initialization errors
        if let error = PersistenceController.initializationError {
            errorState.show(error)
        }
    }
    
    // MARK: - Splash Animation Completed
    func splashAnimationCompleted() {
        withAnimation(.easeInOut(duration: 0.5)) {
            appState = .ready
        }
    }
    
    // MARK: - Quick Log
    func showQuickLog(for boundary: BoundaryEntity) {
        selectedBoundaryForLog = boundary
        showQuickLogSheet = true
        HapticManager.shared.trigger(.light)
    }
    
    func dismissQuickLog() {
        showQuickLogSheet = false
        selectedBoundaryForLog = nil
    }
}

// MARK: - Tab Items
enum TabItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case timeline = "Timeline"
    case insights = "Insights"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .dashboard: return "shield.fill"
        case .timeline: return "clock.fill"
        case .insights: return "chart.line.uptrend.xyaxis"
        case .settings: return "gearshape.fill"
        }
    }
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .timeline: return "Timeline"
        case .insights: return "Insights"
        case .settings: return "Settings"
        }
    }
}

// MARK: - Preview Helper
extension AppViewModel {
    static var preview: AppViewModel {
        let vm = AppViewModel()
        vm.appState = .ready
        return vm
    }
}
