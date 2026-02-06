import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 20

    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
}

struct GradientCard<Content: View>: View {
    let gradient: LinearGradient
    let content: Content

    init(gradient: LinearGradient, @ViewBuilder content: () -> Content) {
        self.gradient = gradient
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(gradient)
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
            )
    }
}

struct NeumorphicCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "1A1A2E"))
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
                    .shadow(color: Color(hex: "2A2A4E").opacity(0.3), radius: 10, x: -5, y: -5)
            )
    }
}

struct AnimatedMeshBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "0F0F1A"),
                    Color(hex: "1A1A2E"),
                    Color(hex: "16213E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geometry in
                ForEach(0..<5) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    gradientColor(for: index).opacity(0.3),
                                    gradientColor(for: index).opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .offset(
                            x: animate ? position(for: index, in: geometry.size).x + 30 : position(for: index, in: geometry.size).x,
                            y: animate ? position(for: index, in: geometry.size).y + 30 : position(for: index, in: geometry.size).y
                        )
                        .animation(
                            Animation.easeInOut(duration: Double(index) + 4)
                                .repeatForever(autoreverses: true),
                            value: animate
                        )
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }

    private func gradientColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(hex: "FF6B6B"),
            Color(hex: "4ECDC4"),
            Color(hex: "FFE66D"),
            Color(hex: "95E1D3"),
            Color(hex: "DDA0DD")
        ]
        return colors[index % colors.count]
    }

    private func position(for index: Int, in size: CGSize) -> CGPoint {
        let positions: [CGPoint] = [
            CGPoint(x: -100, y: -100),
            CGPoint(x: size.width - 100, y: 100),
            CGPoint(x: 50, y: size.height - 200),
            CGPoint(x: size.width - 150, y: size.height - 100),
            CGPoint(x: size.width / 2 - 100, y: size.height / 2)
        ]
        return positions[index % positions.count]
    }
}

#Preview {
    ZStack {
        AnimatedMeshBackground()
        VStack(spacing: 20) {
            GlassCard {
                Text("Glass Card")
                    .foregroundStyle(.white)
            }

            GradientCard(gradient: ExpenseCategory.fuel.gradient) {
                Text("Gradient Card")
                    .foregroundStyle(.white)
            }

            NeumorphicCard {
                Text("Neumorphic Card")
                    .foregroundStyle(.white)
            }
        }
        .padding()
    }
}
