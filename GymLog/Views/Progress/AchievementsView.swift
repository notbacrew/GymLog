//
//  AchievementsView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct AchievementsView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    
    private var workouts: [Workout] {
        guard let user = authManager.currentUser else { return [] }
        return (user.workouts?.allObjects as? [Workout])?.sorted { 
            ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) 
        } ?? []
    }
    
    private var achievements: [GymAchievement] {
        let calendar = Calendar.current
        let totalWorkouts = workouts.count
        
        // Подсчитываем статистику
        var totalSets = 0
        var totalReps = 0
        var totalWeight = 0.0
        var consecutiveDays = 0
        var maxConsecutiveDays = 0
        
        var lastWorkoutDate: Date?
        var currentStreak = 0
        
        for workout in workouts.sorted(by: { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }) {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    totalSets += Int(detail.sets)
                    totalReps += Int(detail.sets) * Int(detail.reps)
                    totalWeight += detail.weight * Double(detail.sets)
                }
            }
            
            // Подсчет последовательных дней
            if let workoutDate = workout.date {
                let workoutDay = calendar.startOfDay(for: workoutDate)
                
                if let lastDate = lastWorkoutDate {
                    let lastDay = calendar.startOfDay(for: lastDate)
                    let daysBetween = calendar.dateComponents([.day], from: workoutDay, to: lastDay).day ?? 0
                    
                    if daysBetween == 1 {
                        currentStreak += 1
                    } else if daysBetween > 1 {
                        maxConsecutiveDays = max(maxConsecutiveDays, currentStreak)
                        currentStreak = 1
                    }
                } else {
                    currentStreak = 1
                }
                
                lastWorkoutDate = workoutDate
            }
        }
        
        maxConsecutiveDays = max(maxConsecutiveDays, currentStreak)
        
        // Дополнительные агрегаты для достижений
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let workoutsLast7Days = workouts.filter { (w: Workout) in
            guard let d = w.date else { return false }
            return d >= weekAgo
        }.count
        
        let todaysCount = workouts.filter { (w: Workout) in
            guard let d = w.date else { return false }
            return calendar.isDate(d, inSameDayAs: now)
        }.count
        
        let thisMonth = calendar.dateComponents([.year, .month], from: now)
        let workoutsThisMonth = workouts.filter { (w: Workout) in
            guard let d = w.date else { return false }
            let comp = calendar.dateComponents([.year, .month], from: d)
            return comp.year == thisMonth.year && comp.month == thisMonth.month
        }.count
        
        return [
            GymAchievement(
                id: "first_workout",
                title: "Первая тренировка",
                description: "Создайте свою первую тренировку",
                icon: "play.circle.fill",
                color: .green,
                isUnlocked: totalWorkouts >= 1,
                progress: min(totalWorkouts, 1),
                maxProgress: 1
            ),
            GymAchievement(
                id: "five_workouts",
                title: "Начало пути",
                description: "Проведите 5 тренировок",
                icon: "5.circle.fill",
                color: .blue,
                isUnlocked: totalWorkouts >= 5,
                progress: min(totalWorkouts, 5),
                maxProgress: 5
            ),
            GymAchievement(
                id: "ten_workouts",
                title: "Регулярность",
                description: "Проведите 10 тренировок",
                icon: "10.circle.fill",
                color: .purple,
                isUnlocked: totalWorkouts >= 10,
                progress: min(totalWorkouts, 10),
                maxProgress: 10
            ),
            GymAchievement(
                id: "twenty_workouts",
                title: "На разогреве",
                description: "Проведите 20 тренировок",
                icon: "20.circle.fill",
                color: .teal,
                isUnlocked: totalWorkouts >= 20,
                progress: min(totalWorkouts, 20),
                maxProgress: 20
            ),
            GymAchievement(
                id: "fifty_workouts",
                title: "Полсотни",
                description: "Проведите 50 тренировок",
                icon: "50.circle.fill",
                color: .indigo,
                isUnlocked: totalWorkouts >= 50,
                progress: min(totalWorkouts, 50),
                maxProgress: 50
            ),
            GymAchievement(
                id: "hundred_workouts",
                title: "Сотня тренировок",
                description: "Проведите 100 тренировок",
                icon: "100.circle.fill",
                color: .yellow,
                isUnlocked: totalWorkouts >= 100,
                progress: min(totalWorkouts, 100),
                maxProgress: 100
            ),
            GymAchievement(
                id: "hundred_sets",
                title: "Сотня подходов",
                description: "Выполните 100 подходов",
                icon: "100.circle.fill",
                color: .orange,
                isUnlocked: totalSets >= 100,
                progress: min(totalSets, 100),
                maxProgress: 100
            ),
            GymAchievement(
                id: "five_hundred_sets",
                title: "Полтысячи",
                description: "Выполните 500 подходов",
                icon: "500.circle.fill",
                color: .red,
                isUnlocked: totalSets >= 500,
                progress: min(totalSets, 500),
                maxProgress: 500
            ),
            GymAchievement(
                id: "thousand_sets",
                title: "Тысячник",
                description: "Выполните 1000 подходов",
                icon: "1000.circle.fill",
                color: .yellow,
                isUnlocked: totalSets >= 1000,
                progress: min(totalSets, 1000),
                maxProgress: 1000
            ),
            GymAchievement(
                id: "two_thousand_sets",
                title: "2000 подходов",
                description: "Наберите 2000 подходов за всё время",
                icon: "number",
                color: .orange,
                isUnlocked: totalSets >= 2000,
                progress: min(totalSets, 2000),
                maxProgress: 2000
            ),
            GymAchievement(
                id: "five_thousand_sets",
                title: "5000 подходов",
                description: "Наберите 5000 подходов за всё время",
                icon: "number",
                color: .pink,
                isUnlocked: totalSets >= 5000,
                progress: min(totalSets, 5000),
                maxProgress: 5000
            ),
            GymAchievement(
                id: "ten_thousand_reps",
                title: "10 000 повторений",
                description: "Выполните суммарно 10 000 повторений",
                icon: "repeat",
                color: .teal,
                isUnlocked: totalReps >= 10_000,
                progress: min(totalReps, 10_000),
                maxProgress: 10_000
            ),
            GymAchievement(
                id: "week_streak",
                title: "Неделя подряд",
                description: "Тренируйтесь 7 дней подряд",
                icon: "calendar.badge.plus",
                color: .cyan,
                isUnlocked: maxConsecutiveDays >= 7,
                progress: min(maxConsecutiveDays, 7),
                maxProgress: 7
            ),
            GymAchievement(
                id: "two_weeks_streak",
                title: "Две недели подряд",
                description: "Тренируйтесь 14 дней подряд",
                icon: "calendar",
                color: .blue,
                isUnlocked: maxConsecutiveDays >= 14,
                progress: min(maxConsecutiveDays, 14),
                maxProgress: 14
            ),
            GymAchievement(
                id: "month_streak",
                title: "Месяц подряд",
                description: "Тренируйтесь 30 дней подряд",
                icon: "calendar.badge.clock",
                color: .indigo,
                isUnlocked: maxConsecutiveDays >= 30,
                progress: min(maxConsecutiveDays, 30),
                maxProgress: 30
            ),
            GymAchievement(
                id: "heavy_lifter",
                title: "Тяжеловес",
                description: "Поднимите 1000 кг за тренировку",
                icon: "scalemass.fill",
                color: .brown,
                isUnlocked: totalWeight >= 1000,
                progress: min(Int(totalWeight), 1000),
                maxProgress: 1000
            ),
            GymAchievement(
                id: "mass_5k",
                title: "Железо 5000",
                description: "Наберите 5000 кг суммарно",
                icon: "scalemass",
                color: .purple,
                isUnlocked: Int(totalWeight) >= 5000,
                progress: min(Int(totalWeight), 5000),
                maxProgress: 5000
            ),
            GymAchievement(
                id: "mass_10k",
                title: "Железо 10 000",
                description: "Наберите 10 000 кг суммарно",
                icon: "scalemass",
                color: .orange,
                isUnlocked: Int(totalWeight) >= 10_000,
                progress: min(Int(totalWeight), 10_000),
                maxProgress: 10_000
            ),
            GymAchievement(
                id: "week_3_workouts",
                title: "Три за неделю",
                description: "Выполните 3 тренировки за последние 7 дней",
                icon: "chart.bar.fill",
                color: .green,
                isUnlocked: workoutsLast7Days >= 3,
                progress: min(workoutsLast7Days, 3),
                maxProgress: 3
            ),
            GymAchievement(
                id: "month_12_workouts",
                title: "12 в месяц",
                description: "Выполните 12 тренировок в текущем месяце",
                icon: "calendar.badge.clock",
                color: .mint,
                isUnlocked: workoutsThisMonth >= 12,
                progress: min(workoutsThisMonth, 12),
                maxProgress: 12
            ),
            GymAchievement(
                id: "double_day",
                title: "Двойная сессия",
                description: "Сделайте 2 тренировки за один день",
                icon: "bolt.fill",
                color: .red,
                isUnlocked: todaysCount >= 2,
                progress: min(todaysCount, 2),
                maxProgress: 2
            )
        ]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Общая статистика
                    VStack(spacing: 12) {
                        Text("Ваша статистика")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(workouts.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Тренировок")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("\(achievements.filter { $0.isUnlocked }.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Достижений")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("\(Int(achievements.filter { $0.isUnlocked }.count * 100 / achievements.count))%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Text("Завершено")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Список достижений
                    ForEach(achievements) { achievement in
                        AchievementRowView(achievement: achievement)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Достижения")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GymAchievement {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    let progress: Int
    let maxProgress: Int
    
    init(id: String, title: String, description: String, icon: String, color: Color, isUnlocked: Bool, progress: Int, maxProgress: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.isUnlocked = isUnlocked
        self.progress = progress
        self.maxProgress = maxProgress
    }
}

extension GymAchievement: Identifiable {}

struct AchievementRowView: View {
    let achievement: GymAchievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка достижения
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color : Color(.systemGray4))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            // Информация о достижении
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Прогресс-бар
                if !achievement.isUnlocked && achievement.maxProgress > 1 {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 4)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(achievement.color)
                                .frame(width: geometry.size.width * (Double(achievement.progress) / Double(achievement.maxProgress)), height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(achievement.progress) / \(achievement.maxProgress)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Статус
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return AchievementsView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}
