import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: ExpenseStore
    @State private var showingAddExpense = false
    @Namespace private var animation

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerView
                        periodSelector
                        totalExpenseCard
                        statsGrid

                        if !store.sortedCategoryExpenses.isEmpty {
                            chartSection
                        }

                        if !store.sortedCategoryExpenses.isEmpty {
                            categoryBreakdown
                        }

                        if !store.recentExpenses.isEmpty {
                            recentExpensesSection
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
                    .environmentObject(store)
            }
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Expenses")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                if let mileage = store.lastMileage {
                    HStack(spacing: 4) {
                        Image(systemName: "speedometer")
                            .font(.caption)
                        Text("\(mileage.formatted()) \(store.distanceUnit.rawValue)")
                            .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
            }

            Spacer()

            Button {
                showingAddExpense = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "FF6B6B").opacity(0.5), radius: 10, y: 5)
                    )
            }
        }
    }

    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ExpenseStore.TimePeriod.allCases, id: \.self) { period in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            store.selectedPeriod = period
                        }
                    } label: {
                        Text(period.rawValue)
                            .font(.subheadline.bold())
                            .foregroundStyle(store.selectedPeriod == period ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background {
                                if store.selectedPeriod == period {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .matchedGeometryEffect(id: "period", in: animation)
                                } else {
                                    Capsule()
                                        .fill(.white.opacity(0.1))
                                }
                            }
                    }
                }
            }
        }
    }

    private var totalExpenseCard: some View {
        GradientCard(
            gradient: LinearGradient(
                colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Expenses")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))

                        Text(formatCurrency(store.totalExpenses))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Image(systemName: "car.side.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(0.3))
                }

                HStack {
                    Label("\(store.filteredExpenses.count) entries", systemImage: "list.bullet")
                    Spacer()
                    Label(store.selectedPeriod.rawValue, systemImage: "calendar")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Per Day",
                value: formatCurrency(store.averagePerDay),
                icon: "clock.fill",
                color: Color(hex: "FF6B6B")
            )

            StatCard(
                title: "Entries",
                value: "\(store.filteredExpenses.count)",
                icon: "doc.text.fill",
                color: Color(hex: "4ECDC4")
            )

            if let topCategory = store.sortedCategoryExpenses.first {
                StatCard(
                    title: "Top Category",
                    value: topCategory.category.rawValue,
                    icon: topCategory.category.icon,
                    color: topCategory.category.color
                )
            }

            if store.sortedCategoryExpenses.count > 1 {
                let fuelExpense = store.expensesByCategory[.fuel] ?? 0
                StatCard(
                    title: "On Fuel",
                    value: formatCurrency(fuelExpense),
                    icon: "fuelpump.fill",
                    color: ExpenseCategory.fuel.color
                )
            }
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Distribution")
                .font(.title3.bold())
                .foregroundStyle(.white)

            GlassCard {
                CategoryPieChart(data: store.sortedCategoryExpenses)
                    .frame(height: 250)
            }
        }
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By Category")
                .font(.title3.bold())
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                ForEach(store.sortedCategoryExpenses, id: \.category) { item in
                    CategoryRow(
                        category: item.category,
                        amount: item.amount,
                        percentage: item.amount / store.totalExpenses
                    )
                }
            }
        }
    }

    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Expenses")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Spacer()

                NavigationLink {
                    ExpenseListView()
                        .environmentObject(store)
                } label: {
                    Text("All")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color(hex: "4ECDC4"))
                }
            }

            VStack(spacing: 12) {
                ForEach(store.recentExpenses) { expense in
                    ExpenseRow(expense: expense)
                }
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        GlassCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }
}

struct CategoryRow: View {
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double

    @State private var animatedPercentage: CGFloat = 0

    var body: some View {
        GlassCard(padding: 16) {
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(category.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.rawValue)
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)

                            Text("\(Int(percentage * 100))%")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }

                    Spacer()

                    Text(formatCurrency(amount))
                        .font(.system(.body, design: .rounded).bold())
                        .foregroundStyle(.white)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.1))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(category.gradient)
                            .frame(width: geometry.size.width * animatedPercentage)
                    }
                }
                .frame(height: 6)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                animatedPercentage = percentage
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

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        GlassCard(padding: 16) {
            HStack(spacing: 14) {
                Image(systemName: expense.category.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(expense.category.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.category.rawValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)

                    Text(expense.note.isEmpty ? formatDate(expense.date) : expense.note)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(expense.amount))
                        .font(.system(.body, design: .rounded).bold())
                        .foregroundStyle(.white)

                    Text(formatDate(expense.date))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
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

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    DashboardView()
        .environmentObject(ExpenseStore())
}
