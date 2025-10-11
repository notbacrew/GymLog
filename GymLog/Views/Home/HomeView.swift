//
//  HomeView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData
import UIKit

struct HomeView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest private var allWorkouts: FetchedResults<Workout>
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        self._allWorkouts = FetchRequest<Workout>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
        )
    }
    
    private var workouts: [Workout] {
        guard let user = authManager.currentUser else { return [] }
        return allWorkouts.filter { $0.user == user }
    }
    
    @State private var showingQuickWorkout = false
    @State private var showingAchievements = false
    @State private var showingAddExercise = false
    @State private var showingTimer = false
    
    private var recentWorkouts: [Workout] {
        Array(workouts.prefix(5))
    }
    
    private var todayWorkouts: [Workout] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return workouts.filter { workout in
            guard let date = workout.date else { return false }
            return calendar.isDate(date, inSameDayAs: today)
        }
    }
    
    private var weeklyStats: (workouts: Int, totalSets: Int, totalWeight: Double) {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        
        let weekWorkouts = workouts.filter { $0.date ?? Date.distantPast >= weekAgo }
        var totalSets = 0
        var totalWeight = 0.0
        
        for workout in weekWorkouts {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    totalSets += Int(detail.sets)
                    
                    // Для кардио считаем минуты, для силовых - вес
                    if let exerciseCategory = detail.exercise?.category?.lowercased(), exerciseCategory == "кардио" {
                        // Для кардио считаем "общий объем" как минуты * подходы
                        totalWeight += Double(detail.reps) * Double(detail.sets)
                    } else {
                        // Для силовых упражнений считаем общий вес
                        totalWeight += detail.weight * Double(detail.sets) * Double(detail.reps)
                    }
                }
            }
        }
        
        return (weekWorkouts.count, totalSets, totalWeight)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Красивый заголовок с приветствием
                        HomeHeaderView(greetingText: greetingText, authManager: authManager)
                        
                        // Быстрые действия с карточным дизайном
                        QuickActionsCardView(authManager: authManager, showingQuickWorkout: $showingQuickWorkout, showingAddExercise: $showingAddExercise, showingTimer: $showingTimer)
                        
                        // Статистика недели с улучшенным дизайном
                        WeeklyStatsCardView(stats: weeklyStats)
                        
                        // Сегодняшние тренировки
                        if !todayWorkouts.isEmpty {
                            TodaysWorkoutsCardView(workouts: todayWorkouts, authManager: authManager, onDeleteWorkout: deleteWorkout)
                        }
                        
                        // Последние тренировки
                        RecentWorkoutsCardView(workouts: recentWorkouts, authManager: authManager)
                        
                        // Достижения
                        AchievementsCardView(showingAchievements: $showingAchievements)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                .background(Color(.systemGroupedBackground))
                .refreshable {
                    // Обновление данных
                }
                
                // Размытый фон в верхней части с плавным переходом
                VStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .mask(
                            LinearGradient(
                                colors: [
                                    Color.black,
                                    Color.black.opacity(0.8),
                                    Color.black.opacity(0.4),
                                    Color.black.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .backgroundExtensionEffect()
                        .frame(height: 150)
                        .ignoresSafeArea(.all, edges: .top)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingQuickWorkout) {
                AddWorkoutView(authManager: authManager)
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(authManager: authManager)
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView(authManager: authManager)
            }
            .sheet(isPresented: $showingTimer) {
                RestTimerView()
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Доброе утро!"
        case 12..<17:
            return "Добрый день!"
        case 17..<22:
            return "Добрый вечер!"
        default:
            return "Доброй ночи!"
        }
    }
    
    private func deleteWorkout(_ workout: Workout) {
        withAnimation {
            viewContext.delete(workout)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting workout: \(error)")
                viewContext.rollback()
            }
        }
    }
}

