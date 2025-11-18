//
//  DashboardView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var levelSystem: LevelSystem
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var sessionManager: SessionManager
    @AppStorage("dashboardDataSeeded") private var dataSeeded = false
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showInsights = true
    @State private var studyHistory: [StudySession] = []
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    dashboardHeader
                        .padding(.horizontal)
                    
                    statsGrid
                        .padding(.horizontal)
                    
                    timeRangeSelector
                        .padding(.horizontal)
                    
                    productivityChart
                        .padding(.horizontal)
                    
                    activityHeatmap
                        .padding(.horizontal)
                    
                    if showInsights {
                        insightsSection
                            .padding(.horizontal)
                    }
                    
                    bestTimeSection
                        .padding(.horizontal)
                }
                .padding(.vertical)
                .padding(.bottom, 100)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                loadStudyHistory()
                seedDataIfNeeded()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ReloadDashboard"))) { _ in
                loadStudyHistory()
            }
        }
    }
    
    // MARK: - Setup & Data Loading
    
    private func seedDataIfNeeded() {
        guard !dataSeeded else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        for daysAgo in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            
            if Int.random(in: 0...10) > 3 {
                let sessionCount = Int.random(in: 1...4)
                for _ in 0..<sessionCount {
                    let duration = [25, 50, 90].randomElement()!
                    let session = StudySession(
                        id: UUID(),
                        duration: TimeInterval(duration * 60),
                        type: "Pomodoro",
                        date: date
                    )
                    studyHistory.append(session)
                }
            }
        }
        
        if let encoded = try? JSONEncoder().encode(studyHistory) {
            UserDefaults.standard.set(encoded, forKey: "study_sessions")
        }
        
        dataSeeded = true
        print("✅ Dados de exemplo populados")
    }
    
    private func loadStudyHistory() {
        if let data = UserDefaults.standard.data(forKey: "study_sessions"),
           let decoded = try? JSONDecoder().decode([StudySession].self, from: data) {
            studyHistory = decoded
        }
    }
    
    // MARK: - Header
    
    private var dashboardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .font(AppTypography.largeTitle)
                
                Text("Acompanhe seu progresso")
                    .font(AppTypography.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            NavigationLink {
                LevelDetailsView()
                    .environmentObject(levelSystem)
            } label: {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Text("\(levelSystem.currentLevel)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nível \(levelSystem.currentLevel)")
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text(levelSystem.title)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.cardBackground)
                )
            }
        }
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                icon: "flame.fill",
                value: "\(streakManager.currentStreak)",
                label: "Dias",
                color: .orange,
                trend: getTrendForStreak()
            )
            
            StatCard(
                icon: "checkmark.circle.fill",
                value: "\(taskStore.completedTasksCount)",
                label: "Tarefas",
                color: .green,
                trend: getTrendForTasks()
            )
            
            StatCard(
                icon: "clock.fill",
                value: String(format: "%.1fh", getTotalHours()),
                label: "Horas",
                color: .blue,
                trend: getTrendForHours()
            )
        }
    }
    
    // MARK: - Time Range Selector
    
    private var timeRangeSelector: some View {
        HStack(spacing: 12) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTimeRange = range
                    }
                } label: {
                    Text(range.title)
                        .font(.system(size: 14, weight: selectedTimeRange == range ? .semibold : .medium))
                        .foregroundStyle(selectedTimeRange == range ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedTimeRange == range ? AppColors.primaryGradient : LinearGradient(colors: [AppColors.cardBackground], startPoint: .leading, endPoint: .trailing))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Productivity Chart
    
    private var productivityChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Produtividade \(selectedTimeRange.title)")
                .font(AppTypography.title3)
            
            chartContent
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 15, y: 8)
        )
    }
    
    @ViewBuilder
    private var chartContent: some View {
        let data = getChartData()
        let isScrollable = selectedTimeRange == .year
        let chartWidth = isScrollable ? max(CGFloat(data.count) * 60, 700) : nil
        
        Group {
            if isScrollable {
                ScrollView(.horizontal, showsIndicators: false) {
                    makeChart(data: data)
                        .frame(width: chartWidth, height: 200)
                }
            } else {
                makeChart(data: data)
                    .frame(height: 200)
            }
        }
    }
    
    @ViewBuilder
    private func makeChart(data: [ChartDataPoint]) -> some View {
        Chart {
            ForEach(data) { dataPoint in
                BarMark(
                    x: .value("Período", dataPoint.label),
                    y: .value("Horas", dataPoint.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.primary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(8)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let hours = value.as(Double.self) {
                        Text("\(Int(hours))h")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.2))
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Activity Heatmap
    
    private var activityHeatmap: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Atividade Mensal")
                    .font(AppTypography.title3)
                
                Spacer()
                
                Text("30 dias")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(0..<28, id: \.self) { index in
                    let intensity = getIntensityForDay(daysAgo: 27 - index)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.primary.opacity(intensity))
                        .frame(height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(AppColors.primary.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            
            HStack {
                Text("Menos")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    ForEach([0.2, 0.4, 0.6, 0.8, 1.0], id: \.self) { intensity in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(AppColors.primary.opacity(intensity))
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text("Mais")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 15, y: 8)
        )
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Insights")
                    .font(AppTypography.title3)
            }
            
            VStack(spacing: 12) {
                ForEach(generateInsights(), id: \.text) { insight in
                    InsightCard(
                        icon: insight.icon,
                        text: insight.text,
                        color: insight.color
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 15, y: 8)
        )
    }
    
    // MARK: - Best Time Section
    
    private var bestTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Seu Ritmo Diário")
                .font(AppTypography.title3)
            
            Chart {
                ForEach(getHourlyData()) { dataPoint in
                    LineMark(
                        x: .value("Hora", dataPoint.label),
                        y: .value("Foco", dataPoint.value)
                    )
                    .foregroundStyle(AppColors.secondary)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Hora", dataPoint.label),
                        y: .value("Foco", dataPoint.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.secondary.opacity(0.3), AppColors.secondary.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 180)
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .stride(by: 4)) { value in
                    AxisValueLabel {
                        if let hour = value.as(String.self) {
                            Text(hour)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 15, y: 8)
        )
    }
    
    // MARK: - Helper Functions
    
    func getTotalHours() -> Double {
        let calendar = Calendar.current
        let filtered = studyHistory.filter { session in
            calendar.isDate(session.date, equalTo: Date(), toGranularity: selectedTimeRange.granularity)
        }
        let totalSeconds = filtered.reduce(0) { $0 + $1.duration }
        return totalSeconds / 3600.0
    }
    
    func getChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .week:
            return (0..<7).reversed().map { daysAgo in
                guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) else {
                    return ChartDataPoint(label: "", value: 0)
                }
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "pt_BR")
                let dayName = formatter.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
                let hours = getHoursForDate(date)
                return ChartDataPoint(label: String(dayName.prefix(3)).capitalized, value: hours)
            }
            
        case .month:
            let weeksToShow = 4
            return (0..<weeksToShow).reversed().map { weeksAgo in
                let startOfWeek = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: now) ?? now
                
                var weekTotal: Double = 0
                for dayOffset in 0..<7 {
                    if let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                        weekTotal += getHoursForDate(dayDate)
                    }
                }
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "pt_BR")
                formatter.dateFormat = "dd/MM"
                let weekLabel = formatter.string(from: startOfWeek)
                
                return ChartDataPoint(label: weekLabel, value: weekTotal)
            }
            
        case .year:
            return (0..<12).reversed().map { monthsAgo in
                guard let date = calendar.date(byAdding: .month, value: -monthsAgo, to: now) else {
                    return ChartDataPoint(label: "", value: 0)
                }
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "pt_BR")
                formatter.dateFormat = "MMM"
                let monthName = formatter.string(from: date)
                let hours = getHoursForMonth(date)
                return ChartDataPoint(label: monthName.capitalized, value: hours)
            }
        }
    }
    
    func getHoursForDate(_ date: Date) -> Double {
        let calendar = Calendar.current
        let sessions = studyHistory.filter { calendar.isDate($0.date, inSameDayAs: date) }
        let totalSeconds = sessions.reduce(0) { $0 + $1.duration }
        return totalSeconds / 3600.0
    }
    
    func getHoursForMonth(_ date: Date) -> Double {
        let calendar = Calendar.current
        let sessions = studyHistory.filter {
            calendar.isDate($0.date, equalTo: date, toGranularity: .month)
        }
        let totalSeconds = sessions.reduce(0) { $0 + $1.duration }
        return totalSeconds / 3600.0
    }
    
    func getIntensityForDay(daysAgo: Int) -> Double {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) else { return 0 }
        let hours = getHoursForDate(date)
        return min(hours / 6.0, 1.0)
    }
    
    func getHourlyData() -> [ChartDataPoint] {
        var hourlyTotals: [Int: Double] = [:]
        
        for session in studyHistory {
            let hour = Calendar.current.component(.hour, from: session.date)
            hourlyTotals[hour, default: 0] += session.duration / 3600.0
        }
        
        return (8...22).map { hour in
            ChartDataPoint(
                label: "\(hour)h",
                value: hourlyTotals[hour] ?? 0
            )
        }
    }
    
    func getTrendForStreak() -> StatCard.Trend? {
        return streakManager.currentStreak > 0 ? .up(10) : nil
    }
    
    func getTrendForTasks() -> StatCard.Trend? {
        let completed = taskStore.completedTasksCount
        return completed > 0 ? .up(12) : nil
    }
    
    func getTrendForHours() -> StatCard.Trend? {
        let hours = getTotalHours()
        return hours > 0 ? .up(8) : nil
    }
    
    func generateInsights() -> [(icon: String, text: String, color: Color)] {
        var insights: [(String, String, Color)] = []
        
        let totalHours = getTotalHours()
        if totalHours > 10 {
            insights.append(("chart.line.uptrend.xyaxis", "Você estudou \(String(format: "%.1f", totalHours))h esta semana! Continue assim! 🎉", .green))
        }
        
        if streakManager.currentStreak >= 3 {
            insights.append(("flame.fill", "Sequência de \(streakManager.currentStreak) dias! Você está no fogo! 🔥", .orange))
        }
        
        let pendingTasks = taskStore.tasks.filter { !$0.isCompleted }.count
        if pendingTasks > 0 && pendingTasks <= 3 {
            insights.append(("target", "Faltam apenas \(pendingTasks) tarefas para bater sua meta!", .orange))
        }
        
        if insights.isEmpty {
            insights.append(("calendar.badge.clock", "Comece sua jornada de estudos hoje!", .blue))
        }
        
        return insights
    }
}

extension TimeRange {
    var granularity: Calendar.Component {
        switch self {
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let trend: Trend?
    
    enum Trend {
        case up(Int)
        case down(Int)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let trend = trend {
                HStack(spacing: 4) {
                    Image(systemName: trend.isPositive ? "arrow.up" : "arrow.down")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(trend.percentage)%")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(trend.isPositive ? .green : .red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill((trend.isPositive ? Color.green : Color.red).opacity(0.15))
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
}

extension StatCard.Trend {
    var isPositive: Bool {
        switch self {
        case .up: return true
        case .down: return false
        }
    }
    
    var percentage: Int {
        switch self {
        case .up(let value), .down(let value): return value
        }
    }
}

struct InsightCard: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

enum TimeRange: CaseIterable {
    case week, month, year
    
    var title: String {
        switch self {
        case .week: return "Semana"
        case .month: return "Mês"
        case .year: return "Ano"
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

#Preview {
    DashboardView()
        .environmentObject(StreakManager())
        .environmentObject(LevelSystem())
        .environmentObject(TaskStore())
        .environmentObject(SessionManager())
}
