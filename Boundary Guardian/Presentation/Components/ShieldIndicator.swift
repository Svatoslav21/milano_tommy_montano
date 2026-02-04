// MARK: - ShieldIndicator.swift
// Money Boundary Guardian
// Компонент индикатора силы границ (щит)

import SwiftUI

// MARK: - Shield Indicator
/// Центральный индикатор "Boundary Strength" в виде щита
struct ShieldIndicator: View {
    let percentage: Int
    let animate: Bool
    
    @State private var animatedPercentage: Double = 0
    @State private var glowOpacity: Double = 0
    
    // MARK: - Computed Properties
    private var color: Color {
        if percentage >= 80 {
            return AppColors.protectiveEmerald
        } else if percentage >= 50 {
            return AppColors.primaryBlue
        } else {
            return AppColors.breachRed
        }
    }
    
    private var statusText: String {
        if percentage >= 90 {
            return "Превосходно"
        } else if percentage >= 70 {
            return "Отлично"
        } else if percentage >= 50 {
            return "Хорошо"
        } else if percentage >= 30 {
            return "Внимание"
        } else {
            return "Критично"
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Фоновое свечение
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 220, height: 220)
                .blur(radius: 30)
                .opacity(glowOpacity)
            
            // Внешний круг прогресса
            Circle()
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 12
                )
                .frame(width: 180, height: 180)
            
            // Прогресс
            Circle()
                .trim(from: 0, to: animatedPercentage / 100)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.5), color, color],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90))
            
            // Щит
            ZStack {
                // Фон щита
                ShieldShape()
                    .fill(AppColors.cardGradient)
                    .frame(width: 100, height: 120)
                    .overlay(
                        ShieldShape()
                            .stroke(color.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: color.opacity(0.5), radius: glowOpacity > 0 ? 15 : 0)
                
                // Контент
                VStack(spacing: 4) {
                    Text("\(Int(animatedPercentage))")
                        .font(AppTypography.statNumber())
                        .foregroundStyle(color)
                        .contentTransition(.numericText())
                    
                    Text("%")
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.metallicSilver)
                }
                .offset(y: -5)
            }
            
            // Статус текст
            VStack {
                Spacer()
                Text(statusText)
                    .font(AppTypography.caption())
                    .foregroundStyle(color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.15))
                    )
            }
            .frame(height: 240)
        }
        .frame(width: 240, height: 260)
        .onAppear {
            if animate {
                startAnimation()
            } else {
                animatedPercentage = Double(percentage)
                glowOpacity = 1
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
        animatedPercentage = 0
        glowOpacity = 0
        
        withAnimation(.easeOut(duration: 1.5)) {
            animatedPercentage = Double(percentage)
        }
        
        withAnimation(.easeInOut(duration: 1).delay(0.5)) {
            glowOpacity = 1
        }
    }
}

// MARK: - Shield Shape
struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Начинаем сверху по центру
        path.move(to: CGPoint(x: width / 2, y: 0))
        
        // Верхняя правая дуга
        path.addQuadCurve(
            to: CGPoint(x: width, y: height * 0.15),
            control: CGPoint(x: width * 0.85, y: 0)
        )
        
        // Правая сторона
        path.addLine(to: CGPoint(x: width, y: height * 0.5))
        
        // Нижняя правая дуга к острию
        path.addQuadCurve(
            to: CGPoint(x: width / 2, y: height),
            control: CGPoint(x: width, y: height * 0.85)
        )
        
        // Нижняя левая дуга
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height * 0.5),
            control: CGPoint(x: 0, y: height * 0.85)
        )
        
        // Левая сторона
        path.addLine(to: CGPoint(x: 0, y: height * 0.15))
        
        // Верхняя левая дуга
        path.addQuadCurve(
            to: CGPoint(x: width / 2, y: 0),
            control: CGPoint(x: width * 0.15, y: 0)
        )
        
        return path
    }
}

// MARK: - Preview
#Preview("Shield Indicator") {
    ZStack {
        AppColors.backgroundGradient
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            ShieldIndicator(percentage: 92, animate: true)
            ShieldIndicator(percentage: 65, animate: false)
            ShieldIndicator(percentage: 25, animate: false)
        }
    }
}
