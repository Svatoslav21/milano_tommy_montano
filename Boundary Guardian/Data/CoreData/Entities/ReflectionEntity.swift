// MARK: - ReflectionEntity.swift
// Boundary Guardian
// Core Data entity for weekly reflection

import CoreData
import SwiftUI

// MARK: - Reflection Entity
/// Entity representing a weekly reflection
/// Helps the user mindfully approach boundary adherence
@objc(ReflectionEntity)
public class ReflectionEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var weekStartDate: Date       // Start of the reflection week
    @NSManaged public var strengths: String?        // What went well
    @NSManaged public var challenges: String?       // Difficulties faced
    @NSManaged public var intentions: String?       // Intentions for next week
    @NSManaged public var moodRating: Int16         // Mood rating 1-5
    @NSManaged public var createdAt: Date
    
    // MARK: - Computed Properties
    
    /// Formatted week
    var weekFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM d"
        
        let endDate = weekStartDate.adding(days: 6)
        return "\(formatter.string(from: weekStartDate)) – \(formatter.string(from: endDate))"
    }
    
    /// Week year
    var year: Int {
        Calendar.current.component(.year, from: weekStartDate)
    }
    
    /// Week number
    var weekNumber: Int {
        Calendar.current.component(.weekOfYear, from: weekStartDate)
    }
    
    /// Mood emoji
    var moodEmoji: String {
        switch moodRating {
        case 1: return "😔"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
    
    /// Mood text
    var moodText: String {
        switch moodRating {
        case 1: return "Tough week"
        case 2: return "Challenging week"
        case 3: return "Okay week"
        case 4: return "Good week"
        case 5: return "Great week"
        default: return "Okay week"
        }
    }
    
    /// Mood color
    var moodColor: Color {
        switch moodRating {
        case 1, 2: return AppColors.breachRed
        case 3: return AppColors.metallicSilver
        case 4, 5: return AppColors.protectiveEmerald
        default: return AppColors.metallicSilver
        }
    }
    
    /// Is reflection completed
    var isCompleted: Bool {
        (strengths != nil && !strengths!.isEmpty) ||
        (challenges != nil && !challenges!.isEmpty) ||
        (intentions != nil && !intentions!.isEmpty)
    }
}

// MARK: - Fetch Requests
extension ReflectionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReflectionEntity> {
        return NSFetchRequest<ReflectionEntity>(entityName: "ReflectionEntity")
    }
    
    /// Fetch reflections sorted by date
    static func sortedFetchRequest() -> NSFetchRequest<ReflectionEntity> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ReflectionEntity.weekStartDate, ascending: false)
        ]
        return request
    }
    
    /// Fetch reflection for current week
    static func currentWeekFetchRequest() -> NSFetchRequest<ReflectionEntity> {
        let request = fetchRequest()
        let weekStart = Date().startOfWeek
        request.predicate = NSPredicate(format: "weekStartDate == %@", weekStart as NSDate)
        request.fetchLimit = 1
        return request
    }
    
    /// Fetch recent N reflections
    static func recentFetchRequest(limit: Int = 12) -> NSFetchRequest<ReflectionEntity> {
        let request = sortedFetchRequest()
        request.fetchLimit = limit
        return request
    }
}

// MARK: - Prompts
extension ReflectionEntity {
    /// Prompts for "Strengths" section
    static let strengthPrompts = [
        "What boundaries did you successfully protect this week?",
        "What helped you maintain control?",
        "What decisions brought you satisfaction?"
    ]
    
    /// Prompts for "Challenges" section
    static let challengePrompts = [
        "What was the hardest part of this week?",
        "Were there moments when you wanted to break a boundary?",
        "What triggered those moments?"
    ]
    
    /// Prompts for "Intentions" section
    static let intentionPrompts = [
        "Which boundaries need special attention?",
        "What will you do differently next week?",
        "What support will you arrange for yourself?"
    ]
}

// MARK: - Preview Helper
extension ReflectionEntity {
    @MainActor
    static var preview: ReflectionEntity {
        let context = PersistenceController.preview.container.viewContext
        let reflection = ReflectionEntity(context: context)
        reflection.id = UUID()
        reflection.weekStartDate = Date().startOfWeek
        reflection.strengths = "Successfully refused a loan I would have given before"
        reflection.challenges = "Hard not to impulse buy a new iPhone"
        reflection.intentions = "Continue 24-hour rule for major purchases"
        reflection.moodRating = 4
        reflection.createdAt = Date()
        return reflection
    }
}
