import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var store: ExpenseStore
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerStats
                        tabSelector

                        switch selectedTab {
                        case 0:
                            monthlyAnalytics
                        case 1:
                            categoryAnalytics
                        default:
                            trendsView
                        }

                        insightsSection

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Statistics")
        }
    }

    private var headerStats: some View {
        GradientCard(
            gradient: LinearGradient(
                colors: [Color(hex: "11998E"), Color(hex: "38EF7D")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Overall Statistics")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))

                        Text(formatCurrency(totalAllTime))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("all time")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.3))
                }

                HStack(spacing: 20) {
                    StatBubble(
                        title: "Entries",
                        value: "\(store.expenses.count)",
                        icon: "doc.text.fill"
                    )

                    StatBubble(
                        title: "Average",
                        value: formatCurrency(averageExpense),
                        icon: "chart.bar.fill"
                    )

                    StatBubble(
                        title: "Maximum",
                        value: formatCurrency(maxExpense),
                        icon: "arrow.up.circle.fill"
                    )
                }
            }
        }
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(["Monthly", "Categories", "Trends"].indices, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = index
                    }
                } label: {
                    Text(["Monthly", "Categories", "Trends"][index])
                        .font(.subheadline.bold())
                        .foregroundStyle(selectedTab == index ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if selectedTab == index {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "4ECDC4").opacity(0.3))
                            }
                        }
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    private var monthlyAnalytics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Expenses")
                .font(.title3.bold())
                .foregroundStyle(.white)

            if !store.monthlyBreakdown.isEmpty {
                GlassCard {
                    VStack(spacing: 16) {
                        CategoryBarChart(data: store.monthlyBreakdown)
                            .frame(height: 180)

                        Divider()
                            .background(.white.opacity(0.2))

                        HStack {
                            VStack(alignment: .leading) {
                                Text("Average Month")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                                Text(formatCurrency(averageMonthly))
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text("Most Expensive")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                                Text(mostExpensiveMonth)
                                    .font(.headline)
                                    .foregroundStyle(Color(hex: "FF6B6B"))
                            }
                        }
                    }
                }
            } else {
                emptyState(message: "Not enough data for analysis")
            }
        }
    }

    private var categoryAnalytics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Analysis")
                .font(.title3.bold())
                .foregroundStyle(.white)

            if !store.sortedCategoryExpenses.isEmpty {
                GlassCard {
                    CategoryPieChart(data: store.sortedCategoryExpenses)
                        .frame(height: 280)
                }

                VStack(spacing: 12) {
                    ForEach(store.sortedCategoryExpenses, id: \.category) { item in
                        CategoryDetailRow(
                            category: item.category,
                            amount: item.amount,
                            count: expenseCount(for: item.category),
                            average: averageForCategory(item.category)
                        )
                    }
                }
            } else {
                emptyState(message: "No category data")
            }
        }
    }

    private var trendsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expense Trends")
                .font(.title3.bold())
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                TrendCard(
                    title: "Fuel",
                    trend: fuelTrend,
                    icon: "fuelpump.fill",
                    color: ExpenseCategory.fuel.color
                )

                TrendCard(
                    title: "Maintenance",
                    trend: maintenanceTrend,
                    icon: "wrench.and.screwdriver.fill",
                    color: ExpenseCategory.repair.color
                )

                TrendCard(
                    title: "Overall Expenses",
                    trend: overallTrend,
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color(hex: "4ECDC4")
                )
            }
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.title3.bold())
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                InsightCard(
                    icon: "lightbulb.fill",
                    title: topCategoryInsight.title,
                    description: topCategoryInsight.description,
                    color: Color(hex: "FFE66D")
                )

                if let mileageInsight = mileageInsight {
                    InsightCard(
                        icon: "speedometer",
                        title: mileageInsight.title,
                        description: mileageInsight.description,
                        color: Color(hex: "74B9FF")
                    )
                }

                InsightCard(
                    icon: "calendar",
                    title: "Expense Frequency",
                    description: frequencyInsight,
                    color: Color(hex: "DDA0DD")
                )
            }
        }
    }

    private func emptyState(message: String) -> some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.3))

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }

    private var totalAllTime: Double {
        store.expenses.reduce(0) { $0 + $1.amount }
    }

    private var averageExpense: Double {
        guard !store.expenses.isEmpty else { return 0 }
        return totalAllTime / Double(store.expenses.count)
    }

    private var maxExpense: Double {
        store.expenses.map { $0.amount }.max() ?? 0
    }

    private var averageMonthly: Double {
        guard !store.monthlyBreakdown.isEmpty else { return 0 }
        let total = store.monthlyBreakdown.reduce(0) { $0 + $1.amount }
        return total / Double(store.monthlyBreakdown.count)
    }

    private var mostExpensiveMonth: String {
        store.monthlyBreakdown.max { $0.amount < $1.amount }?.month ?? "—"
    }

    private func expenseCount(for category: ExpenseCategory) -> Int {
        store.filteredExpenses.filter { $0.category == category }.count
    }

    private func averageForCategory(_ category: ExpenseCategory) -> Double {
        let expenses = store.filteredExpenses.filter { $0.category == category }
        guard !expenses.isEmpty else { return 0 }
        return expenses.reduce(0) { $0 + $1.amount } / Double(expenses.count)
    }

    private var fuelTrend: TrendDirection {
        calculateTrend(for: .fuel)
    }

    private var maintenanceTrend: TrendDirection {
        let repairTotal = store.expensesByCategory[.repair] ?? 0
        let oilTotal = store.expensesByCategory[.oil] ?? 0
        return (repairTotal + oilTotal) > averageExpense * 2 ? .up : .stable
    }

    private var overallTrend: TrendDirection {
        .stable
    }

    private func calculateTrend(for category: ExpenseCategory) -> TrendDirection {
        let categoryExpenses = store.filteredExpenses.filter { $0.category == category }
        guard categoryExpenses.count >= 2 else { return .stable }

        let sorted = categoryExpenses.sorted { $0.date < $1.date }
        let midPoint = sorted.count / 2
        let firstHalf = sorted.prefix(midPoint).reduce(0) { $0 + $1.amount }
        let secondHalf = sorted.suffix(midPoint).reduce(0) { $0 + $1.amount }

        if secondHalf > firstHalf * 1.1 {
            return .up
        } else if secondHalf < firstHalf * 0.9 {
            return .down
        }
        return .stable
    }

    private var topCategoryInsight: (title: String, description: String) {
        guard let top = store.sortedCategoryExpenses.first else {
            return ("No Data", "Add expenses for analysis")
        }
        let percentage = Int((top.amount / store.totalExpenses) * 100)
        return (
            "Main Expenses",
            "\(top.category.rawValue) makes up \(percentage)% of your expenses"
        )
    }

    private var mileageInsight: (title: String, description: String)? {
        guard let lastMileage = store.lastMileage else { return nil }
        let fuelExpenses = store.expenses.filter { $0.category == .fuel }
        guard !fuelExpenses.isEmpty else { return nil }

        let totalFuel = fuelExpenses.reduce(0) { $0 + $1.amount }
        let costPerUnit = totalFuel / Double(lastMileage)
        let unitName = store.distanceUnit == .kilometers ? "kilometer" : "mile"

        return (
            "Cost per \(unitName.capitalized)",
            String(format: "About $%.2f per %@ on fuel", costPerUnit, unitName)
        )
    }

    private var frequencyInsight: String {
        guard !store.expenses.isEmpty else { return "No data" }
        let days = store.daysSinceFirstExpense
        guard days > 0 else { return "First day of tracking" }

        let frequency = Double(days) / Double(store.expenses.count)
        return String(format: "On average one expense every %.1f days", frequency)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
    }
}

