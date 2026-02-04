// MARK: - SplashScreen.swift
// Boundary Guardian
// Loading screen

import SwiftUI

// MARK: - Splash Screen
struct SplashScreen: View {
    let onComplete: () -> Void
    
    @State private var showShield = false
    @State private var showText = false
    @State private var glowOpacity = 0.0
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(AppColors.primaryBlue.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .blur(radius: 30)
                        .opacity(glowOpacity)
                    
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 80))
                        .foregroundStyle(AppColors.primaryBlue)
                        .scaleEffect(showShield ? 1 : 0.5)
                        .opacity(showShield ? 1 : 0)
                }
                
                VStack(spacing: 8) {
                    Text("Boundary Guardian")
                        .font(AppTypography.title())
                        .foregroundStyle(AppColors.softWhite)
                    
                    Text("Protect Your Financial Boundaries")
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.mutedGray)
                }
                .opacity(showText ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showShield = true
            }
            
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                glowOpacity = 0.8
            }
            
            withAnimation(.easeOut.delay(0.3)) {
                showText = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete()
            }
        }
    }
}

// MARK: - Preview
#Preview("Splash") {
    SplashScreen {}
}
