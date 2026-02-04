// MARK: - CategoriesManagerView.swift
// Boundary Guardian
// Category management screen (push navigation)

import SwiftUI
import CoreData

// MARK: - Categories Manager View
struct CategoriesManagerView: View {
    @State private var viewModel = CategoriesViewModel()
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(AppColors.primaryBlue)
                    .scaleEffect(1.5)
            } else if viewModel.categories.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.categories) { category in
                            NavigationLink {
                                CategoryEditorView(viewModel: viewModel, category: category)
                            } label: {
                                CategoryRow(category: category)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    CategoryEditorView(viewModel: viewModel, category: nil)
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(AppColors.primaryBlue)
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .errorAlert(viewModel.errorState)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.mutedGray)
            
            Text("No Categories")
                .font(AppTypography.title3())
                .foregroundStyle(AppColors.softWhite)
            
            Text("Create categories to organize your boundaries")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            NavigationLink {
                CategoryEditorView(viewModel: viewModel, category: nil)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Category")
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
        }
    }
}

// MARK: - Category Row
struct CategoryRow: View {
    let category: CategoryEntity
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundStyle(category.color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(AppTypography.bodyBold())
                    .foregroundStyle(AppColors.softWhite)
                
                Text("\(category.boundariesCount) boundaries")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.mutedGray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.mutedGray)
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

// MARK: - Category Editor View
struct CategoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CategoriesViewModel
    let category: CategoryEntity?
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "folder.fill"
    @State private var selectedColorHex: String = "1A7CFF"
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // Name Field
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Name")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.mutedGray)
                        
                        TextField("Category name", text: $name)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .foregroundStyle(AppColors.softWhite)
                    }
                    
                    // Icon Picker
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Icon")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.mutedGray)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(viewModel.availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundStyle(selectedIcon == icon ? Color(hex: selectedColorHex) : AppColors.mutedGray)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedIcon == icon ? Color(hex: selectedColorHex).opacity(0.2) : Color.white.opacity(0.05))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.lg)
                                .fill(AppColors.cardGradient)
                        )
                    }
                    
                    // Color Picker
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Color")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.mutedGray)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(viewModel.availableColors, id: \.self) { colorHex in
                                Button {
                                    selectedColorHex = colorHex
                                } label: {
                                    Circle()
                                        .fill(Color(hex: colorHex))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColorHex == colorHex ? AppColors.softWhite : Color.clear, lineWidth: 3)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.lg)
                                .fill(AppColors.cardGradient)
                        )
                    }
                    
                    // Save Button
                    Button {
                        saveCategory()
                    } label: {
                        Text("Save")
                            .font(AppTypography.bodyBold())
                            .foregroundStyle(isFormValid ? AppColors.deepNavy : AppColors.mutedGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .fill(isFormValid ? AppColors.primaryBlue : Color.white.opacity(0.1))
                            )
                    }
                    .disabled(!isFormValid)
                    
                    // Delete Button (if editing)
                    if let category = category {
                        Button(role: .destructive) {
                            viewModel.deleteCategory(category)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Category")
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
                .padding()
            }
        }
        .navigationTitle(category == nil ? "New Category" : "Edit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            if let category = category {
                name = category.name
                selectedIcon = category.icon
                selectedColorHex = category.colorHex
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveCategory() {
        if let category = category {
            category.name = name
            category.icon = selectedIcon
            category.colorHex = selectedColorHex
            viewModel.updateCategory(category)
        } else {
            viewModel.addCategory(name: name, icon: selectedIcon, colorHex: selectedColorHex)
        }
        dismiss()
    }
}

// MARK: - Preview
#Preview("Categories Manager") {
    NavigationStack {
        CategoriesManagerView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
