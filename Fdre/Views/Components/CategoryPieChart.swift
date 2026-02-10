import SwiftUI

struct CategoryPieChart: View {
    let data: [(category: ExpenseCategory, amount: Double)]
    @State private var selectedSlice: ExpenseCategory?
    @State private var animationProgress: CGFloat = 0

    private var total: Double {
        data.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2 - 20

            ZStack {
                ForEach(Array(data.enumerated()), id: \.element.category) { index, item in
                    PieSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        innerRadius: radius * 0.55,
                        outerRadius: selectedSlice == item.category ? radius + 10 : radius
                    )
                    .fill(item.category.gradient)
                    .shadow(color: item.category.color.opacity(0.5), radius: selectedSlice == item.category ? 10 : 5)
                    .scaleEffect(animationProgress)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1), value: animationProgress)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            if selectedSlice == item.category {
                                selectedSlice = nil
                            } else {
                                selectedSlice = item.category
                            }
                        }
                    }
                }

                VStack(spacing: 4) {
                    if let selected = selectedSlice,
                       let item = data.first(where: { $0.category == selected }) {
                        Image(systemName: selected.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(selected.color)

                        Text(selected.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        Text(formatCurrency(item.amount))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("\(Int(item.amount / total * 100))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "car.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)

                        Text("Total")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(formatCurrency(total))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: selectedSlice)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animationProgress = 1
            }
        }
    }

    private func startAngle(for index: Int) -> Angle {
        let precedingTotal = data.prefix(index).reduce(0) { $0 + $1.amount }
        return .degrees(precedingTotal / total * 360 - 90)
    }

    private func endAngle(for index: Int) -> Angle {
        let includingTotal = data.prefix(index + 1).reduce(0) { $0 + $1.amount }
        return .degrees(includingTotal / total * 360 - 90)
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

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadius: CGFloat
    var outerRadius: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(startAngle.degrees, endAngle.degrees) }
        set {
            startAngle = .degrees(newValue.first)
            endAngle = .degrees(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)

        var path = Path()

        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )

        path.closeSubpath()

        return path
    }
}

struct CategoryBarChart: View {
    let data: [(month: String, amount: Double)]
    @State private var animationProgress: CGFloat = 0

    private var maxAmount: Double {
        data.map { $0.amount }.max() ?? 1
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: max(20, (geometry.size.height - 40) * CGFloat(item.amount / maxAmount) * animationProgress))
                            .shadow(color: Color(hex: "4ECDC4").opacity(0.3), radius: 5, y: 3)

                        Text(item.month)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.05), value: animationProgress)
                }
            }
        }
        .onAppear {
            withAnimation {
                animationProgress = 1
            }
        }
    }
}

#Preview {
    ZStack {
        AnimatedMeshBackground()
        VStack {
            GlassCard {
                CategoryPieChart(data: [
                    (.fuel, 9600),
                    (.wash, 2000),
                    (.oil, 5500),
                    (.repair, 20500),
                    (.parking, 500),
                    (.insurance, 35000)
                ])
                .frame(height: 250)
            }
            .padding()
        }
    }
}
