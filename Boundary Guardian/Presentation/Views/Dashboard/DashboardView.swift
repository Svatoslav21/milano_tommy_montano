// MARK: - DashboardView.swift
// Boundary Guardian
// Main dashboard screen with dark theme

import SwiftUI
import CoreData

// MARK: - Dashboard View
struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                            // Shield Indicator
                            strengthSection
                            
                            // Quick Stats
                            quickStatsSection
                            
                            // Boundaries List
                            boundariesSection
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.top, AppSpacing.md)
                    }
                    
                    // FAB
                    VStack {
                        Spacer()
                        addButton
                    }
                }
            }
            .navigationTitle("Boundary Guardian")
            .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: BoundaryNavDestination.self) { destination in
                switch destination {
                case .add:
                    AddBoundaryView { _ in
                        navigationPath.removeLast()
                        viewModel.refresh()
                    }
                case .detail(let boundaryId):
                    BoundaryDetailWrapper(
                        boundaryId: boundaryId,
                        navigationPath: $navigationPath,
                        onRefresh: { viewModel.refresh() }
                    )
                }
            }
            .onAppear {
                viewModel.loadData()
            }
            .refreshable {
                viewModel.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: .dataDidReset)) { _ in
                // Clear navigation path and data immediately, then reload
                navigationPath = NavigationPath()
                viewModel.clearData()
                // Reload after a short delay to allow Core Data to finish
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.refresh()
                }
            }
            .errorAlert(viewModel.errorState)
        }
    }
    
    // MARK: - Strength Section
    private var strengthSection: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                // Glow
                Circle()
                    .fill(strengthColor.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                VStack(spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(viewModel.boundaryStrength))")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(strengthColor)
                        
                        Text("%")
                            .font(AppTypography.title2())
                            .foregroundStyle(strengthColor.opacity(0.7))
                    }
                    
                    Text("Boundary Strength")
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.mutedGray)
                }
            }
            .padding(.vertical, AppSpacing.md)
        }
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        HStack(spacing: AppSpacing.md) {
            StatCard(
                title: "Active",
                value: "\(viewModel.activeBoundaries.count)",
                icon: "shield.fill",
                color: AppColors.primaryBlue
            )
            
            StatCard(
                title: "Kept",
                value: "\(viewModel.keptTodayBoundaries.count)",
                icon: "checkmark.shield.fill",
                color: AppColors.protectiveEmerald
            )
            
            StatCard(
                title: "Pending",
                value: "\(viewModel.pendingBoundaries.count)",
                icon: "clock.fill",
                color: AppColors.metallicSilver
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Boundaries Section
    private var boundariesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Your Boundaries")
                    .font(AppTypography.title3())
                    .foregroundStyle(AppColors.softWhite)
                
                Spacer()
                
                if !viewModel.boundaryCards.isEmpty {
                    Text("\(viewModel.boundaryCards.count)")
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.mutedGray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal)
            
            if viewModel.boundaryCards.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.activeBoundaries) { boundary in
                        BoundaryCardView(cardData: boundary)
                            .onTapGesture {
                                navigationPath.append(BoundaryNavDestination.detail(boundary.id))
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "shield.slash")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.mutedGray)
            
            Text("No Boundaries Yet")
                .font(AppTypography.title3())
                .foregroundStyle(AppColors.softWhite)
            
            Text("Create your first financial boundary")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            Button {
                navigationPath.append(BoundaryNavDestination.add)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Boundary")
                }
                .font(AppTypography.bodyBold())
                .foregroundStyle(AppColors.deepNavy)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(AppColors.primaryBlue)
                )
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColors.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    // MARK: - Add Button
    private var addButton: some View {
        Button {
            navigationPath.append(BoundaryNavDestination.add)
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(AppColors.deepNavy)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(AppColors.primaryBlue)
                        .shadow(color: AppColors.primaryBlue.opacity(0.4), radius: 15, y: 5)
                )
        }
        .padding(.bottom, AppSpacing.lg)
    }
    
    private var strengthColor: Color {
        if viewModel.boundaryStrength >= 80 {
            return AppColors.protectiveEmerald
        } else if viewModel.boundaryStrength >= 50 {
            return AppColors.primaryBlue
        } else {
            return AppColors.breachRed
        }
    }
}

// MARK: - Navigation Destination
enum BoundaryNavDestination: Hashable {
    case add
    case detail(UUID) // Use ID instead of entity to avoid crash when entity is deleted
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.softWhite)
            
            Text(title)
                .font(AppTypography.caption2())
                .foregroundStyle(AppColors.mutedGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(AppColors.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Boundary Card View
struct BoundaryCardView: View {
    let cardData: BoundaryCardData
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                // Status
                Image(systemName: cardData.status.icon)
                    .foregroundStyle(cardData.status.color)
                
                Spacer()
                
                // Importance
                HStack(spacing: 2) {
                    ForEach(0..<cardData.importance, id: \.self) { _ in
                        Image(systemName: "shield.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(AppColors.primaryBlue)
                    }
                }
                
                // Streak
                if cardData.currentStreak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(AppColors.accentOrange)
                        Text("\(cardData.currentStreak)")
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                }
            }
            
            Text(cardData.title)
                .font(AppTypography.boundaryTitle())
                .foregroundStyle(AppColors.softWhite)
                .lineLimit(2)
            
            if let categoryName = cardData.categoryName,
               let categoryIcon = cardData.categoryIcon {
                HStack(spacing: 4) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 10))
                    Text(categoryName)
                }
                .font(AppTypography.caption())
                .foregroundStyle(cardData.categoryColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColors.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Boundary Detail Wrapper
/// Wrapper that loads boundary by ID and handles deletion gracefully
struct BoundaryDetailWrapper: View {
    let boundaryId: UUID
    @Binding var navigationPath: NavigationPath
    let onRefresh: () -> Void
    
    @State private var boundary: BoundaryEntity?
    @State private var isLoading = true
    
    private let boundaryRepository = BoundaryRepository()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(AppColors.primaryBlue)
            } else if let boundary = boundary, !boundary.isDeleted {
                BoundaryDetailView(boundary: boundary) {
                    // Pop back after deletion
                    if !navigationPath.isEmpty {
                        navigationPath.removeLast()
                    }
                    onRefresh()
                }
            } else {
                // Boundary was deleted or not found
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "shield.slash")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.mutedGray)
                    Text("Boundary not found")
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.mutedGray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.backgroundGradient.ignoresSafeArea())
                .onAppear {
                    // Auto-pop if boundary doesn't exist
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if !navigationPath.isEmpty {
                            navigationPath.removeLast()
                        }
                        onRefresh()
                    }
                }
            }
        }
        .onAppear {
            loadBoundary()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataDidReset)) { _ in
            // Data was reset, boundary no longer exists
            boundary = nil
            isLoading = false
        }
    }
    
    private func loadBoundary() {
        isLoading = true
        boundary = boundaryRepository.fetch(by: boundaryId)
        isLoading = false
    }
}

// MARK: - Preview
#Preview("Dashboard") {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
