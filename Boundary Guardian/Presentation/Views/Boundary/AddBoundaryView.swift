// MARK: - AddBoundaryView.swift
// Boundary Guardian
// Create/edit boundary screen (push navigation)

import SwiftUI
import CoreData

// MARK: - Add Boundary View
struct AddBoundaryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddBoundaryViewModel
    
    let onSave: (BoundaryEntity) -> Void
    
    init(
        boundaryToEdit: BoundaryEntity? = nil,
        onSave: @escaping (BoundaryEntity) -> Void
    ) {
        _viewModel = State(initialValue: AddBoundaryViewModel(boundaryToEdit: boundaryToEdit))
        self.onSave = onSave
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // Title Field
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Boundary Text")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.mutedGray)
                        
                        TextField("Enter boundary text", text: Binding(
                            get: { viewModel.title },
                            set: { viewModel.updateTitle($0) }
                        ), axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .fill(Color.white.opacity(0.05))
                        )
                        .foregroundStyle(AppColors.softWhite)
                    }
                    
                    // Examples
                    if !viewModel.isEditMode && viewModel.title.isEmpty {
                        examplesSection
                    }
                    
                    // Consequence Field
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Consequences of Violation (optional)")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.mutedGray)
                        
                        TextField("What happens if violated", text: $viewModel.consequenceText, axis: .vertical)
                            .lineLimit(2...4)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .foregroundStyle(AppColors.softWhite)
                    }
                    
                    // Importance Picker
                    importanceSection
                    
                    // Category Picker
                    categorySection
                    
                    // Save Button
                    saveButton
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
        }
        .navigationTitle(viewModel.screenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.loadCategories()
        }
        .errorAlert(viewModel.errorState)
    }
    
    // MARK: - Examples Section
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Example Boundaries")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            FlowLayout(spacing: AppSpacing.xs) {
                ForEach(AddBoundaryViewModel.exampleBoundaries, id: \.self) { example in
                    Button {
                        viewModel.useExample(example)
                    } label: {
                        Text(example)
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.softWhite)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.sm)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColors.cardGradient)
        )
    }
    
    // MARK: - Importance Section
    private var importanceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Importance Level")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            HStack {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        viewModel.importance = Int16(level)
                    } label: {
                        Image(systemName: level <= viewModel.importance ? "shield.fill" : "shield")
                            .font(.system(size: 28))
                            .foregroundStyle(level <= viewModel.importance ? AppColors.primaryBlue : AppColors.mutedGray.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Text(importanceText)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.mutedGray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Category")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.xs) {
                    // No category
                    Button {
                        viewModel.selectedCategory = nil
                    } label: {
                        Text("No Category")
                            .font(AppTypography.caption())
                            .foregroundStyle(viewModel.selectedCategory == nil ? AppColors.deepNavy : AppColors.softWhite)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedCategory == nil ? AppColors.primaryBlue : Color.white.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                    
                    ForEach(viewModel.categories) { category in
                        Button {
                            viewModel.selectedCategory = category
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 12))
                                Text(category.name)
                            }
                            .font(AppTypography.caption())
                            .foregroundStyle(viewModel.selectedCategory?.id == category.id ? AppColors.deepNavy : category.color)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedCategory?.id == category.id ? category.color : category.color.opacity(0.15))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            if let boundary = viewModel.save() {
                onSave(boundary)
                dismiss()
            }
        } label: {
            HStack {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(AppColors.deepNavy)
                } else {
                    Image(systemName: "shield.checkered")
                    Text(viewModel.saveButtonText)
                }
            }
            .font(AppTypography.bodyBold())
            .foregroundStyle(viewModel.isValid ? AppColors.deepNavy : AppColors.mutedGray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(viewModel.isValid ? AppColors.primaryBlue : Color.white.opacity(0.1))
            )
        }
        .disabled(!viewModel.isValid || viewModel.isSaving)
    }
    
    private var importanceText: String {
        switch viewModel.importance {
        case 1: return "Low"
        case 2: return "Moderate"
        case 3: return "Medium"
        case 4: return "High"
        case 5: return "Critical"
        default: return "Medium"
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(subviews[index].sizeThatFits(.unspecified))
            )
        }
    }
    
    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        let containerWidth = proposal.width ?? .infinity
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxWidth = max(maxWidth, currentX - spacing)
        }
        
        return (
            size: CGSize(width: maxWidth, height: currentY + lineHeight),
            positions: positions
        )
    }
}

// MARK: - Preview
#Preview("Add Boundary") {
    NavigationStack {
        AddBoundaryView { boundary in
            print("Created: \(boundary.title)")
        }
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
