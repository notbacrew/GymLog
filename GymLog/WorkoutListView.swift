//
//  WorkoutListView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct WorkoutListView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    
    private var workouts: [Workout] {
        guard let user = authManager.currentUser else { return [] }
        return (user.workouts?.allObjects as? [Workout])?.sorted { 
            ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) 
        } ?? []
    }
    
    @State private var showingAddWorkout = false
    @State private var searchText = ""
    @State private var selectedPeriod: Constants.FilterPeriod = .all
    @State private var selectedCategory: String = "Все"
    @State private var showingFilters = false
    
    private var categories: [String] {
        var cats = ["Все"]
        let exerciseRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        if let exercises = try? viewContext.fetch(exerciseRequest) {
            let uniqueCategories = Set(exercises.compactMap { $0.category }).sorted()
            cats.append(contentsOf: uniqueCategories)
        }
        return cats
    }
    
    private var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let now = Date()
        
        var filtered = workouts.filter { workout in
            // Фильтр по тексту поиска
            let matchesSearch = searchText.isEmpty || 
                (workout.notes?.localizedCaseInsensitiveContains(searchText) == true)
            
            // Фильтр по периоду
            let matchesPeriod: Bool
            switch selectedPeriod {
            case .all:
                matchesPeriod = true
            case .today:
                matchesPeriod = calendar.isDate(workout.date ?? Date.distantPast, inSameDayAs: now)
            case .week:
                let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
                matchesPeriod = workout.date ?? Date.distantPast >= weekAgo
            case .month:
                let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                matchesPeriod = workout.date ?? Date.distantPast >= monthAgo
            case .year:
                let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
                matchesPeriod = workout.date ?? Date.distantPast >= yearAgo
            }
            
            // Фильтр по категории
            let matchesCategory: Bool
            if selectedCategory == "Все" {
                matchesCategory = true
            } else {
                let workoutCategories = (workout.details?.allObjects as? [WorkoutDetail])?
                    .compactMap { $0.exercise?.category } ?? []
                matchesCategory = workoutCategories.contains(selectedCategory)
            }
            
            return matchesSearch && matchesPeriod && matchesCategory
        }
        
        return Array(filtered)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }
    
    private var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поиск и фильтры
                SearchAndFiltersView(
                    searchText: $searchText,
                    selectedPeriod: $selectedPeriod,
                    selectedCategory: $selectedCategory,
                    categories: categories,
                    showingFilters: $showingFilters
                )
                
                // Список тренировок
                if filteredWorkouts.isEmpty {
                    EmptyWorkoutsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredWorkouts, id: \.id) { workout in
                                NavigationLink(destination: WorkoutDetailView(authManager: authManager, workout: workout)) {
                                    WorkoutCardView(workout: workout)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .refreshable {
                        // Обновляем данные при pull-to-refresh
                        viewContext.refreshAllObjects()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Тренировки")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddWorkout = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView(authManager: authManager)
            }
            .sheet(isPresented: $showingFilters) {
                WorkoutFiltersView(
                    selectedPeriod: $selectedPeriod,
                    selectedCategory: $selectedCategory,
                    categories: categories
                )
            }
        }
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredWorkouts[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Search and Filters
struct SearchAndFiltersView: View {
    @Binding var searchText: String
    @Binding var selectedPeriod: Constants.FilterPeriod
    @Binding var selectedCategory: String
    let categories: [String]
    @Binding var showingFilters: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Поиск
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Поиск тренировок", text: $searchText)
                    .font(.system(size: 16, weight: .regular))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            // Фильтры
            HStack(spacing: 12) {
                // Фильтр по периоду
                FilterChipView(
                    title: selectedPeriod.rawValue,
                    icon: "calendar",
                    isSelected: true
                ) {
                    // Переключаем между периодами
                    switch selectedPeriod {
                    case .all:
                        selectedPeriod = .today
                    case .today:
                        selectedPeriod = .week
                    case .week:
                        selectedPeriod = .month
                    case .month:
                        selectedPeriod = .year
                    case .year:
                        selectedPeriod = .all
                    }
                }
                
                // Фильтр по категории
                FilterChipView(
                    title: selectedCategory,
                    icon: "tag",
                    isSelected: true
                ) {
                    // Переключаем между категориями
                    if let currentIndex = categories.firstIndex(of: selectedCategory) {
                        let nextIndex = (currentIndex + 1) % categories.count
                        selectedCategory = categories[nextIndex]
                    }
                }
                
                Spacer()
                
                Button(action: { showingFilters = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(Color(.systemGroupedBackground))
    }
}

struct FilterChipView: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(isSelected ? .blue : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty State
struct EmptyWorkoutsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dumbbell")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Пока нет тренировок")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Нажмите + чтобы создать первую тренировку")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Workout Card
struct WorkoutCardView: View {
    let workout: Workout
    
    private var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private var exerciseCount: Int {
        workout.details?.count ?? 0
    }
    
    private var totalSets: Int {
        guard let details = workout.details?.allObjects as? [WorkoutDetail] else { return 0 }
        return details.reduce(0) { $0 + Int($1.sets) }
    }
    
    private var totalReps: Int {
        guard let details = workout.details?.allObjects as? [WorkoutDetail] else { return 0 }
        return details.reduce(0) { $0 + Int($1.reps) }
    }
    
    private var totalWeight: Double {
        guard let details = workout.details?.allObjects as? [WorkoutDetail] else { return 0 }
        return details.reduce(0) { $0 + ($1.weight * Double($1.sets)) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(shortDateFormatter.string(from: workout.date ?? Date()))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("\(exerciseCount) упражнений")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Заметки
            if let notes = workout.notes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Статистика
            HStack(spacing: 16) {
                if totalSets > 0 {
                    StatisticItemView(
                        icon: "repeat",
                        value: "\(totalSets)",
                        label: "подходов",
                        color: .green
                    )
                }
                
                if totalReps > 0 {
                    StatisticItemView(
                        icon: "arrow.clockwise",
                        value: "\(totalReps)",
                        label: "повторений",
                        color: .orange
                    )
                }
                
                if totalWeight > 0 {
                    StatisticItemView(
                        icon: "scalemass.fill",
                        value: String(format: "%.0f", totalWeight),
                        label: "кг",
                        color: .blue
                    )
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct StatisticItemView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return WorkoutListView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}