// MARK: - Home Header
struct HomeHeaderView: View {
    let greetingText: String
    @ObservedObject var authManager: AuthManager
    @State private var showingProfile = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Иконка приложения и название в верхней части
            VStack(spacing: 4) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.top, 25) // Отступ от статус-бара
                
                Text("GymLog")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(.bottom, 20) // Увеличил отступ до фона
            }
            
            // Верхняя часть с уменьшенным отступом
            VStack(spacing: 16) {
                // Заголовок "Главная" и приветствие в одной строке
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Главная")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(greetingText)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Аватарка профиля
                    Button(action: {
                        showingProfile = true
                    }) {
                        if let avatarData = authManager.currentUser?.avatar,
                           let uiImage = UIImage(data: avatarData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Подзаголовок
                HStack {
                    Text("Готов к тренировке?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16) // Уменьшенный отступ от иконки приложения
            .padding(.bottom, 28)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 12)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(authManager: authManager)
        }
    }
}

// MARK: - Quick Actions Card
struct QuickActionsCardView: View {
    @ObservedObject var authManager: AuthManager
    @Binding var showingQuickWorkout: Bool
    @Binding var showingAddExercise: Bool
    @Binding var showingTimer: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Быстрые действия")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "Новая тренировка",
                    subtitle: "Начать сейчас",
                    color: .blue,
                    action: { showingQuickWorkout = true }
                )
                
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "Новое упражнение",
                    subtitle: "Добавить",
                    color: .green,
                    action: { showingAddExercise = true }
                )
            }
            
            // Таймер отдыха - заметно, но не навязчиво
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Таймер отдыха")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { showingTimer = true }) {
                    HStack(spacing: 6) {
                        Text("Запустить")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                        
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Weekly Stats Card
struct WeeklyStatsCardView: View {
    let stats: (workouts: Int, totalSets: Int, totalWeight: Double)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статистика недели")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 0) {
                StatItemView(
                    value: "\(stats.workouts)",
                    label: "Тренировок",
                    color: .blue,
                    icon: "dumbbell.fill"
                )
                
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 16)
                
                StatItemView(
                    value: "\(stats.totalSets)",
                    label: "Подходов",
                    color: .green,
                    icon: "repeat"
                )
                
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 16)
                
                StatItemView(
                    value: String(format: "%.0f", stats.totalWeight),
                    label: "Общий вес (кг)",
                    color: .orange,
                    icon: "scalemass.fill"
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct StatItemView: View {
    let value: String
    let label: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Today's Workouts Card
struct TodaysWorkoutsCardView: View {
    let workouts: [Workout]
    let authManager: AuthManager
    let onDeleteWorkout: (Workout) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.blue)
                    .font(.system(size: 18, weight: .medium))
                
                Text("Сегодня")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(workouts.count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(spacing: 12) {
                ForEach(workouts, id: \.id) { workout in
                    NavigationLink(destination: WorkoutDetailView(authManager: authManager, workout: workout)) {
                        WorkoutRowCardView(workout: workout)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Удалить", role: .destructive) {
                            onDeleteWorkout(workout)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct WorkoutRowCardView: View {
    let workout: Workout
    
    private var exerciseCount: Int {
        workout.details?.count ?? 0
    }
    
    private var totalSets: Int {
        guard let details = workout.details?.allObjects as? [WorkoutDetail] else { return 0 }
        return details.reduce(0) { $0 + Int($1.sets) }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Время тренировки
            VStack(alignment: .leading, spacing: 4) {
                Text(DateFormatter.time.string(from: workout.date ?? Date()))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(exerciseCount) упражнений")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Статистика
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(totalSets) подходов")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Recent Workouts Card
struct RecentWorkoutsCardView: View {
    let workouts: [Workout]
    let authManager: AuthManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.green)
                    .font(.system(size: 18, weight: .medium))
                
                Text("Последние тренировки")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink(destination: WorkoutListView(authManager: authManager)) {
                    HStack(spacing: 4) {
                        Text("Все")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if workouts.isEmpty {
                EmptyStateView(
                    icon: "dumbbell",
                    title: "Пока нет тренировок",
                    subtitle: "Начните с создания первой тренировки"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(workouts, id: \.id) { workout in
                        NavigationLink(destination: WorkoutDetailView(authManager: authManager, workout: workout)) {
                            RecentWorkoutRowView(workout: workout)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct RecentWorkoutRowView: View {
    let workout: Workout
    
    private var exerciseCount: Int {
        workout.details?.count ?? 0
    }
    
    private var totalSets: Int {
        guard let details = workout.details?.allObjects as? [WorkoutDetail] else { return 0 }
        return details.reduce(0) { $0 + Int($1.sets) }
    }
    
    private var workoutDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: workout.date ?? Date())
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка тренировки
            Image(systemName: "dumbbell.fill")
                .foregroundColor(.green)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 24, height: 24)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
            
            // Информация о тренировке
            VStack(alignment: .leading, spacing: 4) {
                Text(workoutDate)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("\(exerciseCount) упражнений • \(totalSets) подходов")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - Achievements Card
struct AchievementsCardView: View {
    @Binding var showingAchievements: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18, weight: .medium))
                
                Text("Достижения")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { showingAchievements = true }) {
                    HStack(spacing: 4) {
                        Text("Все")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            HStack(spacing: 12) {
                AchievementBadgeCardView(
                    icon: "flame.fill",
                    title: "Первая тренировка",
                    isUnlocked: true,
                    color: .orange
                )
                
                AchievementBadgeCardView(
                    icon: "calendar",
                    title: "Неделя тренировок",
                    isUnlocked: false,
                    color: .blue
                )
                
                AchievementBadgeCardView(
                    icon: "trophy.fill",
                    title: "100 подходов",
                    isUnlocked: false,
                    color: .yellow
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct AchievementBadgeCardView: View {
    let icon: String
    let title: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isUnlocked ? color : .secondary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isUnlocked ? color.opacity(0.1) : Color(.systemGray5))
                )
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isUnlocked ? color.opacity(0.05) : Color(.systemGray6))
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return HomeView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}

