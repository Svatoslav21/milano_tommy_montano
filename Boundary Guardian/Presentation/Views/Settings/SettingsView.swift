// MARK: - SettingsView.swift
// Boundary Guardian
// Settings screen (push navigation)

import SwiftUI
import CoreData

// MARK: - Settings View
struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(AppColors.primaryBlue)
                        .scaleEffect(1.5)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppSpacing.lg) {
                            // Quick Links Section
                            quickLinksSection
                            
                            // Statistics Section
                            statisticsSection
                            
                            // Export Section
                            exportSection
                            
                            // Danger Zone
                            dangerZone
                            
                            // About Section
                            aboutSection
                            
                            Spacer(minLength: 100)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Reset All Data?", isPresented: $viewModel.showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text("All boundaries, events, and reflections will be deleted.")
            }
            .errorAlert(viewModel.errorState)
        }
    }
    
    // MARK: - Quick Links Section
    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Quick Access")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            VStack(spacing: 0) {
                NavigationLink {
                    CategoriesManagerView()
                } label: {
                    SettingsRow(icon: "folder.fill", title: "Categories", color: AppColors.primaryBlue)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                NavigationLink {
                    VictoryGalleryView()
                } label: {
                    SettingsRow(icon: "trophy.fill", title: "Achievements", color: AppColors.accentOrange)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                NavigationLink {
                    ReflectionView()
                } label: {
                    SettingsRow(icon: "brain.head.profile", title: "Reflections", color: AppColors.protectiveEmerald)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardGradient)
            )
        }
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Statistics")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            VStack(spacing: 0) {
                StatRow(title: "Boundaries Created", value: "\(viewModel.totalBoundaries)")
                Divider().background(Color.white.opacity(0.1))
                StatRow(title: "Events Logged", value: "\(viewModel.totalEvents)")
                Divider().background(Color.white.opacity(0.1))
                StatRow(title: "Reflections", value: "\(viewModel.totalReflections)")
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardGradient)
            )
        }
    }
    
    // MARK: - Export Section
    private var exportSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Export")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            VStack(spacing: 0) {
                NavigationLink {
                    ExportView()
                } label: {
                    SettingsRow(icon: "square.and.arrow.up", title: "Export Data", color: AppColors.metallicSilver)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardGradient)
            )
        }
    }
    
    // MARK: - Danger Zone
    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Danger Zone")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            Button {
                viewModel.showResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(AppColors.breachRed)
                        .frame(width: 30)
                    
                    Text("Reset All Data")
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.breachRed)
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(AppColors.breachRed.opacity(0.1))
                )
            }
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("About")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            VStack(spacing: 0) {
                StatRow(title: "Version", value: viewModel.appVersion)
                Divider().background(Color.white.opacity(0.1))
                StatRow(title: "Build", value: viewModel.buildNumber)
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardGradient)
            )
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 30)
            
            Text(title)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.softWhite)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.mutedGray)
        }
        .padding()
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.softWhite)
            
            Spacer()
            
            Text(value)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.mutedGray)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview("Settings") {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
