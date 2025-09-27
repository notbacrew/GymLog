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
                    
                    // Статистика по упражнениям
                    ExerciseStatsView(workouts: Array(workouts), period: selectedPeriod)
                    
                    // График прогресса
                    ProgressChartView(workouts: Array(workouts), period: selectedPeriod)
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
    
    private var totalStats: (sets: Int, reps: Int, weight: Double, workouts: Int) {
        var totalSets = 0
        var totalReps = 0
        var totalWeight = 0.0
        
        for workout in filteredWorkouts {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    totalSets += Int(detail.sets)
                    totalReps += Int(detail.reps)
                    totalWeight += detail.weight * Double(detail.sets)
                }
            }
        }
        
        return (totalSets, totalReps, totalWeight, filteredWorkouts.count)
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
                    dayWeight += detail.weight * Double(detail.sets)
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

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return ProgressStatsView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}
