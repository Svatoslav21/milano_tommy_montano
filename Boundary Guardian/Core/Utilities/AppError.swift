// MARK: - AppError.swift
// Boundary Guardian
// Application error handling system

import Foundation
import SwiftUI

// MARK: - App Error
/// Centralized error handling for the application
enum AppError: LocalizedError, Equatable {
    case coreDataLoad(String)
    case coreDataSave(String)
    case coreDataFetch(String)
    case validationError(String)
    case exportError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .coreDataLoad(let message):
            return "Database loading error: \(message)"
        case .coreDataSave(let message):
            return "Failed to save data: \(message)"
        case .coreDataFetch(let message):
            return "Failed to fetch data: \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .exportError(let message):
            return "Export error: \(message)"
        case .unknown(let message):
            return "An error occurred: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .coreDataLoad, .coreDataSave, .coreDataFetch:
            return "Please try again. If the problem persists, restart the app."
        case .validationError:
            return "Please check your input and try again."
        case .exportError:
            return "Please try exporting again."
        case .unknown:
            return "Please try again later."
        }
    }
    
    var icon: String {
        switch self {
        case .coreDataLoad, .coreDataSave, .coreDataFetch:
            return "externaldrive.badge.exclamationmark"
        case .validationError:
            return "exclamationmark.triangle"
        case .exportError:
            return "square.and.arrow.up.trianglebadge.exclamationmark"
        case .unknown:
            return "exclamationmark.circle"
        }
    }
}

// MARK: - Error State
/// Observable error state for ViewModels
@MainActor
@Observable
final class ErrorState {
    var currentError: AppError?
    var showError: Bool = false
    
    func show(_ error: AppError) {
        currentError = error
        showError = true
    }
    
    func dismiss() {
        showError = false
        currentError = nil
    }
}

// MARK: - Error Alert View Modifier
struct ErrorAlertModifier: ViewModifier {
    @Bindable var errorState: ErrorState
    
    func body(content: Content) -> some View {
        content
            .alert(
                "Error",
                isPresented: $errorState.showError,
                presenting: errorState.currentError
            ) { _ in
                Button("OK") {
                    errorState.dismiss()
                }
            } message: { error in
                VStack {
                    Text(error.errorDescription ?? "An error occurred")
                    if let recovery = error.recoverySuggestion {
                        Text(recovery)
                            .font(.caption)
                    }
                }
            }
    }
}

extension View {
    func errorAlert(_ errorState: ErrorState) -> some View {
        modifier(ErrorAlertModifier(errorState: errorState))
    }
}

// MARK: - Result Extension
extension Result where Failure == AppError {
    var appError: AppError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
