//
//  ProgressView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct ProgressStatsView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    
    private var workouts: [Workout] {
        guard let user = authManager.currentUser else { return [] }
        return (user.workouts?.allObjects as? [Workout])?.sorted {
            ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast)
        } ?? []
    }
    
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedExercise: Exercise?
    
    enum TimePeriod: String, CaseIterable {
        case week = "Неделя"
        case month = "Месяц"
        case year = "Год"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Селектор периода
                    Picker("Период", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, Constants.Layout.padding)
                    
                    // KPI
                    GeneralStatsView(workouts: Array(workouts), period: selectedPeriod)
                    
                    // Категории
                    CategoryBreakdownView(workouts: Array(workouts), period: selectedPeriod)
                    
                    // Топ упражнений
                    ExerciseStatsView(workouts: Array(workouts), period: selectedPeriod)
                    
                    // График прогресса (линейный)
                    ProgressChartView(workouts: Array(workouts), period: selectedPeriod)
                    
                    // Личные рекорды (PR)
                    PRListView(workouts: Array(workouts), period: selectedPeriod, authManager: authManager)
                    
                    // Тепловая карта активности
                    ActivityHeatmapView(workouts: Array(workouts), period: selectedPeriod)
                }
                .padding(Constants.Layout.padding)
            }
            .navigationTitle("Прогресс")
        }
    }
}

struct GeneralStatsView: View {
    let workouts: [Workout]
    let period: ProgressStatsView.TimePeriod
    
    private var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return workouts.filter { $0.date ?? Date.distantPast >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return workouts.filter { $0.date ?? Date.distantPast >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return workouts.filter { $0.date ?? Date.distantPast >= yearAgo }
        }
    }
    
    private var totalStats: (sets: Int, reps: Int, weight: Double, workouts: Int,
                             setsDelta: Int, repsDelta: Int, weightDelta: Double) {
        var totalSets = 0
        var totalReps = 0
        var totalWeight = 0.0
        
        for workout in filteredWorkouts {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    totalSets += Int(detail.sets)
                    totalReps += Int(detail.reps) * Int(detail.sets)
                    totalWeight += detail.weight * Double(detail.sets) * Double(detail.reps)
                }
            }
        }

        // Подсчет прошлый период для индикаторов
        let calendar = Calendar.current
        let now = Date()
        let previousRange: [Workout]
        switch period {
        case .week:
            let startPrev = calendar.date(byAdding: .weekOfYear, value: -2, to: now) ?? now
            let endPrev = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            previousRange = workouts.filter { ($0.date ?? .distantPast) >= startPrev && ($0.date ?? .distantPast) < endPrev }
        case .month:
            let startPrev = calendar.date(byAdding: .month, value: -2, to: now) ?? now
            let endPrev = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            previousRange = workouts.filter { ($0.date ?? .distantPast) >= startPrev && ($0.date ?? .distantPast) < endPrev }
        case .year:
            let startPrev = calendar.date(byAdding: .year, value: -2, to: now) ?? now
            let endPrev = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            previousRange = workouts.filter { ($0.date ?? .distantPast) >= startPrev && ($0.date ?? .distantPast) < endPrev }
        }

        var prevSets = 0, prevReps = 0, prevWeight = 0.0
        for workout in previousRange {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    prevSets += Int(detail.sets)
                    prevReps += Int(detail.reps) * Int(detail.sets)
                    prevWeight += detail.weight * Double(detail.sets) * Double(detail.reps)
                }
            }
        }

        return (totalSets, totalReps, totalWeight, filteredWorkouts.count,
                totalSets - prevSets, totalReps - prevReps, totalWeight - prevWeight)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Общая статистика")
                .font(.headline)
            let stats = totalStats
            let activeDays = Set(filteredWorkouts.compactMap { Calendar.current.startOfDay(for: $0.date ?? Date()) }).count
            let items: [(title: String, value: String, color: Color, deltaView: AnyView?)] = [
                ("Тренировок", "\(stats.workouts)", Constants.Colors.primary, nil),
                ("Подходов", "\(stats.sets)", Constants.Colors.success, AnyView(DeltaTag(delta: stats.setsDelta))),
                ("Повторений", "\(stats.reps)", Constants.Colors.warning, AnyView(DeltaTag(delta: stats.repsDelta))),
                ("Общий вес (кг)", formatNumber(stats.weight), Constants.Colors.danger, AnyView(DeltaTagDouble(delta: stats.weightDelta)))
            ]
            LazyVGrid(columns: [GridItem(.flexible(), spacing: Constants.Layout.padding), GridItem(.flexible())], spacing: Constants.Layout.padding) {
                ForEach(0..<items.count, id: \.self) { i in
                    let item = items[i]
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.value)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(item.color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                        Text(item.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let delta = item.deltaView { delta }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 80)  // Fixed height for uniform shape
                    .padding(Constants.Layout.padding)
                    .background(Color(.systemBackground))
                    .cornerRadius(Constants.Layout.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                }
            }
        }
        .padding(Constants.Layout.padding)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Constants.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}

