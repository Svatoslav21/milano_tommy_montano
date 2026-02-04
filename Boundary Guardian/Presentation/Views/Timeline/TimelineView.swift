// MARK: - TimelineView.swift
// Boundary Guardian
// Event timeline screen

import SwiftUI
import CoreData

// MARK: - Timeline View
struct TimelineView: View {
    @State private var viewModel = TimelineViewModel()
    @State private var selectedFilter: TimelineFilter = .all
    
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
                    VStack(spacing: 0) {
                        // Filter Tabs
                        filterTabs
                        
                        // Month Stats
                        monthStatsCard
                        
                        // Timeline
                        if viewModel.filteredEvents.isEmpty {
                            emptyState
                        } else {
                            timelineList
                        }
                    }
                }
            }
            .navigationTitle("Timeline")
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
            .errorAlert(viewModel.errorState)
        }
    }
    
    // MARK: - Filter Tabs
    private var filterTabs: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(TimelineFilter.allCases) { filter in
                Button {
                    selectedFilter = filter
                    viewModel.setFilter(filter)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: filter.icon)
                            .font(.system(size: 12))
                        Text(filter.rawValue)
                            .font(AppTypography.caption())
                    }
                    .foregroundStyle(selectedFilter == filter ? AppColors.deepNavy : filter.color)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(selectedFilter == filter ? filter.color : filter.color.opacity(0.15))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, AppSpacing.sm)
    }
    
    // MARK: - Month Stats Card
    private var monthStatsCard: some View {
        HStack(spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: 4) {
                Text("This Month")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.mutedGray)
                
                HStack(spacing: AppSpacing.md) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.protectiveEmerald)
                        Text("\(viewModel.monthStats.kept)")
                            .font(AppTypography.bodyBold())
                            .foregroundStyle(AppColors.softWhite)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColors.breachRed)
                        Text("\(viewModel.monthStats.breached)")
                            .font(AppTypography.bodyBold())
                            .foregroundStyle(AppColors.softWhite)
                    }
                }
            }
            
            Spacer()
            
            let total = viewModel.monthStats.kept + viewModel.monthStats.breached
            let rate = total > 0 ? Int(Double(viewModel.monthStats.kept) / Double(total) * 100) : 100
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(rate)%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primaryBlue)
                
                Text("success")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.mutedGray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColors.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .padding(.bottom, AppSpacing.sm)
    }
    
    // MARK: - Timeline List
    private var timelineList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.filteredEvents) { dayEvents in
                    Section {
                        ForEach(dayEvents.events) { event in
                            TimelineEventRow(event: event, isLast: event.id == dayEvents.events.last?.id)
                        }
                    } header: {
                        DaySectionHeader(dayEvents: dayEvents)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.mutedGray)
            
            Text("No Events")
                .font(AppTypography.title3())
                .foregroundStyle(AppColors.softWhite)
            
            Text("Events will appear when you\nstart logging boundary compliance")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.mutedGray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Day Section Header
struct DaySectionHeader: View {
    let dayEvents: DayEvents
    
    var body: some View {
        HStack {
            Text(dayEvents.dateFormatted)
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.metallicSilver)
            
            Spacer()
            
            HStack(spacing: 8) {
                if dayEvents.keptCount > 0 {
                    HStack(spacing: 2) {
                        Circle()
                            .fill(AppColors.protectiveEmerald)
                            .frame(width: 8, height: 8)
                        Text("\(dayEvents.keptCount)")
                            .font(AppTypography.caption2())
                            .foregroundStyle(AppColors.protectiveEmerald)
                    }
                }
                
                if dayEvents.breachedCount > 0 {
                    HStack(spacing: 2) {
                        Circle()
                            .fill(AppColors.breachRed)
                            .frame(width: 8, height: 8)
                        Text("\(dayEvents.breachedCount)")
                            .font(AppTypography.caption2())
                            .foregroundStyle(AppColors.breachRed)
                    }
                }
            }
        }
        .padding(.vertical, AppSpacing.sm)
        .padding(.horizontal, AppSpacing.xs)
        .background(AppColors.deepNavy.opacity(0.95))
    }
}

// MARK: - Timeline Event Row
struct TimelineEventRow: View {
    let event: ComplianceEventEntity
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            VStack(spacing: 0) {
                Circle()
                    .fill(event.color)
                    .frame(width: 12, height: 12)
                    .shadow(color: event.color.opacity(0.5), radius: 4)
                
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [event.color.opacity(0.5), event.color.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: event.icon)
                        .foregroundStyle(event.color)
                    
                    Text(event.boundary.title)
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.softWhite)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(event.date.time)
                        .font(AppTypography.caption2())
                        .foregroundStyle(AppColors.mutedGray)
                }
                
                if let notes = event.notes, !notes.isEmpty {
                    Text(notes)
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.mutedGray)
                        .lineLimit(2)
                }
            }
            .padding(.bottom, AppSpacing.md)
        }
    }
}

// MARK: - Preview
#Preview("Timeline") {
    TimelineView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
