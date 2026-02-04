// MARK: - CustomTextField.swift
// Money Boundary Guardian
// Кастомные текстовые поля в премиальном стиле

import SwiftUI

// MARK: - Custom Text Field
/// Стилизованное текстовое поле
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isMultiline: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Label
            if !placeholder.isEmpty {
                Text(placeholder)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.metallicSilver)
            }
            
            // Field
            HStack(alignment: isMultiline ? .top : .center, spacing: AppSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(isFocused ? AppColors.warmGold : AppColors.mutedGray)
                        .frame(width: 24)
                }
                
                if isMultiline {
                    TextEditor(text: $text)
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.softWhite)
                        .scrollContentBackground(.hidden)
                        .focused($isFocused)
                        .frame(minHeight: 100)
                } else {
                    TextField("", text: $text)
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.softWhite)
                        .focused($isFocused)
                        .textInputAutocapitalization(.sentences)
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .stroke(
                                isFocused ? AppColors.warmGold.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}

// MARK: - Serif Text Field
/// Текстовое поле с serif шрифтом для текстов границ
struct SerifTextField: View {
    let placeholder: String
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if !placeholder.isEmpty {
                Text(placeholder)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.metallicSilver)
            }
            
            TextField("", text: $text, axis: .vertical)
                .font(AppTypography.boundaryText())
                .foregroundStyle(AppColors.softWhite)
                .focused($isFocused)
                .lineLimit(3...6)
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .stroke(
                                    isFocused ? AppColors.warmGold.opacity(0.5) : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                )
        }
    }
}

// MARK: - Preview
#Preview("Custom Text Field") {
    struct PreviewWrapper: View {
        @State private var text1 = ""
        @State private var text2 = "Некоторый текст"
        @State private var text3 = ""
        
        var body: some View {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    CustomTextField(
                        placeholder: "Название границы",
                        text: $text1,
                        icon: "shield.fill"
                    )
                    
                    CustomTextField(
                        placeholder: "Последствия нарушения",
                        text: $text2,
                        isMultiline: true
                    )
                    
                    SerifTextField(
                        placeholder: "Текст границы",
                        text: $text3
                    )
                }
                .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