struct ExerciseStatsView: View {
    let workouts: [Workout]
    let period: ProgressStatsView.TimePeriod
    
    private var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return workouts.filter { $0.date ?? Date.distantPast >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return workouts.filter { $0.date ?? Date.distantPast >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return workouts.filter { $0.date ?? Date.distantPast >= yearAgo }
        }
    }
    
    private var exerciseStats: [(exercise: Exercise, maxWeight: Double, totalSets: Int)] {
        var exerciseData: [UUID: (exercise: Exercise, maxWeight: Double, totalSets: Int)] = [:]
        
        for workout in filteredWorkouts {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    guard let exercise = detail.exercise else { continue }
                    
                    if let existing = exerciseData[exercise.id ?? UUID()] {
                        exerciseData[exercise.id ?? UUID()] = (
                            exercise: exercise,
                            maxWeight: max(existing.maxWeight, detail.weight),
                            totalSets: existing.totalSets + Int(detail.sets)
                        )
                    } else {
                        exerciseData[exercise.id ?? UUID()] = (
                            exercise: exercise,
                            maxWeight: detail.weight,
                            totalSets: Int(detail.sets)
                        )
                    }
                }
            }
        }
        
        return exerciseData.values.sorted { $0.maxWeight > $1.maxWeight }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Топ упражнений")
                .font(.headline)
            
            if exerciseStats.isEmpty {
                Text("Нет данных за выбранный период")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(Array(exerciseStats.prefix(5)), id: \.exercise.id) { stat in
                    HStack {
                        if let imageData = stat.exercise.image,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: Constants.Layout.smallImageSize, height: Constants.Layout.smallImageSize)
                                .clipped()
                                .cornerRadius(Constants.Layout.smallCornerRadius)
                        } else {
                            RoundedRectangle(cornerRadius: Constants.Layout.smallCornerRadius)
                                .fill(Color(.systemGray5))
                                .frame(width: Constants.Layout.smallImageSize, height: Constants.Layout.smallImageSize)
                                .overlay(
                                    Image(systemName: "dumbbell")
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        VStack(alignment: .leading) {
                            Text(stat.exercise.name ?? "Без названия")
                                .font(.headline)
                            if let category = stat.exercise.category {
                                Text(category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(String(format: "%.1f", stat.maxWeight)) кг")
                                .font(.headline)
                                .foregroundColor(Constants.Colors.primary)
                            Text("\(stat.totalSets) подходов")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(Constants.Layout.padding)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Constants.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}

struct ProgressChartView: View {
    let workouts: [Workout]
    let period: ProgressStatsView.TimePeriod
    
    @State private var selectedDataPoint: (date: Date, weight: Double)?
    @State private var tooltipPosition: CGPoint = .zero
    
    private var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return workouts.filter { $0.date ?? Date.distantPast >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return workouts.filter { $0.date ?? Date.distantPast >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return workouts.filter { $0.date ?? Date.distantPast >= yearAgo }
        }
    }
    
    private var chartData: [(date: Date, weight: Double)] {
        let calendar = Calendar.current
        var dailyData: [Date: Double] = [:]
        
        for workout in filteredWorkouts {
            let day = calendar.startOfDay(for: workout.date ?? Date())
            var dayWeight = 0.0
            
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    dayWeight += detail.weight * Double(detail.sets) * Double(detail.reps)
                }
            }
            
            dailyData[day, default: 0] += dayWeight
        }
        
        return dailyData.map { (date: $0.key, weight: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    private var weekDays: [String] {
        ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("График прогресса")
                .font(.headline)
            
            if chartData.isEmpty {
                Text("Нет данных для отображения")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(spacing: 8) {
                    // Y-axis labels
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            let values = chartData.map { $0.weight }
                            let minV = values.min() ?? 0
                            let maxV = values.max() ?? 1
                            let range = max(maxV - minV, 1)
                            
                            ForEach([0, 1, 2, 3, 4], id: \.self) { i in
                                let value = minV + (range * Double(i) / 4)
                                Text(formatNumber(value))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(height: 20)
                            }
                        }
                        .frame(width: 50)
                        
                        // Chart area
                        GeometryReader { proxy in
                            let size = proxy.size
                            let values = chartData.map { $0.weight }
                            let minV = values.min() ?? 0
                            let maxV = values.max() ?? 1
                            let range = max(maxV - minV, 1)
                            let points: [CGPoint] = chartData.enumerated().map { idx, pair in
                                let x = size.width * CGFloat(Double(idx) / Double(max(chartData.count - 1, 1)))
                                let norm = (pair.weight - minV) / range
                                let y = size.height * (1 - CGFloat(norm))
                                return CGPoint(x: x, y: y)
                            }
                            
                            ZStack {
                                // Grid lines
                                ForEach(0..<5, id: \.self) { i in
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 0.5)
                                        .offset(y: size.height * CGFloat(i) / 4)
                                }
                                
                                // Area under the curve
                                Path { path in
                                    guard points.count > 0 else { return }
                                    
                                    let first = points[0]
                                    path.move(to: CGPoint(x: first.x, y: size.height))
                                    path.addLine(to: first)
                                    
                                    if points.count == 2 {
                                        path.addLine(to: points[1])
                                    } else if points.count > 2 {
                                        for i in 1..<points.count {
                                            let previousPoint = points[i-1]
                                            let currentPoint = points[i]
                                            
                                            let controlPoint1 = CGPoint(
                                                x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.3,
                                                y: previousPoint.y
                                            )
                                            let controlPoint2 = CGPoint(
                                                x: currentPoint.x - (currentPoint.x - previousPoint.x) * 0.3,
                                                y: currentPoint.y
                                            )
                                            
                                            path.addCurve(to: currentPoint, control1: controlPoint1, control2: controlPoint2)
                                        }
                                    }
                                    
                                    if let last = points.last {
                                        path.addLine(to: CGPoint(x: last.x, y: size.height))
                                    }
                                    path.closeSubpath()
                                }
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.3),
                                            Color.blue.opacity(0.1)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                
                                // Main line with smooth curves
                                Path { path in
                                    guard points.count > 1 else { return }
                                    
                                    path.move(to: points[0])
                                    
                                    if points.count == 2 {
                                        path.addLine(to: points[1])
                                    } else {
                                        for i in 1..<points.count {
                                            let previousPoint = points[i-1]
                                            let currentPoint = points[i]
                                            
                                            let controlPoint1 = CGPoint(
                                                x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.3,
                                                y: previousPoint.y
                                            )
                                            let controlPoint2 = CGPoint(
                                                x: currentPoint.x - (currentPoint.x - previousPoint.x) * 0.3,
                                                y: currentPoint.y
                                            )
                                            
                                            path.addCurve(to: currentPoint, control1: controlPoint1, control2: controlPoint2)
                                        }
                                    }
                                }
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                                
                                // Data points
                                ForEach(0..<points.count, id: \.self) { i in
                                    let point = points[i]
                                    let dataPoint = chartData[i]
                                    
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 8, height: 8)
                                        .position(point)
                                        .onTapGesture {
                                            selectedDataPoint = dataPoint
                                            tooltipPosition = CGPoint(
                                                x: point.x + 20,
                                                y: point.y - 20
                                            )
                                        }
                                }
                                
                                // Tooltip
                                if let selectedData = selectedDataPoint {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(dayOfWeek(for: selectedData.date))
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                        Text("weight: \(formatNumber(selectedData.weight))")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    .position(tooltipPosition)
                                }
                            }
                        }
                        .frame(height: 180)
                        .onTapGesture {
                            selectedDataPoint = nil
                        }
                    }
                    
                    // X-axis labels
                    HStack {
                        Spacer().frame(width: 50)
                        HStack {
                            ForEach(0..<weekDays.count, id: \.self) { i in
                                Text(weekDays[i])
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
        .padding(Constants.Layout.padding)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Constants.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
    }
    
    private func dayOfWeek(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatNumber(_ value: Double) -> String {
        if value >= 1000000 {
            return String(format: "%.1fM", value / 1000000)
        } else if value >= 1000 {
            return String(format: "%.0fK", value / 1000)
        } else {
            return String(format: "%.0f", value)
        }
    }
}

// MARK: - Delta Tags
struct DeltaTag: View {
    let delta: Int
    var body: some View {
        let positive = delta > 0
        let color: Color = delta == 0 ? .secondary : (positive ? .green : .red)
        Text(delta == 0 ? "0" : String(format: "%@%d", positive ? "+" : "", delta))
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

struct DeltaTagDouble: View {
    let delta: Double
    var body: some View {
        let positive = delta > 0
        let color: Color = delta == 0 ? .secondary : (positive ? .green : .red)
        Text(delta == 0 ? "0" : String(format: "%@%.0f", positive ? "+" : "", delta))
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

// MARK: - Category Breakdown
struct CategoryBreakdownView: View {
    let workouts: [Workout]
    let period: ProgressStatsView.TimePeriod
    
    private var items: [(category: String, volume: Double, share: Double)] {
        let filtered = workouts.filterBy(period: period)
        var totals: [String: Double] = [:]
        var totalVolume: Double = 0
        for workout in filtered {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for d in details {
                    let cat = d.exercise?.category ?? "Прочее"
                    let v = d.weight * Double(d.sets) * Double(d.reps)
                    totals[cat, default: 0] += v
                    totalVolume += v
                }
            }
        }
        guard totalVolume > 0 else { return [] }
        return totals.map { (key, value) in (key, value, value / totalVolume) }
            .sorted { $0.volume > $1.volume }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Распределение по категориям")
                .font(.headline)
            
            if items.isEmpty {
                Text("Нет данных для силового объема за период")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                let maxVolume = items.map { $0.volume }.max() ?? 1
                ForEach(items, id: \.category) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.category)
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "%.0f кг", item.volume))
                                .font(.subheadline)
                        }
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 12)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.categoryColor(for: item.category))
                                .frame(width: max(8, CGFloat(item.volume / maxVolume) * UIScreen.main.bounds.width * 0.6), height: 12)
                        }
                        Text(String(format: "%.0f%%", item.share * 100))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(Constants.Layout.padding)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Constants.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}

// MARK: - PR List
struct PRListView: View {
    let workouts: [Workout]
    let period: ProgressStatsView.TimePeriod
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var prManager = PersonalRecordManager.shared
    
    private enum ActiveSheet: Identifiable {
        case add
        case edit(PersonalRecord)
        
        var id: String {
            switch self {
            case .add:
                return "add"
            case .edit(let record):
                return record.id.uuidString
            }
        }
    }
    
    @State private var activeSheet: ActiveSheet?
    
    private var personalRecords: [PersonalRecord] {
        guard let userId = authManager.currentUser?.id?.uuidString else { return [] }
        return prManager.getRecords(for: userId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Личные рекорды")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    activeSheet = .add
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Constants.Colors.primary)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }
            
            if personalRecords.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "trophy")
                        .font(.system(size: 36, weight: .regular))
                        .foregroundColor(.secondary)
                    
                    Text("Нет личных рекордов")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Нажмите, чтобы добавить свой первый рекорд")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(personalRecords.sorted { $0.exerciseName < $1.exerciseName }) { record in
                        PersonalRecordRowView(record: record) {
                            activeSheet = .edit(record)
                        }
                    }
                }
            }
        }
        .padding(Constants.Layout.padding)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Constants.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
        .sheet(item: $activeSheet) { item in
            switch item {
            case .add:
                AddPersonalRecordView(authManager: authManager)
            case .edit(let record):
                EditPersonalRecordView(record: record, authManager: authManager)
            }
        }
    }
}

