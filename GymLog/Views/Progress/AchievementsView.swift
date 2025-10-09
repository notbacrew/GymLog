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
        var totalWeight = 0.0
        var consecutiveDays = 0
        var maxConsecutiveDays = 0
        
        var lastWorkoutDate: Date?
        var currentStreak = 0
        
        for workout in workouts.sorted(by: { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }) {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    totalSets += Int(detail.sets)
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
