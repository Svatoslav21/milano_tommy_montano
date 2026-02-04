// MARK: - ImportancePicker.swift
// Money Boundary Guardian
// Компонент выбора важности (1-5 щитов)

import SwiftUI

// MARK: - Importance Picker
/// Выбор уровня важности границы через щиты
struct ImportancePicker: View {
    @Binding var value: Int16
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Уровень важности")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.metallicSilver)
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(1...5, id: \.self) { level in
                    ShieldButton(
                        level: Int16(level),
                        isSelected: value >= level,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                value = Int16(level)
                            }
                            HapticManager.shared.trigger(.selection)
                        }
                    )
                }
                
                Spacer()
                
                // Текстовое описание
                Text(importanceText)
                    .font(AppTypography.caption())
                    .foregroundStyle(importanceColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(importanceColor.opacity(0.15))
                    )
            }
        }
    }
    
    // MARK: - Computed Properties
    private var importanceText: String {
        switch value {
        case 1: return "Низкая"
        case 2: return "Умеренная"
        case 3: return "Средняя"
        case 4: return "Высокая"
        case 5: return "Критическая"
        default: return "Средняя"
        }
    }
    
    private var importanceColor: Color {
        switch value {
        case 1, 2: return AppColors.metallicSilver
        case 3: return AppColors.warmGold
        case 4, 5: return AppColors.protectiveEmerald
        default: return AppColors.metallicSilver
        }
    }
}

// MARK: - Shield Button
struct ShieldButton: View {
    let level: Int16
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "shield.fill" : "shield")
                .font(.system(size: 28))
                .foregroundStyle(
                    isSelected ? AppColors.primaryBlue : AppColors.mutedGray.opacity(0.4)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Preview
#Preview("Importance Picker") {
    struct PreviewWrapper: View {
        @State private var importance: Int16 = 3
        
        var body: some View {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                ImportancePicker(value: $importance)
                    .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
