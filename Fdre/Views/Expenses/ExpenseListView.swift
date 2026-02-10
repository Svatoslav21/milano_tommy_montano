import SwiftUI

struct ExpenseListView: View {
    @EnvironmentObject var store: ExpenseStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: ExpenseCategory?
    @State private var showingAddExpense = false
    @State private var expenseToEdit: Expense?

    var filteredExpenses: [Expense] {
        var expenses = store.filteredExpenses

        if let category = selectedCategory {
            expenses = expenses.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            expenses = expenses.filter {
                $0.note.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }

        return expenses
    }

    var groupedExpenses: [(key: String, expenses: [Expense])] {
        let grouped = Dictionary(grouping: filteredExpenses) { expense -> String in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: expense.date)
        }

        return grouped.map { (key: $0.key, expenses: $0.value) }
            .sorted { first, second in
                guard let firstDate = first.expenses.first?.date,
                      let secondDate = second.expenses.first?.date else {
                    return false
                }
                return firstDate > secondDate
            }
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white.opacity(0.5))

                        TextField("Search...", text: $searchText)
                            .foregroundStyle(.white)
                            .autocorrectionDisabled()

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                color: Color(hex: "4ECDC4")
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = nil
                                }
                            }

                            ForEach(ExpenseCategory.allCases) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category,
                                    color: category.color
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 16)

                if filteredExpenses.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 20) {
                            ForEach(groupedExpenses, id: \.key) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.key)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.white.opacity(0.6))
                                        .padding(.horizontal, 4)

                                    ForEach(group.expenses) { expense in
                                        ExpenseListRow(expense: expense, distanceUnit: store.distanceUnit)
                                            .onTapGesture {
                                                expenseToEdit = expense
                                            }
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    withAnimation {
                                                        store.deleteExpense(expense)
                                                    }
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }

                                                Button {
                                                    expenseToEdit = expense
                                                } label: {
                                                    Label("Edit", systemImage: "pencil")
                                                }
                                            }
                                    }
                                }
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .navigationTitle("All Expenses")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color(hex: "4ECDC4"))
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
                .environmentObject(store)
        }
        .sheet(item: $expenseToEdit) { expense in
            AddExpenseView(editingExpense: expense)
                .environmentObject(store)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.3))

            Text("Nothing Found")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Try changing your search parameters")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }
}

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption.bold())
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill(color.opacity(0.8))
                } else {
                    Capsule()
                        .fill(.white.opacity(0.1))
                }
            }
        }
    }
}

struct ExpenseListRow: View {
    let expense: Expense
    let distanceUnit: DistanceUnit
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(expense.category.gradient)
                    .frame(width: 50, height: 50)

                Image(systemName: expense.category.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category.rawValue)
                    .font(.headline)
                    .foregroundStyle(.white)

                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }

                if let mileage = expense.mileage {
                    HStack(spacing: 4) {
                        Image(systemName: "speedometer")
                            .font(.caption2)
                        Text("\(mileage.formatted()) \(distanceUnit.rawValue)")
                            .font(.caption2)
                    }
                    .foregroundStyle(.white.opacity(0.5))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(expense.amount))
                    .font(.system(.headline, design: .rounded).bold())
                    .foregroundStyle(.white)

                Text(formatTime(expense.date))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.3), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity) {
        } onPressingChanged: { pressing in
            isPressed = pressing
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

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ExpenseListView()
            .environmentObject(ExpenseStore())
    }
}
