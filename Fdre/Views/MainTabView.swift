import SwiftUI

struct MainTabView: View {
    @StateObject private var store = ExpenseStore()
    @State private var selectedTab = 0
    @State private var showingAddExpense = false

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color(hex: "1A1A2E").opacity(0.95))

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "4ECDC4"))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: "4ECDC4"))]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .environmentObject(store)
                    .tag(0)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                ExpenseListView()
                    .environmentObject(store)
                    .tag(1)
                    .tabItem {
                        Label("Expenses", systemImage: "list.bullet")
                    }

                Color.clear
                    .tag(2)
                    .tabItem {
                        Label("", systemImage: "")
                    }

                StatisticsView()
                    .environmentObject(store)
                    .tag(3)
                    .tabItem {
                        Label("Analytics", systemImage: "chart.pie.fill")
                    }

                SettingsView()
                    .environmentObject(store)
                    .tag(4)
                    .tabItem {
                        Label("More", systemImage: "ellipsis")
                    }
            }
            .tint(Color(hex: "4ECDC4"))

            floatingAddButton
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
                .environmentObject(store)
        }
    }

    private var floatingAddButton: some View {
        Button {
            showingAddExpense = true
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color(hex: "FF6B6B").opacity(0.5), radius: 10, y: 5)

                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
        }
        .offset(y: -25)
    }
}

#Preview {
    MainTabView()
}
