// MARK: - Date+Extensions.swift
// Boundary Guardian
// Date utility extensions

import Foundation

extension Date {
    // MARK: - Formatting
    
    /// Full date: "February 3, 2026"
    var fullDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }
    
    /// Short date: "Feb 3"
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    /// Time: "2:30 PM"
    var time: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Date and time: "Feb 3, 2:30 PM"
    var dateTime: String {
        "\(shortDate), \(time)"
    }
    
    /// Weekday: "Monday"
    var weekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self).capitalized
    }
    
    /// Short weekday: "Mon"
    var shortWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    /// Month and year: "February 2026"
    var monthYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self).capitalized
    }
    
    // MARK: - Relative Time
    
    /// Relative time: "Today", "Yesterday", "3 days ago"
    var relative: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let components = calendar.dateComponents([.day], from: self, to: Date())
            if let days = components.day, days < 7 {
                return "\(days) day\(days == 1 ? "" : "s") ago"
            } else {
                return fullDate
            }
        }
    }
    
    // MARK: - Calculations
    
    /// Start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// End of day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// Start of week
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Start of month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Days between dates
    func daysBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: other.startOfDay)
        return abs(components.day ?? 0)
    }
    
    /// Add days
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Add weeks
    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }
    
    /// Add months
    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    // MARK: - Checks
    
    /// Is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Is this week
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Is this month
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
}

// MARK: - Streak Calculation Helper
extension Date {
    /// Calculates streak (consecutive days) for array of dates
    static func calculateStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let sortedDates = dates
            .map { $0.startOfDay }
            .sorted(by: >)  // Newest to oldest
        
        var streak = 0
        var currentDate = Date().startOfDay
        
        for date in sortedDates {
            if date == currentDate {
                streak += 1
                currentDate = currentDate.adding(days: -1)
            } else if date < currentDate {
                // Missed a day - streak broken
                break
            }
        }
        
        return streak
    }
}
