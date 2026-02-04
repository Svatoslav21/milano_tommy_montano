// MARK: - QuickComplianceLogView.swift
// Boundary Guardian
// Quick logging modal

import SwiftUI
import CoreData

// MARK: - Quick Compliance Log View
struct QuickComplianceLogView: View {
    @Environment(\.dismiss) private var dismiss
    
    let boundary: BoundaryEntity
    let onLog: (Bool, String?) -> Void
    
    @State private var isKept: Bool = true
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(boundary.title)
                        .font(.headline)
                }
                
                Section("Status") {
                    Picker("Status", selection: $isKept) {
                        Label("Kept", systemImage: "checkmark.shield.fill")
                            .tag(true)
                        Label("Breached", systemImage: "xmark.shield.fill")
                            .tag(false)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                if !isKept {
                    Section("Note (optional)") {
                        TextField("What happened?", text: $notes, axis: .vertical)
                            .lineLimit(3...5)
                    }
                }
            }
            .navigationTitle("Log Compliance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onLog(isKept, notes.isEmpty ? nil : notes)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("Quick Log") {
    QuickComplianceLogView(boundary: .preview) { isKept, notes in
        print("Logged: \(isKept ? "Kept" : "Breached"), Notes: \(notes ?? "none")")
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
