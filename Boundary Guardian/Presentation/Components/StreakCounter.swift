// MARK: - StreakCounter.swift
// Money Boundary Guardian
// Компонент счётчика streak с пульсирующей анимацией

import SwiftUI

// MARK: - Streak Counter
/// Отображает streak (серию дней) с анимацией
struct StreakCounter: View {
    let currentStreak: Int
    let longestStreak: Int
    let animate: Bool
    
    @State private var animatedValue: Int = 0
    @State private var isPulsing: Bool = false
    
    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            // Текущий streak
            StreakItem(
                title: "Текущий streak",
                value: animate ? animatedValue : currentStreak,
                icon: "flame.fill",
                color: AppColors.accentOrange,
                isPulsing: isPulsing && currentStreak > 0
            )
            
            Divider()
                .frame(height: 50)
                .background(Color.white.opacity(0.1))
            
            // Лучший streak
            StreakItem(
                title: "Лучший streak",
                value: longestStreak,
                icon: "crown.fill",
                color: AppColors.protectiveEmerald,
                isPulsing: false
            )
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColors.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            if animate {
                startAnimation()
            }
        }
        .onChange(of: animate) { _, newValue in
            if newValue {
                startAnimation()
            }
        }
    }
    
    // MARK: - Animation
    private func startAnimation() {
        animatedValue = 0
        isPulsing = false
        
        // Анимируем счётчик
        withAnimation(.easeOut(duration: 1.0)) {
            animatedValue = currentStreak
        }
        
        // Запускаем пульсацию
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Streak Item
struct StreakItem: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let isPulsing: Bool
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .shadow(
                        color: isPulsing ? color.opacity(0.6) : Color.clear,
                        radius: isPulsing ? 8 : 0
                    )
                
                Text("\(value)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
            }
            
            Text(title)
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            // Дни
            Text(daysWord(value))
                .font(AppTypography.caption2())
                .foregroundStyle(AppColors.mutedGray.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func daysWord(_ count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "дней"
        }
        
        switch lastDigit {
        case 1: return "день"
        case 2, 3, 4: return "дня"
        default: return "дней"
        }
    }
}

// MARK: - Compact Streak Badge
/// Компактный бейдж streak для карточек
struct StreakBadge: View {
    let streak: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 12))
            Text("\(streak)")
                .font(AppTypography.caption())
        }
        .foregroundStyle(AppColors.accentOrange)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(AppColors.accentOrange.opacity(0.15))
        )
    }
}

// MARK: - Preview
#Preview("Streak Counter") {
    ZStack {
        AppColors.backgroundGradient
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            StreakCounter(
                currentStreak: 15,
                longestStreak: 30,
                animate: true
            )
            
            StreakBadge(streak: 7)
        }
        .padding()
    }
}
