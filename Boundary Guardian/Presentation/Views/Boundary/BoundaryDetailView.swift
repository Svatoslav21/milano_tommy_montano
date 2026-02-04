// MARK: - BoundaryDetailView.swift
// Boundary Guardian
// Boundary detail view (push navigation)

import SwiftUI
import CoreData

// MARK: - Boundary Detail View
struct BoundaryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: BoundaryDetailViewModel
    @State private var showDeleteAlert: Bool = false
    
    let onDismiss: () -> Void
    
    init(boundary: BoundaryEntity, onDismiss: @escaping () -> Void) {
        _viewModel = State(initialValue: BoundaryDetailViewModel(boundary: boundary))
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            if viewModel.isDeleted || !viewModel.isBoundaryValid {
                // Show empty state if boundary was deleted
                deletedStateView
            } else if viewModel.isLoading {
                ProgressView()
                    .tint(AppColors.primaryBlue)
                    .scaleEffect(1.5)
            } else {
                contentView
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if viewModel.isBoundaryValid {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        EditBoundaryView(viewModel: viewModel)
                    } label: {
                        Text("Edit")
                            .foregroundStyle(AppColors.primaryBlue)
                    }
                }
            }
        }
        .alert("Delete Boundary?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                performDelete()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear {
            if !viewModel.isDeleted {
                viewModel.loadEvents()
            }
        }
        .errorAlert(viewModel.errorState)
    }
    
    // MARK: - Deleted State
    private var deletedStateView: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "shield.slash")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.mutedGray)
            Text("Boundary deleted")
                .font(AppTypography.body())
                .foregroundStyle(AppColors.mutedGray)
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.lg) {
                headerCard
                statsSection
                
                if viewModel.safeIsActive {
                    quickActionsSection
                }
                
                if !viewModel.events.isEmpty {
                    eventsSection
                }
                
                dangerZone
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
    
    // MARK: - Perform Delete
    private func performDelete() {
        // Delete first (this sets isDeleted = true immediately)
        viewModel.deleteBoundary()
        // Then dismiss
        onDismiss()
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                // Status
                HStack(spacing: 6) {
                    Image(systemName: viewModel.safeStatus.icon)
                    Text(viewModel.safeStatus.text)
                }
                .font(AppTypography.caption())
                .foregroundStyle(viewModel.safeStatus.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(viewModel.safeStatus.color.opacity(0.15))
                )
                
                Spacer()
                
                // Importance
                HStack(spacing: 2) {
                    ForEach(0..<viewModel.safeImportance, id: \.self) { _ in
                        Image(systemName: "shield.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.primaryBlue)
                    }
                }
            }
            
            Text(viewModel.safeTitle)
                .font(AppTypography.boundaryTitle())
                .foregroundStyle(AppColors.softWhite)
            
            if let consequence = viewModel.safeConsequence, !consequence.isEmpty {
                Text(consequence)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.mutedGray)
            }
            
            if let categoryName = viewModel.safeCategoryName,
               let categoryIcon = viewModel.safeCategoryIcon {
                HStack(spacing: 6) {
                    Image(systemName: categoryIcon)
                    Text(categoryName)
                }
                .font(AppTypography.caption())
                .foregroundStyle(viewModel.safeCategoryColor)
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
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                StatBox(
                    title: "Current Streak",
                    value: "\(viewModel.currentStreak)",
                    unit: "days",
                    color: AppColors.accentOrange,
                    icon: "flame.fill"
                )
                
                StatBox(
                    title: "Best Streak",
                    value: "\(viewModel.longestStreak)",
                    unit: "days",
                    color: AppColors.protectiveEmerald,
                    icon: "trophy.fill"
                )
            }
            
            HStack(spacing: AppSpacing.md) {
                StatBox(
                    title: "Kept",
                    value: "\(viewModel.keptCount)",
                    unit: "times",
                    color: AppColors.protectiveEmerald,
                    icon: "checkmark.circle.fill"
                )
                
                StatBox(
                    title: "Breached",
                    value: "\(viewModel.breachedCount)",
                    unit: "times",
                    color: AppColors.breachRed,
                    icon: "xmark.circle.fill"
                )
            }
            
            // Compliance Rate
            VStack(spacing: AppSpacing.xs) {
                HStack {
                    Text("Compliance Rate")
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.mutedGray)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.complianceRate))%")
                        .font(AppTypography.bodyBold())
                        .foregroundStyle(AppColors.primaryBlue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.primaryBlue)
                            .frame(width: geometry.size.width * viewModel.complianceRate / 100)
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppColors.cardGradient)
            )
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Log Compliance")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            HStack(spacing: AppSpacing.md) {
                Button {
                    viewModel.logCompliance(isKept: true)
                } label: {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                        Text("Kept")
                    }
                    .font(AppTypography.bodyBold())
                    .foregroundStyle(AppColors.deepNavy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .fill(AppColors.protectiveEmerald)
                    )
                }
                
                Button {
                    viewModel.logCompliance(isKept: false)
                } label: {
                    HStack {
                        Image(systemName: "xmark.shield.fill")
                        Text("Breached")
                    }
                    .font(AppTypography.bodyBold())
                    .foregroundStyle(AppColors.softWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .fill(AppColors.breachRed)
                    )
                }
            }
        }
    }
    
    // MARK: - Events Section
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Recent Events")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.events.prefix(10))) { event in
                    HStack {
                        Image(systemName: event.icon)
                            .foregroundStyle(event.color)
                        
                        Text(event.statusText)
                            .font(AppTypography.body())
                            .foregroundStyle(AppColors.softWhite)
                        
                        Spacer()
                        
                        Text(event.formattedDate)
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.mutedGray)
                    }
                    .padding()
                    
                    if event.id != viewModel.events.prefix(10).last?.id {
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
    
    // MARK: - Danger Zone
    private var dangerZone: some View {
        Button(role: .destructive) {
            showDeleteAlert = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Boundary")
            }
            .font(AppTypography.body())
            .foregroundStyle(AppColors.breachRed)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppColors.breachRed.opacity(0.1))
            )
        }
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.softWhite)
            
            Text(unit)
                .font(AppTypography.caption2())
                .foregroundStyle(AppColors.mutedGray)
            
            Text(title)
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(AppColors.cardGradient)
        )
    }
}