struct StatBubble: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            Text(value)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.15))
        )
    }
}

struct CategoryDetailRow: View {
    let category: ExpenseCategory
    let amount: Double
    let count: Int
    let average: Double

    var body: some View {
        GlassCard(padding: 14) {
            HStack {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(category.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)

                    Text("\(count) entries · avg. \(formatCurrency(average))")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Text(formatCurrency(amount))
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
    }
}

enum TrendDirection {
    case up, down, stable

    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }

    var color: Color {
        switch self {
        case .up: return Color(hex: "FF6B6B")
        case .down: return Color(hex: "4ECDC4")
        case .stable: return Color(hex: "FFE66D")
        }
    }

    var text: String {
        switch self {
        case .up: return "Increasing"
        case .down: return "Decreasing"
        case .stable: return "Stable"
        }
    }
}

struct TrendCard: View {
    let title: String
    let trend: TrendDirection
    let icon: String
    let color: Color

    var body: some View {
        GlassCard(padding: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)

                    Text(trend.text)
                        .font(.caption)
                        .foregroundStyle(trend.color)
                }

                Spacer()

                Image(systemName: trend.icon)
                    .font(.title2)
                    .foregroundStyle(trend.color)
            }
        }
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        GlassCard(padding: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()
            }
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(ExpenseStore())
}
