import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: ExpenseStore

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        profileCard
                        unitsSection
                        statisticsSummary
                        aboutSection

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var profileCard: some View {
        GradientCard(
            gradient: LinearGradient(
                colors: [Color(hex: "834D9B"), Color(hex: "D04ED6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 70, height: 70)

                    Image(systemName: "car.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("My Vehicle")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    if let mileage = store.lastMileage {
                        Text("Mileage: \(mileage.formatted()) \(store.distanceUnit.rawValue)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Text("Entries: \(store.expenses.count)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()
            }
        }
    }

    private var statisticsSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary")
                .font(.title3.bold())
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SummaryCard(
                    title: "Total Spent",
                    value: formatCurrency(totalSpent),
                    icon: "creditcard.fill",
                    color: Color(hex: "FF6B6B")
                )

                SummaryCard(
                    title: "Days Tracking",
                    value: "\(store.daysSinceFirstExpense)",
                    icon: "calendar",
                    color: Color(hex: "4ECDC4")
                )

                SummaryCard(
                    title: "Entries",
                    value: "\(store.expenses.count)",
                    icon: "doc.text.fill",
                    color: Color(hex: "FFE66D")
                )

                SummaryCard(
                    title: "Categories",
                    value: "\(usedCategories)",
                    icon: "square.grid.2x2.fill",
                    color: Color(hex: "DDA0DD")
                )
            }
        }
    }

    private var unitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Units")
                .font(.title3.bold())
                .foregroundStyle(.white)

            GlassCard(padding: 16) {
                HStack {
                    Image(systemName: "speedometer")
                        .font(.title3)
                        .foregroundStyle(Color(hex: "4ECDC4"))

                    Text("Distance")
                        .font(.body)
                        .foregroundStyle(.white)

                    Spacer()

                    Picker("", selection: $store.distanceUnit) {
                        ForEach(DistanceUnit.allCases, id: \.self) { unit in
                            Text(unit.fullName).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.title3.bold())
                .foregroundStyle(.white)

            GlassCard {
                VStack(spacing: 16) {
                    Image(systemName: "car.side.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("AutoExpenses")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("Smart expense tracking for your vehicle. Track fuel, maintenance, repairs, and other costs.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var totalSpent: Double {
        store.expenses.reduce(0) { $0 + $1.amount }
    }

    private var usedCategories: Int {
        Set(store.expenses.map { $0.category }).count
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

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        GlassCard(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Text(value)
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ExpenseStore())
}
