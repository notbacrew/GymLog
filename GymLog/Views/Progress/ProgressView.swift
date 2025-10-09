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
                VStack(spacing: 20) {
                    // Селектор периода
                    Picker("Период", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Общая статистика
                    GeneralStatsView(workouts: Array(workouts), period: selectedPeriod)
                    
                    // Распределение по категориям
                    CategoryBreakdownView(workouts: Array(workouts), period: selectedPeriod)
                    
                    // Статистика по упражнениям (топ по макс. весу)
                    ExerciseStatsView(workouts: Array(workouts), period: selectedPeriod)
                    
                    // График прогресса
                    ProgressChartView(workouts: Array(workouts), period: selectedPeriod)

                    // Личные рекорды (PR)
                    PRListView(workouts: Array(workouts), period: selectedPeriod)

                    // Тепловая карта календаря (активность)
                    ActivityHeatmapView(workouts: Array(workouts), period: selectedPeriod)
                }
                .padding()
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
    
    private var totalStats: (sets: Int, reps: Int, weight: Double, cardioMinutes: Int, workouts: Int,
                             setsDelta: Int, repsDelta: Int, weightDelta: Double, cardioDelta: Int) {
        var totalSets = 0
        var totalReps = 0
        var totalWeight = 0.0
        var totalCardio = 0
        
        for workout in filteredWorkouts {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    totalSets += Int(detail.sets)
                    totalReps += Int(detail.reps)
                    // Силовые: вес * подходы * повторы; Кардио: минуты = reps, weight = 0
                    if (detail.exercise?.category?.lowercased() ?? "") == "кардио" {
                        totalCardio += Int(detail.reps) * Int(detail.sets)
                    } else {
                        totalWeight += detail.weight * Double(detail.sets) * Double(detail.reps)
                    }
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

        var prevSets = 0, prevReps = 0, prevCardio = 0
        var prevWeight = 0.0
        for workout in previousRange {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    prevSets += Int(detail.sets)
                    prevReps += Int(detail.reps)
                    if (detail.exercise?.category?.lowercased() ?? "") == "кардио" {
                        prevCardio += Int(detail.reps) * Int(detail.sets)
                    } else {
                        prevWeight += detail.weight * Double(detail.sets) * Double(detail.reps)
                    }
                }
            }
        }

        return (
            totalSets, totalReps, totalWeight, totalCardio, filteredWorkouts.count,
            totalSets - prevSets, totalReps - prevReps, totalWeight - prevWeight, totalCardio - prevCardio
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Общая статистика")
                .font(.headline)
            
            let stats = totalStats
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(stats.workouts)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Тренировок")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(stats.sets)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Подходов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DeltaTag(delta: stats.setsDelta)
                }
                
                Spacer()
                
                VStack {
                    Text("\(stats.reps)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Повторений")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DeltaTag(delta: stats.repsDelta)
                }
                
                Spacer()
                
                VStack {
                    Text(String(format: "%.0f", stats.weight))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("Общий вес (кг)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DeltaTagDouble(delta: stats.weightDelta)
                }
                
                Spacer()
                
                VStack {
                    Text("\(stats.cardioMinutes)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Кардио (мин)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DeltaTag(delta: stats.cardioDelta)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
        VStack(alignment: .leading, spacing: 16) {
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
                                .frame(width: 40, height: 40)
                                .clipped()
                                .cornerRadius(6)
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray5))
                                .frame(width: 40, height: 40)
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
                                .foregroundColor(.blue)
                            Text("\(stat.totalSets) подходов")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ProgressChartView: View {
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
    
    private var chartData: [(date: Date, weight: Double)] {
        let calendar = Calendar.current
        var dailyData: [Date: Double] = [:]
        
        for workout in filteredWorkouts {
            let day = calendar.startOfDay(for: workout.date ?? Date())
            var dayWeight = 0.0
            
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    if (detail.exercise?.category?.lowercased() ?? "") == "кардио" {
                        // учитываем минуты отдельно, в график объема силовых не включаем
                    } else {
                        dayWeight += detail.weight * Double(detail.sets) * Double(detail.reps)
                    }
                }
            }
            
            dailyData[day, default: 0] += dayWeight
        }
        
        return dailyData.map { (date: $0.key, weight: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("График прогресса")
                .font(.headline)
            
            if chartData.isEmpty {
                Text("Нет данных для отображения")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                // Простой график в виде столбцов
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                        VStack {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 20, height: max(10, CGFloat(data.weight / 10)))
                            
                            Text(formatDate(data.date))
                                .font(.caption2)
                                .rotationEffect(.degrees(-45))
                        }
                    }
                }
                .frame(height: 150)
                .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
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
                    let v: Double
                    if (d.exercise?.category?.lowercased() ?? "") == "кардио" {
                        v = 0 // не смешиваем с силовым объемом
                    } else {
                        v = d.weight * Double(d.sets) * Double(d.reps)
                    }
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Распределение по категориям")
                .font(.headline)
            
            if items.isEmpty {
                Text("Нет данных для силового объема за период")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(items, id: \.category) { item in
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.categoryColor(for: item.category))
                            .frame(width: 10, height: 10)
                        Text(item.category)
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.0f кг", item.volume))
                            .font(.subheadline)
                        Text(String(format: "(%.0f%%)", item.share * 100))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - PR List
struct PRListView: View {
    let workouts: [Workout]
    let period: ProgressStatsView.TimePeriod
    
    private struct PRItem: Identifiable { let id = UUID(); let title: String; let subtitle: String }
    
    private var items: [PRItem] {
        let filtered = workouts.filterBy(period: period)
        var bestByExercise: [UUID: (name: String, best: Double, date: Date)] = [:]
        for w in filtered {
            if let details = w.details?.allObjects as? [WorkoutDetail] {
                for d in details {
                    guard let ex = d.exercise, let exId = ex.id else { continue }
                    if (ex.category?.lowercased() ?? "") == "кардио" { continue }
                    let oneRM = d.weight * (1 + Double(d.reps)/30.0)
                    if let cur = bestByExercise[exId] {
                        if oneRM > cur.best { bestByExercise[exId] = (ex.name ?? "Упражнение", oneRM, w.date ?? Date()) }
                    } else {
                        bestByExercise[exId] = (ex.name ?? "Упражнение", oneRM, w.date ?? Date())
                    }
                }
            }
        }
        return bestByExercise.values.map { PRItem(title: $0.name, subtitle: String(format: "1RM ≈ %.1f кг", $0.best)) }
            .sorted { $0.subtitle < $1.subtitle }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Личные рекорды (оценочно)")
                .font(.headline)
            if items.isEmpty {
                Text("Нет PR за выбранный период")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(items) { item in
                    HStack {
                        Image(systemName: "trophy.fill").foregroundColor(.yellow)
                        Text(item.title).font(.subheadline)
                        Spacer()
                        Text(item.subtitle).font(.subheadline).foregroundColor(.blue)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
                    if (d.exercise?.category?.lowercased() ?? "") == "кардио" {
                        score += Int(d.reps)
                    } else {
                        score += Int(d.sets * d.reps)
                    }
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
        case .year: count = 179
        }
        return stride(from: 0, through: count, by: 1).compactMap {
            cal.date(byAdding: .day, value: -$0, to: cal.startOfDay(for: now))
        }.reversed()
    }
    
    private var maxScore: Int {
        max(days.values.max() ?? 1, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Активность по дням")
                .font(.headline)
            
            let cal = Calendar.current
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(14), spacing: 6), count: period == .year ? 26 : (period == .month ? 10 : 7)), spacing: 6) {
                ForEach(Array(daysSequence), id: \.self) { day in
                    let score = days[day, default: 0]
                    let intensity = Double(score) / Double(maxScore)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.blue.opacity(0.2 + 0.6 * intensity))
                        .frame(width: 14, height: 14)
                        .overlay(
                            Text(cal.component(.day, from: day).description)
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(intensity > 0.5 ? 1 : 0.6))
                        )
                        .accessibilityLabel(Text("\(day, formatter: DateFormatter.short) — активность: \(score)"))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return ProgressStatsView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}
