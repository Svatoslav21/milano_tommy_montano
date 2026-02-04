// MARK: - AppTheme.swift
// Money Boundary Guardian
// Тёмная тема в стиле 1Win

import SwiftUI

// MARK: - App Colors
enum AppColors {
    // Основные цвета 1Win
    static let deepNavy = Color(hex: "0D1B2A")          // Тёмный фон
    static let primaryBlue = Color(hex: "1A7CFF")       // Основной синий 1Win
    static let accentOrange = Color(hex: "FF6B00")      // Оранжевый акцент 1Win
    static let protectiveEmerald = Color(hex: "00C853") // Зелёный для успеха
    
    // Алиасы
    static let warmGold = accentOrange
    static let metallicSilver = Color(hex: "9E9E9E")
    
    // Дополнительные цвета
    static let breachRed = Color(hex: "FF3D00")
    static let softWhite = Color(hex: "FFFFFF")
    static let mutedGray = Color(hex: "78909C")
    static let darkNavy = Color(hex: "0A1628")
    
    // Градиенты
    static let shieldGradient = LinearGradient(
        colors: [primaryBlue, primaryBlue.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [deepNavy, darkNavy],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.08),
            Color.white.opacity(0.03)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [protectiveEmerald, protectiveEmerald.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let breachGradient = LinearGradient(
        colors: [breachRed, breachRed.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - App Typography
enum AppTypography {
    static func largeTitle() -> Font {
        .system(size: 34, weight: .bold, design: .default)
    }
    
    static func title() -> Font {
        .system(size: 28, weight: .bold, design: .default)
    }
    
    static func title2() -> Font {
        .system(size: 22, weight: .semibold, design: .default)
    }
    
    static func title3() -> Font {
        .system(size: 20, weight: .semibold, design: .default)
    }
    
    static func boundaryTitle() -> Font {
        .system(size: 20, weight: .semibold, design: .default)
    }
    
    static func boundaryText() -> Font {
        .system(size: 17, weight: .regular, design: .default)
    }
    
    static func boundaryQuote() -> Font {
        .system(size: 18, weight: .medium, design: .default)
    }
    
    static func body() -> Font {
        .system(size: 17, weight: .regular, design: .default)
    }
    
    static func bodyBold() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }
    
    static func caption() -> Font {
        .system(size: 12, weight: .regular, design: .default)
    }
    
    static func caption2() -> Font {
        .system(size: 11, weight: .regular, design: .default)
    }
    
    static func statNumber() -> Font {
        .system(size: 48, weight: .bold, design: .rounded)
    }
    
    static func statLabel() -> Font {
        .system(size: 14, weight: .medium, design: .default)
    }
}

// MARK: - App Spacing
enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - App Radius
enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}

// MARK: - App Shadows
enum AppShadows {
    static func card() -> some View {
        Color.black.opacity(0.3)
    }
    
    static let cardRadius: CGFloat = 20
    static let cardX: CGFloat = 0
    static let cardY: CGFloat = 10
    
    static func glow(color: Color) -> some View {
        color.opacity(0.5)
    }
    
    static let glowRadius: CGFloat = 30
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview("App Colors") {
    ScrollView {
        VStack(spacing: 20) {
            colorSwatch("Deep Navy", AppColors.deepNavy)
            colorSwatch("Primary Blue", AppColors.primaryBlue)
            colorSwatch("Accent Orange", AppColors.accentOrange)
            colorSwatch("Protective Green", AppColors.protectiveEmerald)
            colorSwatch("Breach Red", AppColors.breachRed)
        }
        .padding()
    }
    .background(AppColors.deepNavy)
}

private func colorSwatch(_ name: String, _ color: Color) -> some View {
    HStack {
        RoundedRectangle(cornerRadius: AppRadius.md)
            .fill(color)
            .frame(width: 60, height: 60)
        
        Text(name)
            .font(AppTypography.body())
            .foregroundStyle(AppColors.softWhite)
        
        Spacer()
    }
}
