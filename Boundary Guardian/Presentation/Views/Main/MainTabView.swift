// MARK: - MainTabView.swift
// Boundary Guardian
// Main tab-based navigation

import SwiftUI
import CoreData

// MARK: - Main Tab View
struct MainTabView: View {
    @Bindable var appViewModel: AppViewModel
    @State private var selectedTab: TabItem = .dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tag(TabItem.dashboard)
                .tabItem {
                    Label(TabItem.dashboard.title, systemImage: TabItem.dashboard.icon)
                }
            
            TimelineView()
                .tag(TabItem.timeline)
                .tabItem {
                    Label(TabItem.timeline.title, systemImage: TabItem.timeline.icon)
                }
            
            InsightsView()
                .tag(TabItem.insights)
                .tabItem {
                    Label(TabItem.insights.title, systemImage: TabItem.insights.icon)
                }
            
            SettingsView()
                .tag(TabItem.settings)
                .tabItem {
                    Label(TabItem.settings.title, systemImage: TabItem.settings.icon)
                }
        }
        .tint(AppColors.primaryBlue)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(AppColors.deepNavy.opacity(0.95))
        
        // Blur effect
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.mutedGray)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.mutedGray),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.primaryBlue)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.primaryBlue),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Preview
#Preview("Main Tab View") {
    MainTabView(appViewModel: .preview)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
