// MARK: - AppNotifications.swift
// Boundary Guardian
// Application-wide notifications

import Foundation

// MARK: - App Notifications
extension Notification.Name {
    /// Posted when all data has been reset
    static let dataDidReset = Notification.Name("com.boundaryguardian.dataDidReset")
    
    /// Posted when a boundary has been modified
    static let boundaryDidChange = Notification.Name("com.boundaryguardian.boundaryDidChange")
    
    /// Posted when categories have been modified
    static let categoriesDidChange = Notification.Name("com.boundaryguardian.categoriesDidChange")
}

// MARK: - Notification Helper
struct AppNotifications {
    /// Post data reset notification
    static func postDataReset() {
        NotificationCenter.default.post(name: .dataDidReset, object: nil)
    }
    
    /// Post boundary change notification
    static func postBoundaryChange() {
        NotificationCenter.default.post(name: .boundaryDidChange, object: nil)
    }
    
    /// Post categories change notification
    static func postCategoriesChange() {
        NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
    }
}
