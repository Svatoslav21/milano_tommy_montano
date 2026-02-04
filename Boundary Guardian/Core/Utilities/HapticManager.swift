// MARK: - HapticManager.swift
// Boundary Guardian
// Haptic feedback management for enhanced UX

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Haptic Manager
/// Haptic feedback manager
/// Creates physical feedback on app interactions
@MainActor
final class HapticManager {
    
    // MARK: - Singleton
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Haptic Types
    enum HapticType {
        case success      // Boundary kept
        case error        // Boundary breached
        case warning      // Warning
        case light        // Light tap
        case medium       // Medium press
        case heavy        // Heavy press
        case selection    // Element selection
        case rigid        // Rigid impact
        case soft         // Soft impact
    }
    
    // MARK: - Trigger Haptic
    /// Triggers haptic feedback of the specified type
    func trigger(_ type: HapticType) {
        #if os(iOS)
        switch type {
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
            
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
            
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.warning)
            
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
            
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
            
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
            
        case .rigid:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.prepare()
            generator.impactOccurred()
            
        case .soft:
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.prepare()
            generator.impactOccurred()
        }
        #endif
    }
    
    // MARK: - Boundary Events
    /// Called when boundary is kept
    func boundaryKept() {
        trigger(.success)
    }
    
    /// Called when boundary is breached
    func boundaryBreached() {
        // Double vibration for enhanced effect
        trigger(.error)
        
        // Additional vibration after short delay
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            trigger(.heavy)
        }
    }
    
    /// Called when achievement is earned
    func achievement() {
        trigger(.success)
        
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            trigger(.medium)
            try? await Task.sleep(nanoseconds: 200_000_000)
            trigger(.light)
        }
    }
}

// MARK: - View Extension for Haptics
extension View {
    /// Adds haptic feedback on tap
    func hapticOnTap(_ type: HapticManager.HapticType = .light) -> some View {
        self.onTapGesture {
            HapticManager.shared.trigger(type)
        }
    }
}