// MARK: - Edit Boundary View
struct EditBoundaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: BoundaryDetailViewModel
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            if viewModel.isDeleted {
                Text("Boundary deleted")
                    .foregroundStyle(AppColors.mutedGray)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        // Title
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Boundary Text")
                                .font(AppTypography.caption())
                                .foregroundStyle(AppColors.mutedGray)
                            
                            TextField("Text", text: $viewModel.editTitle, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: AppRadius.md)
                                        .fill(Color.white.opacity(0.05))
                                )
                                .foregroundStyle(AppColors.softWhite)
                        }
                        
                        // Consequence
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Consequences")
                                .font(AppTypography.caption())
                                .foregroundStyle(AppColors.mutedGray)
                            
                            TextField("Consequences of violation", text: $viewModel.editConsequence, axis: .vertical)
                                .lineLimit(2...4)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: AppRadius.md)
                                        .fill(Color.white.opacity(0.05))
                                )
                                .foregroundStyle(AppColors.softWhite)
                        }
                        
                        // Importance
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Importance")
                                .font(AppTypography.caption())
                                .foregroundStyle(AppColors.mutedGray)
                            
                            HStack {
                                ForEach(1...5, id: \.self) { level in
                                    Button {
                                        viewModel.editImportance = Int16(level)
                                    } label: {
                                        Image(systemName: level <= viewModel.editImportance ? "shield.fill" : "shield")
                                            .font(.system(size: 28))
                                            .foregroundStyle(level <= viewModel.editImportance ? AppColors.primaryBlue : AppColors.mutedGray.opacity(0.4))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                        
                        // Save Button
                        Button {
                            viewModel.saveChanges()
                            dismiss()
                        } label: {
                            Text("Save")
                                .font(AppTypography.bodyBold())
                                .foregroundStyle(AppColors.deepNavy)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: AppRadius.lg)
                                        .fill(AppColors.primaryBlue)
                                )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.startEditing()
        }
    }
}

// MARK: - Preview
#Preview("Boundary Detail") {
    NavigationStack {
        BoundaryDetailView(boundary: .preview) {}
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
