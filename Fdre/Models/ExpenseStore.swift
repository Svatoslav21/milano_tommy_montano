import Foundation
import SwiftUI
import Combine

enum DistanceUnit: String, CaseIterable, Codable {
    case kilometers = "km"
    case miles = "mi"

    var fullName: String {
        switch self {
        case .kilometers: return "Kilometers"
        case .miles: return "Miles"
        }
    }
}

@MainActor
class ExpenseStore: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var selectedPeriod: TimePeriod = .month
    @Published var distanceUnit: DistanceUnit = .kilometers {
        didSet {
            UserDefaults.standard.set(distanceUnit.rawValue, forKey: distanceUnitKey)
        }
    }

    private let saveKey = "SavedExpenses"
    private let distanceUnitKey = "DistanceUnit"

    init() {
        loadExpenses()
        loadDistanceUnit()
    }

    private func loadDistanceUnit() {
        if let savedUnit = UserDefaults.standard.string(forKey: distanceUnitKey),
           let unit = DistanceUnit(rawValue: savedUnit) {
            distanceUnit = unit
        }
    }

    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
        case all = "All Time"

        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .quarter: return 90
            case .year: return 365
            case .all: return 3650
            }
        }
    }

    var filteredExpenses: [Expense] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedPeriod.days, to: Date()) ?? Date()
        return expenses.filter { $0.date >= cutoffDate }.sorted { $0.date > $1.date }
    }

    var totalExpenses: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var expensesByCategory: [ExpenseCategory: Double] {
        var result: [ExpenseCategory: Double] = [:]
        for expense in filteredExpenses {
            result[expense.category, default: 0] += expense.amount
        }
        return result
    }

    var sortedCategoryExpenses: [(category: ExpenseCategory, amount: Double)] {
        expensesByCategory
            .map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }

    var averagePerDay: Double {
        guard !filteredExpenses.isEmpty else { return 0 }
        let days = min(selectedPeriod.days, daysSinceFirstExpense)
        return days > 0 ? totalExpenses / Double(days) : 0
    }

    var daysSinceFirstExpense: Int {
        guard let firstDate = expenses.min(by: { $0.date < $1.date })?.date else { return 0 }
        return Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day ?? 0
    }

    var lastMileage: Int? {
        expenses.compactMap { $0.mileage }.max()
    }

    var monthlyBreakdown: [(month: String, amount: Double)] {
        var breakdown: [String: Double] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM"

        for expense in filteredExpenses {
            let monthKey = dateFormatter.string(from: expense.date)
            breakdown[monthKey, default: 0] += expense.amount
        }

        let sortedMonths = filteredExpenses
            .map { expense -> (date: Date, month: String) in
                let monthKey = dateFormatter.string(from: expense.date)
                return (expense.date, monthKey)
            }
            .sorted { $0.date < $1.date }
            .reduce(into: [String]()) { result, item in
                if !result.contains(item.month) {
                    result.append(item.month)
                }
            }

        return sortedMonths.map { month in
            (month: month, amount: breakdown[month] ?? 0)
        }
    }

    var recentExpenses: [Expense] {
        Array(filteredExpenses.prefix(5))
    }

    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveExpenses()
    }

    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveExpenses()
        }
    }

    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveExpenses()
    }

    func deleteExpenses(at offsets: IndexSet) {
        let expensesToDelete = offsets.map { filteredExpenses[$0] }
        for expense in expensesToDelete {
            expenses.removeAll { $0.id == expense.id }
        }
        saveExpenses()
    }

    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadExpenses() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
    }
}