struct PersonalRecordRowView: View {
    let record: PersonalRecord
    var onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(8)
                    .background(Circle().fill(Color.yellow.opacity(0.15)))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.exerciseName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(ThemeManager.shared.primaryTextColor)
                    
                    Text("Установлен: \(record.dateFormatted)")
                        .font(.caption)
                        .foregroundColor(ThemeManager.shared.secondaryTextColor)
                    
                    if let notes = record.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(ThemeManager.shared.secondaryTextColor)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text("PR")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Constants.Colors.primary.opacity(0.15))
                        .foregroundColor(Constants.Colors.primary)
                        .cornerRadius(8)
                    
                    Text("\(record.weight, specifier: "%.1f") кг")
                        .font(.headline)
                        .foregroundColor(Constants.Colors.primary)
                }
            }
            
            Button(action: onEdit) {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                    Text("Редактировать")
                }
                .font(.caption)
                .foregroundColor(Constants.Colors.primary)
            }
            .buttonStyle(.plain)
            .padding(.leading, 48)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(ThemeManager.shared.cardBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ThemeManager.shared.cardBackgroundColor.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Activity Heatmap (простая сетка)
struct ActivityHeatmapView: View {
    let workouts: [Workout]
    let period: ProgressStatsView.TimePeriod
    
    private var days: [Date: Int] {
        let filtered = workouts.filterBy(period: period)
        var map: [Date: Int] = [:]
        let cal = Calendar.current
        for w in filtered {
            let day = cal.startOfDay(for: w.date ?? Date())
            var score = 0
            if let details = w.details?.allObjects as? [WorkoutDetail] {
                for d in details {
                    score += Int(d.sets * d.reps)
                }
            }
            map[day, default: 0] += score
        }
        return map
    }
    
    private var daysSequence: [Date] {
        let cal = Calendar.current
        let now = Date()
        let count: Int
        switch period {
        case .week: count = 6
        case .month: count = 29
        case .year: count = 179 // Возвращаем как было раньше
        }
        return stride(from: 0, through: count, by: 1).compactMap {
            cal.date(byAdding: .day, value: -$0, to: cal.startOfDay(for: now))
        }.reversed()
    }
    
    private var maxScore: Int {
        max(days.values.max() ?? 1, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Активность по дням")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(12), spacing: 2), count: period == .year ? 20 : (period == .month ? 10 : 7)), spacing: 2) {
                ForEach(Array(daysSequence), id: \.self) { day in
                    let score = days[day, default: 0]
                    let intensity = Double(score) / Double(maxScore)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Constants.Colors.primary.opacity(0.15 + 0.6 * intensity))
                        .frame(width: 12, height: 12)
                        .accessibilityLabel(Text("\(day, formatter: DateFormatter.short) — активность: \(score)"))
                }
            }
        }
        .padding(Constants.Layout.padding)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Constants.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Helpers
private extension Array where Element == Workout {
    func filterBy(period: ProgressStatsView.TimePeriod) -> [Workout] {
        let cal = Calendar.current
        let now = Date()
        switch period {
        case .week:
            let from = cal.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return self.filter { ($0.date ?? .distantPast) >= from }
        case .month:
            let from = cal.date(byAdding: .month, value: -1, to: now) ?? now
            return self.filter { ($0.date ?? .distantPast) >= from }
        case .year:
            let from = cal.date(byAdding: .year, value: -1, to: now) ?? now
            return self.filter { ($0.date ?? .distantPast) >= from }
        }
    }
}

// MARK: - Helper Functions
private func formatNumber(_ value: Double) -> String {
    if value >= 1000000 {
        return String(format: "%.1fM", value / 1000000)
    } else if value >= 1000 {
        return String(format: "%.0fK", value / 1000)
    } else {
        return String(format: "%.0f", value)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return ProgressStatsView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}


