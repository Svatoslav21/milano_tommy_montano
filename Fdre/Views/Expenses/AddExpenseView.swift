import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var store: ExpenseStore
    @Environment(\.dismiss) var dismiss

    var editingExpense: Expense?

    @State private var selectedCategory: ExpenseCategory = .fuel
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var mileage: String = ""
    @State private var date: Date = Date()
    @State private var showingDatePicker = false

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case amount, note, mileage
    }

    var isEditing: Bool {
        editingExpense != nil
    }

    var isValid: Bool {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            return false
        }
        return amountValue > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        categorySelector
                        amountInput
                        dateSelector
                        noteInput
                        mileageInput
                        saveButton

                        if isEditing {
                            deleteButton
                        }

                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle(isEditing ? "Edit Expense" : "New Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.8))
                }

                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
            }
            .onAppear {
                if let expense = editingExpense {
                    selectedCategory = expense.category
                    amount = String(format: "%.0f", expense.amount)
                    note = expense.note
                    if let expMileage = expense.mileage {
                        mileage = String(expMileage)
                    }
                    date = expense.date
                }
            }
        }
    }

    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.subheadline.bold())
                .foregroundStyle(.white.opacity(0.8))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ExpenseCategory.allCases) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    private var amountInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.subheadline.bold())
                .foregroundStyle(.white.opacity(0.8))

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)

                    HStack {
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .amount)

                        Text("$")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 70)
            }

            HStack(spacing: 10) {
                ForEach([10, 25, 50, 100], id: \.self) { value in
                    Button {
                        amount = String(value)
                    } label: {
                        Text("+\(value)")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.1))
                            )
                    }
                }
            }
        }
    }

    private var dateSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date")
                .font(.subheadline.bold())
                .foregroundStyle(.white.opacity(0.8))

            Button {
                withAnimation {
                    showingDatePicker.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color(hex: "4ECDC4"))

                    Text(formatDate(date))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: showingDatePicker ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
            }

            if showingDatePicker {
                DatePicker(
                    "Date",
                    selection: $date,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .tint(Color(hex: "4ECDC4"))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
                .environment(\.locale, Locale(identifier: "en_US"))
            }
        }
    }

    private var noteInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Note")
                .font(.subheadline.bold())
                .foregroundStyle(.white.opacity(0.8))

            TextField("Expense description...", text: $note, axis: .vertical)
                .lineLimit(3...5)
                .foregroundStyle(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
                .focused($focusedField, equals: .note)
        }
    }

    private var mileageInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mileage")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white.opacity(0.8))

                Text("(optional)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            HStack {
                Image(systemName: "speedometer")
                    .foregroundStyle(Color(hex: "FFE66D"))

                TextField("Current mileage", text: $mileage)
                    .keyboardType(.numberPad)
                    .foregroundStyle(.white)
                    .focused($focusedField, equals: .mileage)

                Text(store.distanceUnit.rawValue)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )

            if let lastMileage = store.lastMileage {
                Text("Last mileage: \(lastMileage.formatted()) \(store.distanceUnit.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    private var saveButton: some View {
        Button {
            saveExpense()
        } label: {
            HStack {
                Image(systemName: isEditing ? "checkmark.circle.fill" : "plus.circle.fill")
                Text(isEditing ? "Save" : "Add Expense")
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isValid ?
                        LinearGradient(
                            colors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: isValid ? Color(hex: "4ECDC4").opacity(0.4) : .clear, radius: 10, y: 5)
            )
        }
        .disabled(!isValid)
    }

    private var deleteButton: some View {
        Button {
            if let expense = editingExpense {
                store.deleteExpense(expense)
                dismiss()
            }
        } label: {
            HStack {
                Image(systemName: "trash.fill")
                Text("Delete Expense")
                    .fontWeight(.bold)
            }
            .foregroundStyle(Color(hex: "FF6B6B"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "FF6B6B").opacity(0.15))
            )
        }
    }

    private func saveExpense() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else { return }

        let mileageValue = Int(mileage)

        if var expense = editingExpense {
            expense.category = selectedCategory
            expense.amount = amountValue
            expense.note = note
            expense.mileage = mileageValue
            expense.date = date
            store.updateExpense(expense)
        } else {
            let expense = Expense(
                category: selectedCategory,
                amount: amountValue,
                date: date,
                note: note,
                mileage: mileageValue
            )
            store.addExpense(expense)
        }

        dismiss()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM d, yyyy, HH:mm"
        return formatter.string(from: date)
    }
}

struct CategoryButton: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? category.gradient : LinearGradient(colors: [.white.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 56, height: 56)
                        .shadow(color: isSelected ? category.color.opacity(0.4) : .clear, radius: 8, y: 4)

                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                }

                Text(category.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(ExpenseStore())
}
