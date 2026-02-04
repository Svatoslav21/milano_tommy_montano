// MARK: - VictoryGalleryView.swift
// Boundary Guardian
// Achievements gallery (push navigation)

import SwiftUI
import CoreData

// MARK: - Victory Gallery View
struct VictoryGalleryView: View {
    @State private var viewModel = VictoryViewModel()
    
    var body: some View {
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
                        // Progress Section
                        progressSection
                        
                        // Longest Streaks
                        if !viewModel.longestStreaks.isEmpty {
                            longestStreaksSection
                        }
                        
                        // Unlocked Achievements
                        if !viewModel.unlockedAchievements.isEmpty {
                            achievementsSection(
                                title: "Unlocked",
                                achievements: viewModel.unlockedAchievements,
                                isUnlocked: true
                            )
                        }
                        
                        // Locked Achievements
                        if !viewModel.lockedAchievements.isEmpty {
                            achievementsSection(
                                title: "In Progress",
                                achievements: viewModel.lockedAchievements,
                                isUnlocked: false
                            )
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.loadData()
        }
        .refreshable {
            viewModel.refresh()
        }
        .errorAlert(viewModel.errorState)
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.unlockedAchievements.count) / \(viewModel.achievements.count)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.softWhite)
                
                Text("achievements unlocked")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.mutedGray)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 6)
                
                Circle()
                    .trim(from: 0, to: Double(viewModel.unlockPercentage) / 100)
                    .stroke(AppColors.primaryBlue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text("\(viewModel.unlockPercentage)%")
                    .font(AppTypography.bodyBold())
                    .foregroundStyle(AppColors.softWhite)
            }
            .frame(width: 70, height: 70)
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
    
    // MARK: - Longest Streaks Section
    private var longestStreaksSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(AppColors.accentOrange)
                Text("Best Streaks")
                    .font(AppTypography.title3())
                    .foregroundStyle(AppColors.softWhite)
            }
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.longestStreaks.enumerated()), id: \.element.id) { index, boundary in
                    HStack {
                        Text("\(index + 1)")
                            .font(AppTypography.bodyBold())
                            .foregroundStyle(index == 0 ? AppColors.accentOrange : AppColors.mutedGray)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(boundary.title)
                                .font(AppTypography.body())
                                .foregroundStyle(AppColors.softWhite)
                                .lineLimit(1)
                            
                            if let category = boundary.category {
                                Text(category.name)
                                    .font(AppTypography.caption())
                                    .foregroundStyle(AppColors.mutedGray)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(AppColors.accentOrange)
                            Text("\(boundary.longestStreak)")
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColors.softWhite)
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    
                    if index < viewModel.longestStreaks.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.1))
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardGradient)
            )
        }
    }
    
    // MARK: - Achievements Section
    private func achievementsSection(title: String, achievements: [Achievement], isUnlocked: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppTypography.title3())
                .foregroundStyle(AppColors.softWhite)
            
            VStack(spacing: 0) {
                ForEach(achievements) { achievement in
                    AchievementRow(achievement: achievement, isUnlocked: isUnlocked)
                    
                    if achievement.id != achievements.last?.id {
                        Divider()
                            .background(Color.white.opacity(0.1))
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardGradient)
            )
        }
    }
}

// MARK: - Achievement Row
struct AchievementRow: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundStyle(isUnlocked ? achievement.color : AppColors.mutedGray)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(AppTypography.bodyBold())
                    .foregroundStyle(isUnlocked ? AppColors.softWhite : AppColors.mutedGray)
                
                Text(achievement.description)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.mutedGray)
                
                if !isUnlocked {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(achievement.color)
                                .frame(width: geometry.size.width * achievement.progress)
                        }
                    }
                    .frame(height: 4)
                    
                    Text(achievement.progressText)
                        .font(AppTypography.caption2())
                        .foregroundStyle(AppColors.mutedGray)
                }
            }
            
            if isUnlocked {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppColors.protectiveEmerald)
            }
        }
        .padding()
    }
}

// MARK: - Achievement Hashable
extension Achievement: Hashable {
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Preview
#Preview("Victory Gallery") {
    NavigationStack {
        VictoryGalleryView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
