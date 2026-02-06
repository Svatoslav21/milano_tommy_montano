import Foundation
import SwiftUI

enum ExpenseCategory: String, CaseIterable, Codable, Identifiable {
    case fuel = "Fuel"
    case wash = "Car Wash"
    case oil = "Oil"
    case repair = "Repair"
    case insurance = "Insurance"
    case parking = "Parking"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fuel: return "fuelpump.fill"
        case .wash: return "drop.fill"
        case .oil: return "oilcan.fill"
        case .repair: return "wrench.and.screwdriver.fill"
        case .insurance: return "shield.fill"
        case .parking: return "parkingsign.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .fuel: return Color(hex: "FF6B6B")
        case .wash: return Color(hex: "4ECDC4")
        case .oil: return Color(hex: "FFE66D")
        case .repair: return Color(hex: "95E1D3")
        case .insurance: return Color(hex: "DDA0DD")
        case .parking: return Color(hex: "74B9FF")
        case .other: return Color(hex: "A8A8A8")
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .fuel:
            return LinearGradient(
                colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .wash:
            return LinearGradient(
                colors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .oil:
            return LinearGradient(
                colors: [Color(hex: "FFE66D"), Color(hex: "F7971E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .repair:
            return LinearGradient(
                colors: [Color(hex: "95E1D3"), Color(hex: "38EF7D")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .insurance:
            return LinearGradient(
                colors: [Color(hex: "DDA0DD"), Color(hex: "C471ED")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .parking:
            return LinearGradient(
                colors: [Color(hex: "74B9FF"), Color(hex: "0984E3")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .other:
            return LinearGradient(
                colors: [Color(hex: "A8A8A8"), Color(hex: "636E72")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct Expense: Identifiable, Codable {
    let id: UUID
    var category: ExpenseCategory
    var amount: Double
    var date: Date
    var note: String
    var mileage: Int?

    init(id: UUID = UUID(), category: ExpenseCategory, amount: Double, date: Date = Date(), note: String = "", mileage: Int? = nil) {
        self.id = id
        self.category = category
        self.amount = amount
        self.date = date
        self.note = note
        self.mileage = mileage
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
