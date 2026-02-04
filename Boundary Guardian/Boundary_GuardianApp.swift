
import SwiftUI
import CoreData

@main
struct Boundary_GuardianApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        configureGlobalAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    persistenceController.save()
                }
        }
    }
    
    private func configureGlobalAppearance() {
        // Force dark mode UI components
        
        // Navigation Bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = .clear
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(AppColors.primaryBlue)
        
        // Tab Bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundColor = UIColor(AppColors.deepNavy.opacity(0.95))
        tabAppearance.backgroundEffect = UIBlurEffect(style: .dark)
        
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.mutedGray)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.mutedGray),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.primaryBlue)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.primaryBlue),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
