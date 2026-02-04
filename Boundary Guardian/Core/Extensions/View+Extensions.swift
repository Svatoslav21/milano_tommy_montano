// MARK: - View+Extensions.swift
// Money Boundary Guardian
// Расширения для SwiftUI View

import SwiftUI

// MARK: - Card Style Modifier
extension View {
    /// Применяет премиальный стиль карточки
    func cardStyle(padding: CGFloat = AppSpacing.md) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: Color.black.opacity(0.3),
                radius: AppShadows.cardRadius,
                x: AppShadows.cardX,
                y: AppShadows.cardY
            )
    }
    
    /// Применяет стиль карточки границы с опциональным золотым свечением
    func boundaryCardStyle(isGlowing: Bool = false) -> some View {
        self
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .stroke(
                                isGlowing
                                    ? AppColors.warmGold.opacity(0.6)
                                    : Color.white.opacity(0.1),
                                lineWidth: isGlowing ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isGlowing ? AppColors.warmGold.opacity(0.4) : Color.clear,
                        radius: isGlowing ? 20 : 0
                    )
            )
            .shadow(
                color: Color.black.opacity(0.25),
                radius: 15,
                x: 0,
                y: 8
            )
    }
    
    /// Добавляет эффект золотого свечения (для соблюдённых границ)
    func goldGlow(intensity: Double = 0.5) -> some View {
        self.shadow(
            color: AppColors.warmGold.opacity(intensity),
            radius: 20
        )
    }
    
    /// Добавляет эффект изумрудного свечения
    func emeraldGlow(intensity: Double = 0.5) -> some View {
        self.shadow(
            color: AppColors.protectiveEmerald.opacity(intensity),
            radius: 20
        )
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double
    let bounce: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + phase * geometry.size.width * 2)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: bounce)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Добавляет эффект мерцания
    func shimmer(duration: Double = 2, bounce: Bool = false) -> some View {
        modifier(ShimmerModifier(duration: duration, bounce: bounce))
    }
}

// MARK: - Pulse Animation
struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    let minScale: CGFloat
    let maxScale: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? maxScale : minScale)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    /// Добавляет пульсирующую анимацию
    func pulse(minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05, duration: Double = 1) -> some View {
        modifier(PulseModifier(minScale: minScale, maxScale: maxScale, duration: duration))
    }
}

// MARK: - Glow Animation
struct GlowModifier: ViewModifier {
    @State private var isGlowing = false
    let color: Color
    let minRadius: CGFloat
    let maxRadius: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(isGlowing ? 0.8 : 0.3),
                radius: isGlowing ? maxRadius : minRadius
            )
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: isGlowing
            )
            .onAppear {
                isGlowing = true
            }
    }
}

extension View {
    /// Добавляет анимированное свечение
    func animatedGlow(
        color: Color = AppColors.warmGold,
        minRadius: CGFloat = 5,
        maxRadius: CGFloat = 20,
        duration: Double = 1.5
    ) -> some View {
        modifier(GlowModifier(
            color: color,
            minRadius: minRadius,
            maxRadius: maxRadius,
            duration: duration
        ))
    }
}

// MARK: - Crack Effect (для нарушенных границ)
struct CrackOverlay: View {
    let isVisible: Bool
    
    var body: some View {
        if isVisible {
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    // Основная трещина
                    path.move(to: CGPoint(x: width * 0.3, y: 0))
                    path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.2))
                    path.addLine(to: CGPoint(x: width * 0.28, y: height * 0.4))
                    path.addLine(to: CGPoint(x: width * 0.38, y: height * 0.6))
                    path.addLine(to: CGPoint(x: width * 0.32, y: height * 0.8))
                    path.addLine(to: CGPoint(x: width * 0.4, y: height))
                    
                    // Ветвь 1
                    path.move(to: CGPoint(x: width * 0.35, y: height * 0.2))
                    path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.35))
                    
                    // Ветвь 2
                    path.move(to: CGPoint(x: width * 0.28, y: height * 0.4))
                    path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.5))
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            AppColors.breachRed.opacity(0.8),
                            AppColors.breachRed.opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
}

extension View {
    /// Добавляет эффект трещины на стекле
    func crackEffect(isVisible: Bool) -> some View {
        self.overlay(CrackOverlay(isVisible: isVisible))
    }
}

// MARK: - Conditional Modifier
extension View {
    /// Применяет модификатор условно
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Hide Keyboard
#if canImport(UIKit)
extension View {
    /// Скрывает клавиатуру
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
#endif
