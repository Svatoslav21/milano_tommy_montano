// MARK: - CategoryPicker.swift
// Money Boundary Guardian
// Компонент выбора категории

import SwiftUI

// MARK: - Category Picker
/// Горизонтальный скроллинг выбора категории
struct CategoryPicker: View {
    @Binding var selectedCategory: CategoryEntity?
    let categories: [CategoryEntity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Категория")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.metallicSilver)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    // Опция "Без категории"
                    CategoryChip(
                        name: "Без категории",
                        icon: "folder",
                        color: AppColors.mutedGray,
                        isSelected: selectedCategory == nil
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = nil
                        }
                        HapticManager.shared.trigger(.selection)
                    }
                    
                    // Категории
                    ForEach(categories) { category in
                        CategoryChip(
                            name: category.name,
                            icon: category.icon,
                            color: category.color,
                            isSelected: selectedCategory?.id == category.id
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = category
                            }
                            HapticManager.shared.trigger(.selection)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(name)
                    .font(AppTypography.caption())
            }
            .foregroundStyle(isSelected ? AppColors.deepNavy : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Badge
/// Компактный бейдж категории
struct CategoryBadge: View {
    let category: CategoryEntity?
    
    var body: some View {
        if let category = category {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.system(size: 10))
                Text(category.name)
                    .font(AppTypography.caption2())
            }
            .foregroundStyle(category.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(category.color.opacity(0.15))
            )
        }
    }
}

// MARK: - Preview
#Preview("Category Picker") {
    struct PreviewWrapper: View {
        @State private var selectedCategory: CategoryEntity?
        
        var body: some View {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                CategoryPicker(
                    selectedCategory: $selectedCategory,
                    categories: []
                )
                .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
