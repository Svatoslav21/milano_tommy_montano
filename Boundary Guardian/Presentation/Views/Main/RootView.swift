// MARK: - RootView.swift
// Boundary Guardian
// Root view of the application

import SwiftUI
import CoreData

// MARK: - Root View
struct RootView: View {
    @State private var appViewModel = AppViewModel()
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            if showSplash {
                SplashScreen {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            } else {
                MainTabView(appViewModel: appViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .errorAlert(appViewModel.errorState)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
#Preview("Root View") {
    RootView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
