// MARK: - BoundaryCard.swift
// Money Boundary Guardian
// Карточка границы для списка

import SwiftUI

// MARK: - Boundary Card
/// Элегантная карточка границы с эффектами
struct BoundaryCard: View {
    let boundary: BoundaryEntity
    var namespace: Namespace.ID?
    var showQuickActions: Bool = true
    var onQuickLog: (() -> Void)?
    var onTap: (() -> Void)?
    
    @State private var isPressed: Bool = false
    @State private var showCrack: Bool = false
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            HapticManager.shared.trigger(.light)
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Header
                HStack {
                    // Категория
                    if let category = boundary.category {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12))
                            Text(category.name)
                                .font(AppTypography.caption())
                        }
                        .foregroundStyle(category.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(category.color.opacity(0.15))
                        )
                    }
                    
                    Spacer()
                    
                    // Статус иконка
                    statusIcon
                }
                
                // Название границы
                Text(boundary.title)
                    .font(AppTypography.boundaryTitle())
                    .foregroundStyle(AppColors.softWhite)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Важность (щиты)
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < boundary.importance ? "shield.fill" : "shield")
                            .font(.system(size: 12))
                            .foregroundStyle(
                                index < boundary.importance
                                    ? AppColors.warmGold
                                    : AppColors.mutedGray.opacity(0.3)
                            )
                    }
                    
                    Spacer()
                    
                    // Streak
                    if boundary.currentStreak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(AppColors.warmGold)
                            Text("\(boundary.currentStreak)")
                                .font(AppTypography.caption())
                                .foregroundStyle(AppColors.warmGold)
                        }
                    }
                }
                
                // Quick Actions
                if showQuickActions && boundary.status == .pending {
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    HStack(spacing: AppSpacing.sm) {
                        QuickActionButton(
                            title: "Соблюдено",
                            icon: "checkmark",
                            color: AppColors.protectiveEmerald
                        ) {
                            onQuickLog?()
                        }
                        
                        QuickActionButton(
                            title: "Нарушено",
                            icon: "xmark",
                            color: AppColors.breachRed
                        ) {
                            showCrack = true
                            HapticManager.shared.boundaryBreached()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showCrack = false
                            }
                            onQuickLog?()
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .crackEffect(isVisible: showCrack)
            .shadow(
                color: shadowColor,
                radius: boundary.status == .kept ? 15 : 10,
                x: 0,
                y: 5
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
    
    // MARK: - Status Icon
    @ViewBuilder
    private var statusIcon: some View {
        Image(systemName: boundary.status.icon)
            .font(.system(size: 20))
            .foregroundStyle(boundary.status.color)
            .if(boundary.status == .kept) { view in
                view.animatedGlow(color: AppColors.warmGold)
            }
    }
    
    // MARK: - Computed Properties
    private var borderColor: Color {
        switch boundary.status {
        case .kept:
            return AppColors.warmGold.opacity(0.5)
        case .breached:
            return AppColors.breachRed.opacity(0.5)
        default:
            return Color.white.opacity(0.1)
        }
    }
    
    private var borderWidth: CGFloat {
        boundary.status == .kept || boundary.status == .breached ? 1.5 : 1
    }
    
    private var shadowColor: Color {
        switch boundary.status {
        case .kept:
            return AppColors.warmGold.opacity(0.3)
        case .breached:
            return AppColors.breachRed.opacity(0.2)
        default:
            return Color.black.opacity(0.2)
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(AppTypography.caption())
            }
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview("Boundary Card") {
    ZStack {
        AppColors.backgroundGradient
            .ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 16) {
                BoundaryCard(
                    boundary: .preview,
                    showQuickActions: true
                )
                
                BoundaryCard(
                    boundary: .preview,
                    showQuickActions: false
                )
            }
            .padding()
        }
    }
}
