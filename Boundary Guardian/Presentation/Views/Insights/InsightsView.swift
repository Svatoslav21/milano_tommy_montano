// MARK: - InsightsView.swift
// Boundary Guardian
// Analytics screen

import SwiftUI
import Charts
import CoreData

// MARK: - Insights View
struct InsightsView: View {
    @State private var viewModel = InsightsViewModel()
    
    private var chartTitle: String {
        switch viewModel.selectedPeriod {
        case .week:
            return "Progress by Day"
        case .month:
            return "Progress by Week"
        case .quarter, .year, .allTime:
            return "Progress by Month"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(AppColors.primaryBlue)
                        .scaleEffect(1.5)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppSpacing.lg) {
                            // Period Selector
                            periodSelector
                            
                            // Main Stats Card
                            mainStatsCard
                            
                            // Chart
                            chartSection
                            
                            // Top Performers
                            if !viewModel.topPerformers.isEmpty {
                                topPerformersSection
                            }
                            
                            // Needs Attention
                            if !viewModel.needsAttention.isEmpty {
                                needsAttentionSection
                            }
                            
                            Spacer(minLength: 100)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Insights")
            .toolbarBackground(AppColors.deepNavy, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                viewModel.loadData()
            }
            .refreshable {
                viewModel.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: .dataDidReset)) { _ in
                viewModel.clearData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.refresh()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedPeriod)
            .errorAlert(viewModel.errorState)
        }
    }
    
    // MARK: - Period Selector
    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(StatisticsPeriod.allCases) { period in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.setPeriod(period)
                        }
                    } label: {
                        Text(period.rawValue)
                            .font(AppTypography.caption())
                            .foregroundStyle(viewModel.selectedPeriod == period ? AppColors.deepNavy : AppColors.metallicSilver)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedPeriod == period ? AppColors.primaryBlue : Color.white.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Main Stats Card
    private var mainStatsCard: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Boundary Strength • \(viewModel.selectedPeriod.rawValue)")
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.mutedGray)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(viewModel.complianceRate))")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.primaryBlue)
                            .contentTransition(.numericText())
                        
                        Text("%")
                            .font(AppTypography.title2())
                            .foregroundStyle(AppColors.primaryBlue.opacity(0.7))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text(viewModel.trendText)
                    }
                    .font(AppTypography.bodyBold())
                    .foregroundStyle(viewModel.trendColor)
                    
                    Text("vs previous period")
                        .font(AppTypography.caption2())
                        .foregroundStyle(AppColors.mutedGray)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack {
                QuickStatItem(
                    title: "Kept",
                    value: "\(viewModel.complianceStatistics?.keptCount ?? 0)",
                    color: AppColors.protectiveEmerald
                )
                
                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.1))
                
                QuickStatItem(
                    title: "Breached",
                    value: "\(viewModel.complianceStatistics?.breachedCount ?? 0)",
                    color: AppColors.breachRed
                )
                
                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.1))
                
                QuickStatItem(
                    title: "Total",
                    value: "\(viewModel.complianceStatistics?.totalEvents ?? 0)",
                    color: AppColors.metallicSilver
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColors.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(AppColors.primaryBlue.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(chartTitle)
                .font(AppTypography.title3())
                .foregroundStyle(AppColors.softWhite)
            
            if viewModel.monthlyData.isEmpty {
                // Empty state for chart
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.mutedGray)
                    Text("Нет данных")
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.mutedGray)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                Chart(viewModel.monthlyData) { month in
                    BarMark(
                        x: .value("Month", month.monthName),
                        y: .value("Rate", month.complianceRate)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.primaryBlue.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(AppColors.mutedGray)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(AppColors.mutedGray)
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColors.cardGradient)
        )
    }
    
    // MARK: - Top Performers
    private var topPerformersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(AppColors.accentOrange)
                Text("Top Boundaries")
                    .font(AppTypography.title3())
                    .foregroundStyle(AppColors.softWhite)
            }
            
            ForEach(viewModel.topPerformers) { boundary in
                PerformanceRow(boundary: boundary, color: AppColors.protectiveEmerald)
            }
        }
    }
    
    // MARK: - Needs Attention
    private var needsAttentionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(AppColors.breachRed)
                Text("Needs Attention")
                    .font(AppTypography.title3())
                    .foregroundStyle(AppColors.softWhite)
            }
            
            ForEach(viewModel.needsAttention) { boundary in
                PerformanceRow(boundary: boundary, color: AppColors.breachRed)
            }
        }
    }
}

// MARK: - Quick Stat Item
struct QuickStatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
            
            Text(title)
                .font(AppTypography.caption2())
                .foregroundStyle(AppColors.mutedGray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Performance Row
struct PerformanceRow: View {
    let boundary: BoundaryRankingData
    let color: Color
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: boundary.complianceRate / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(boundary.complianceRate))%")
                    .font(AppTypography.caption2())
                    .foregroundStyle(color)
            }
            .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(boundary.title)
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.softWhite)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(Color.white.opacity(0.03))
        )
    }
}

// MARK: - Preview
#Preview("Insights") {
    InsightsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
