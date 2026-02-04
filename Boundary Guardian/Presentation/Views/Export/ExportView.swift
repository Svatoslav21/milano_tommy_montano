// MARK: - ExportView.swift
// Boundary Guardian
// Data export screen (push navigation)

import SwiftUI
import CoreData

// MARK: - Export View
struct ExportView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var isExportingPDF = false
    @State private var isCreatingBackup = false
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // PDF Report Section
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("PDF Report")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.mutedGray)
                        
                        Button {
                            isExportingPDF = true
                            viewModel.exportPDF()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isExportingPDF = false
                            }
                        } label: {
                            HStack {
                                Image(systemName: "doc.richtext.fill")
                                    .foregroundStyle(AppColors.primaryBlue)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Create PDF Report")
                                        .font(AppTypography.body())
                                        .foregroundStyle(AppColors.softWhite)
                                    
                                    Text("Beautiful report of your financial boundaries")
                                        .font(AppTypography.caption())
                                        .foregroundStyle(AppColors.mutedGray)
                                }
                                
                                Spacer()
                                
                                if isExportingPDF {
                                    ProgressView()
                                        .tint(AppColors.primaryBlue)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppColors.mutedGray)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .fill(AppColors.cardGradient)
                            )
                        }
                        .disabled(isExportingPDF)
                    }
                    
                    // Backup Section
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Backup")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.mutedGray)
                        
                        Button {
                            isCreatingBackup = true
                            viewModel.createBackup()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isCreatingBackup = false
                            }
                        } label: {
                            HStack {
                                Image(systemName: "externaldrive.fill")
                                    .foregroundStyle(AppColors.protectiveEmerald)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Create Backup")
                                        .font(AppTypography.body())
                                        .foregroundStyle(AppColors.softWhite)
                                    
                                    Text("Export all data as JSON")
                                        .font(AppTypography.caption())
                                        .foregroundStyle(AppColors.mutedGray)
                                }
                                
                                Spacer()
                                
                                if isCreatingBackup {
                                    ProgressView()
                                        .tint(AppColors.protectiveEmerald)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppColors.mutedGray)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .fill(AppColors.cardGradient)
                            )
                        }
                        .disabled(isCreatingBackup)
                    }
                    
                    // Info
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(AppColors.primaryBlue)
                        
                        Text("All data is stored locally on your device. Create backups regularly.")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.mutedGray)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .fill(AppColors.primaryBlue.opacity(0.1))
                    )
                }
                .padding()
            }
        }
        .navigationTitle("Export")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .errorAlert(viewModel.errorState)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
#Preview("Export") {
    NavigationStack {
        ExportView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
