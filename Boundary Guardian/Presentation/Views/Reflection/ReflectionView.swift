// MARK: - ReflectionView.swift
// Boundary Guardian
// Reflections screen (push navigation)

import SwiftUI
import CoreData

// MARK: - Reflection View
struct ReflectionView: View {
    @State private var viewModel = ReflectionViewModel()
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(AppColors.primaryBlue)
                    .scaleEffect(1.5)
            } else if viewModel.reflections.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.reflections) { reflection in
                            NavigationLink {
                                ReflectionEditorView(viewModel: viewModel, reflection: reflection)
                            } label: {
                                ReflectionCard(reflection: reflection)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Reflections")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    ReflectionEditorView(viewModel: viewModel, reflection: nil)
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(AppColors.primaryBlue)
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .errorAlert(viewModel.errorState)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.mutedGray)
            
            Text("No Reflections")
                .font(AppTypography.title3())
                .foregroundStyle(AppColors.softWhite)
            
            Text("Create your first reflection\nto analyze your boundaries")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
                .multilineTextAlignment(.center)
            
            NavigationLink {
                ReflectionEditorView(viewModel: viewModel, reflection: nil)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Reflection")
                }
                .font(AppTypography.bodyBold())
                .foregroundStyle(AppColors.deepNavy)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(AppColors.primaryBlue)
                )
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Reflection Card
struct ReflectionCard: View {
    let reflection: ReflectionEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Header
            HStack {
                Text(reflection.createdAt.fullDate)
                    .font(AppTypography.bodyBold())
                    .foregroundStyle(AppColors.softWhite)
                
                Spacer()
                
                Text(reflection.moodEmoji)
                    .font(.system(size: 24))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.mutedGray)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Content
            if let strengths = reflection.strengths, !strengths.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.protectiveEmerald)
                        Text("What went well")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.protectiveEmerald)
                    }
                    Text(strengths)
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.softWhite.opacity(0.9))
                        .lineLimit(2)
                }
            }
            
            if let challenges = reflection.challenges, !challenges.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.accentOrange)
                        Text("Challenges")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.accentOrange)
                    }
                    Text(challenges)
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.softWhite.opacity(0.9))
                        .lineLimit(2)
                }
            }
            
            if let intentions = reflection.intentions, !intentions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "target")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.primaryBlue)
                        Text("Intentions")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.primaryBlue)
                    }
                    Text(intentions)
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.softWhite.opacity(0.9))
                        .lineLimit(2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColors.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Reflection Editor View
struct ReflectionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ReflectionViewModel
    let reflection: ReflectionEntity?
    
    @State private var strengths: String = ""
    @State private var challenges: String = ""
    @State private var intentions: String = ""
    @State private var moodRating: Int16 = 3
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // Mood Picker
                    moodSection
                    
                    // Strengths
                    textSection(
                        title: "What went well?",
                        icon: "hand.thumbsup.fill",
                        color: AppColors.protectiveEmerald,
                        text: $strengths
                    )
                    
                    // Challenges
                    textSection(
                        title: "What were the challenges?",
                        icon: "exclamationmark.triangle.fill",
                        color: AppColors.accentOrange,
                        text: $challenges
                    )
                    
                    // Intentions
                    textSection(
                        title: "Intentions for the future",
                        icon: "target",
                        color: AppColors.primaryBlue,
                        text: $intentions
                    )
                    
                    // Save Button
                    Button {
                        saveReflection()
                    } label: {
                        Text("Save")
                            .font(AppTypography.bodyBold())
                            .foregroundStyle(isFormValid ? AppColors.deepNavy : AppColors.mutedGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .fill(isFormValid ? AppColors.primaryBlue : Color.white.opacity(0.1))
                            )
                    }
                    .disabled(!isFormValid)
                    
                    // Delete Button (if editing)
                    if let reflection = reflection {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Reflection")
                            }
                            .font(AppTypography.body())
                            .foregroundStyle(AppColors.breachRed)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .fill(AppColors.breachRed.opacity(0.1))
                            )
                        }
                        .alert("Delete Reflection?", isPresented: $showDeleteAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Delete", role: .destructive) {
                                viewModel.delete(reflection)
                                dismiss()
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(reflection == nil ? "New Reflection" : "Edit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            if let reflection = reflection {
                strengths = reflection.strengths ?? ""
                challenges = reflection.challenges ?? ""
                intentions = reflection.intentions ?? ""
                moodRating = reflection.moodRating
            }
        }
    }
    
    // MARK: - Mood Section
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("How did it go?")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
            
            HStack(spacing: AppSpacing.md) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        moodRating = Int16(rating)
                    } label: {
                        Text(moodEmoji(for: Int16(rating)))
                            .font(.system(size: 32))
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(moodRating == rating 
                                          ? AppColors.primaryBlue.opacity(0.2) 
                                          : Color.white.opacity(0.05))
                            )
                            .overlay(
                                Circle()
                                    .stroke(moodRating == rating 
                                            ? AppColors.primaryBlue 
                                            : Color.clear, lineWidth: 2)
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardGradient)
            )
        }
    }
    
    // MARK: - Text Section
    private func textSection(
        title: String,
        icon: String,
        color: Color,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.mutedGray)
            }
            
            TextField("Write here...", text: text, axis: .vertical)
                .lineLimit(4...8)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(Color.white.opacity(0.05))
                )
                .foregroundStyle(AppColors.softWhite)
        }
    }
    
    private var isFormValid: Bool {
        !strengths.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !challenges.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !intentions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func moodEmoji(for rating: Int16) -> String {
        switch rating {
        case 1: return "😔"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
    
    private func saveReflection() {
        viewModel.editStrengths = strengths
        viewModel.editChallenges = challenges
        viewModel.editIntentions = intentions
        viewModel.editMoodRating = moodRating
        
        if reflection != nil {
            viewModel.selectedReflection = reflection
            viewModel.isEditing = true
        } else {
            viewModel.isEditing = false
        }
        
        viewModel.save()
        dismiss()
    }
}

// MARK: - Preview
#Preview("Reflection") {
    NavigationStack {
        ReflectionView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
