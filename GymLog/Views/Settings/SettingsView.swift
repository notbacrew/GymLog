//
//  SettingsView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingClearDataAlert = false
    @State private var showingSampleDataAlert = false
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingImportAlert = false
    @State private var importSuccess = false
    @State private var showingThemePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Данные
                    SettingsSectionView(title: "Данные") {
                        VStack(spacing: 12) {
                            SettingsActionCard(
                                icon: "square.and.arrow.up.fill",
                                title: "Экспорт в JSON",
                                subtitle: "Сохранить данные в файл",
                                color: .blue,
                                action: { showingExportSheet = true }
                            )
                            
                            SettingsActionCard(
                                icon: "square.and.arrow.down.fill",
                                title: "Импорт из JSON",
                                subtitle: "Загрузить данные из файла",
                                color: .green,
                                action: { showingImportPicker = true }
                            )
                            
                            SettingsActionCard(
                                icon: "plus.circle.fill",
                                title: "Добавить примеры данных",
                                subtitle: "Создать демо-данные",
                                color: .orange,
                                action: { showingSampleDataAlert = true }
                            )
                            
                            SettingsActionCard(
                                icon: "trash.fill",
                                title: "Очистить все данные",
                                subtitle: "Удалить все данные",
                                color: .red,
                                action: { showingClearDataAlert = true }
                            )
                        }
                    }
                    
                    // Внешний вид
                    SettingsSectionView(title: "Внешний вид") {
                        SettingsInfoCard(
                            icon: "paintbrush.fill",
                            title: "Тема",
                            value: themeManager.currentTheme.displayName,
                            color: .purple,
                            action: { showingThemePicker = true }
                        )
                    }
                    
                    // О приложении
                    SettingsSectionView(title: "О приложении") {
                        VStack(spacing: 12) {
                            SettingsInfoCard(
                                icon: "info.circle.fill",
                                title: "Версия",
                                value: "1.0.0",
                                color: .blue
                            )
                            
                            SettingsInfoCard(
                                icon: "person.2.fill",
                                title: "Разработчик",
                                value: "Чернуха Максим П-441к",
                                color: .green
                            )
                        }
                    }
                    
                    // Информация
                    SettingsSectionView(title: "Информация") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("GymLog - это приложение для ведения дневника тренировок. Все данные хранятся локально на вашем устройстве.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Добавить примеры данных?", isPresented: $showingSampleDataAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Добавить") {
                guard let user = authManager.currentUser else { return }
                createSampleData(context: viewContext, user: user)
            }
        } message: {
            Text("Это добавит примеры упражнений и тренировок для демонстрации функций приложения.")
        }
        .alert("Очистить все данные?", isPresented: $showingClearDataAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Очистить", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("Это действие удалит все упражнения и тренировки. Данные нельзя будет восстановить.")
        }
        .sheet(isPresented: $showingExportSheet) {
            if let exportURL = DataExportManager.exportToJSON(context: viewContext) {
                ShareSheet(activityItems: [exportURL])
            }
        }
        .sheet(isPresented: $showingImportPicker) {
            DocumentPicker(selectedURL: .constant(nil))
                .onDisappear {
                    // Обработка импорта будет в onAppear следующего экрана
                }
        }
        .alert("Результат импорта", isPresented: $showingImportAlert) {
            Button("OK") { }
        } message: {
            Text(importSuccess ? "Данные успешно импортированы!" : "Ошибка при импорте данных.")
        }
        .sheet(isPresented: $showingThemePicker) {
            NavigationView {
                ThemePickerView()
                    .navigationTitle("Выбор темы")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Готово") {
                                showingThemePicker = false
                            }
                        }
                    }
            }
        }
    }
    
    private func createSampleData(context: NSManagedObjectContext, user: User) {
        let calendar = Calendar.current
        let today = Date()
        
        // Создаем подробный список упражнений по категориям
        let sampleExercises: [(String, String)] = [
            // Грудь
            ("Жим лежа", "Грудь"),
            ("Жим гантелей на наклонной", "Грудь"),
            ("Отжимания на брусьях", "Грудь"),
            ("Разводка гантелей", "Грудь"),
            ("Пуловер", "Грудь"),
            
            // Спина
            ("Становая тяга", "Спина"),
            ("Подтягивания", "Спина"),
            ("Тяга штанги в наклоне", "Спина"),
            ("Тяга гантели одной рукой", "Спина"),
            ("Тяга верхнего блока", "Спина"),
            ("Гиперэкстензия", "Спина"),
            
            // Ноги
            ("Приседания со штангой", "Ноги"),
            ("Жим ногами", "Ноги"),
            ("Выпады", "Ноги"),
            ("Румынская тяга", "Ноги"),
            ("Подъемы на носки", "Ноги"),
            ("Разгибания ног", "Ноги"),
            
            // Плечи
            ("Жим стоя", "Плечи"),
            ("Жим Арнольда", "Плечи"),
            ("Махи гантелями в стороны", "Плечи"),
            ("Тяга штанги к подбородку", "Плечи"),
            ("Разводка в наклоне", "Плечи"),
            
            // Руки
            ("Подъем штанги на бицепс", "Руки"),
            ("Молотки", "Руки"),
            ("Французский жим", "Руки"),
            ("Отжимания узким хватом", "Руки"),
            ("Концентрированные сгибания", "Руки"),
            
            // Пресс
            ("Скручивания", "Пресс"),
            ("Планка", "Пресс"),
            ("Подъемы ног", "Пресс"),
            ("Русские скручивания", "Пресс")
        ]
        
        // Создаем упражнения
        var exerciseMap: [String: Exercise] = [:]
        for (name, category) in sampleExercises {
            let exercise = Exercise(context: context)
            exercise.id = UUID()
            exercise.name = name
            exercise.category = category
            exercise.timestamp = calendar.date(byAdding: .day, value: -Int.random(in: 45...60), to: today) ?? today
            exercise.user = user
            exerciseMap[name] = exercise
        }
        
        // Определяем типы тренировок
        let workoutTypes: [(name: String, exercises: [String])] = [
            ("Грудь и Трицепс", ["Жим лежа", "Жим гантелей на наклонной", "Отжимания на брусьях", "Разводка гантелей", "Французский жим", "Отжимания узким хватом"]),
            ("Спина и Бицепс", ["Становая тяга", "Подтягивания", "Тяга штанги в наклоне", "Тяга гантели одной рукой", "Подъем штанги на бицепс", "Молотки", "Концентрированные сгибания"]),
            ("Ноги", ["Приседания со штангой", "Жим ногами", "Выпады", "Румынская тяга", "Подъемы на носки", "Разгибания ног"]),
            ("Плечи", ["Жим стоя", "Жим Арнольда", "Махи гантелями в стороны", "Тяга штанги к подбородку", "Разводка в наклоне"]),
            ("Руки", ["Подъем штанги на бицепс", "Молотки", "Французский жим", "Отжимания узким хватом", "Концентрированные сгибания"]),
            ("Верх тела", ["Жим лежа", "Подтягивания", "Жим стоя", "Тяга штанги в наклоне", "Отжимания на брусьях", "Подъем штанги на бицепс"]),
            ("Ноги и Пресс", ["Приседания со штангой", "Жим ногами", "Выпады", "Скручивания", "Планка", "Подъемы ног"]),
            ("Фулбоди", ["Приседания со штангой", "Жим лежа", "Становая тяга", "Подтягивания", "Жим стоя", "Скручивания"])
        ]
        
        // Базовые веса для каждого упражнения (в кг)
        var baseWeights: [String: Double] = [:]
        for (name, category) in sampleExercises {
            switch category {
            case "Грудь":
                baseWeights[name] = name.contains("Жим лежа") ? 70.0 : (name.contains("на наклонной") ? 25.0 : 0.0)
            case "Спина":
                baseWeights[name] = name.contains("Становая") ? 100.0 : (name.contains("Подтягивания") ? 0.0 : 40.0)
            case "Ноги":
                baseWeights[name] = name.contains("Приседания") ? 80.0 : (name.contains("Жим ногами") ? 120.0 : 20.0)
            case "Плечи":
                baseWeights[name] = name.contains("Жим стоя") ? 30.0 : 12.0
            case "Руки":
                baseWeights[name] = name.contains("бицепс") ? 20.0 : 15.0
            case "Пресс":
                baseWeights[name] = 0.0
            default:
                baseWeights[name] = 20.0
            }
        }
        
        // Создаем тренировки на последние 45 дней (примерно 6 недель, 3-4 тренировки в неделю)
        var workoutCount = 0
        var maxWeights: [String: Double] = [:] // Для отслеживания максимальных весов
        var prDates: [String: Date] = [:] // Для отслеживания дат рекордов
        
        for dayOffset in stride(from: 44, through: 0, by: -1) {
            // Пропускаем некоторые дни (не тренируемся каждый день)
            if dayOffset % 7 == 6 || (dayOffset % 7 == 0 && dayOffset < 30) {
                continue // Пропускаем воскресенье и некоторые понедельники в начале
            }
            
            guard let workoutDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // Выбираем тип тренировки (циклично)
            let workoutType = workoutTypes[workoutCount % workoutTypes.count]
            workoutCount += 1
            
            let workout = Workout(context: context)
            workout.id = UUID()
            workout.date = workoutDate
            
            // Добавляем заметки к некоторым тренировкам
            let baseNotes: [String?] = [
                "Отличная тренировка!",
                "Чувствовал себя хорошо",
                "Устал, но доволен результатом",
                "Прогресс чувствуется",
                nil,
                nil,
                nil
            ]
            
            // Иногда добавляем название типа тренировки
            if let baseNote = baseNotes.randomElement(), let note = baseNote {
                workout.notes = "\(workoutType.name). \(note)"
            } else if Int.random(in: 0...2) == 0 {
                workout.notes = workoutType.name
            }
            workout.user = user
            
            // Добавляем упражнения к тренировке
            for exerciseName in workoutType.exercises {
                guard let exercise = exerciseMap[exerciseName] else { continue }
                
                // Прогрессивное увеличение веса со временем
                let daysAgo = dayOffset
                let progressFactor = 1.0 + (Double(44 - daysAgo) / 44.0) * 0.15 // Увеличение на 15% за период
                let baseWeight = baseWeights[exerciseName] ?? 20.0
                var currentWeight = baseWeight * progressFactor
                
                // Добавляем небольшие вариации
                currentWeight += Double.random(in: -2.5...2.5)
                currentWeight = max(0, round(currentWeight / 2.5) * 2.5) // Округляем до 2.5 кг
                
                // Для упражнений с весом тела - используем только повторения
                let isBodyWeight = exerciseName.contains("Подтягивания") || 
                                 exerciseName.contains("Отжимания") || 
                                 exerciseName.contains("Планка") ||
                                 exerciseName.contains("Скручивания") ||
                                 exerciseName.contains("Подъемы ног") ||
                                 exerciseName.contains("Русские")
                
                // Количество подходов (3-5)
                let sets = Int16.random(in: 3...5)
                
                // Количество повторений зависит от упражнения
                var reps: Int16
                if isBodyWeight {
                    if exerciseName.contains("Подтягивания") {
                        reps = Int16.random(in: 6...12)
                        currentWeight = 0 // Вес тела не учитываем
                    } else if exerciseName.contains("Отжимания") {
                        reps = Int16.random(in: 10...20)
                        currentWeight = 0
                    } else if exerciseName.contains("Планка") {
                        reps = 1 // Планка в секундах (но храним как reps)
                        currentWeight = 0
                    } else {
                        reps = Int16.random(in: 15...25)
                        currentWeight = 0
                    }
                } else {
                    // Для силовых упражнений
                    if currentWeight >= 60 {
                        reps = Int16.random(in: 4...8) // Тяжелые веса
                    } else if currentWeight >= 30 {
                        reps = Int16.random(in: 6...12) // Средние веса
                    } else {
                        reps = Int16.random(in: 10...15) // Легкие веса
                    }
                }
                
                // Создаем детали тренировки
                let detail = WorkoutDetail(context: context)
                detail.id = UUID()
                detail.sets = sets
                detail.reps = reps
                detail.weight = currentWeight
                
                // Добавляем комментарии к некоторым упражнениям
                let commentOptions = [
                    nil, nil, nil, nil, nil, // Большинство без комментариев
                    "Отличная форма",
                    "Последний подход был тяжелым",
                    "Легко далось",
                    "Нужно увеличить вес в следующий раз"
                ]
                detail.comment = commentOptions.randomElement() ?? nil
                
                detail.exercise = exercise
                detail.workout = workout
                
                // Отслеживаем максимальные веса для личных рекордов
                if !isBodyWeight && currentWeight > 0 {
                    if maxWeights[exerciseName] == nil || currentWeight > maxWeights[exerciseName]! {
                        maxWeights[exerciseName] = currentWeight
                        prDates[exerciseName] = workoutDate
                    }
                }
            }
        }
        
        // Сохраняем данные
        do {
            try context.save()
            
            // Создаем личные рекорды для основных упражнений
            guard let userId = user.id?.uuidString else { return }
            
            let prExercises = ["Жим лежа", "Становая тяга", "Приседания со штангой", "Жим стоя", 
                             "Подтягивания", "Тяга штанги в наклоне", "Жим ногами"]
            
            for exerciseName in prExercises {
                if let maxWeight = maxWeights[exerciseName], maxWeight > 0,
                   let prDate = prDates[exerciseName] {
                    let record = PersonalRecord(
                        exerciseName: exerciseName,
                        weight: maxWeight,
                        date: prDate,
                        notes: "Установлен на тренировке"
                    )
                    PersonalRecordManager.shared.addRecord(record, for: userId)
                } else if exerciseName == "Подтягивания" {
                    // Для подтягиваний рекорд - это количество повторений
                    let record = PersonalRecord(
                        exerciseName: exerciseName,
                        weight: 15.0, // Сохраняем как количество повторений в поле weight
                        date: prDates[exerciseName] ?? calendar.date(byAdding: .day, value: -20, to: today) ?? today,
                        notes: "15 повторений"
                    )
                    PersonalRecordManager.shared.addRecord(record, for: userId)
                }
            }
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func clearAllData() {
        // Удаляем все упражнения
        let exerciseRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        if let exercises = try? viewContext.fetch(exerciseRequest) {
            for exercise in exercises {
                viewContext.delete(exercise)
            }
        }
        
        // Удаляем все тренировки
        let workoutRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        if let workouts = try? viewContext.fetch(workoutRequest) {
            for workout in workouts {
                viewContext.delete(workout)
            }
        }
        
        // Удаляем все детали тренировок
        let detailRequest: NSFetchRequest<WorkoutDetail> = WorkoutDetail.fetchRequest()
        if let details = try? viewContext.fetch(detailRequest) {
            for detail in details {
                viewContext.delete(detail)
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return SettingsView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}

// MARK: - Settings Components
struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            content
        }
    }
}

struct SettingsActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.Layout.padding) {
                // Иконка
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(color)
                    )
                
                // Текст
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Стрелка
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(Constants.Layout.padding)
            .background(ThemeManager.shared.cardBackgroundColor)
            .cornerRadius(Constants.Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let action: (() -> Void)?
    
    init(icon: String, title: String, value: String, color: Color, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: Constants.Layout.padding) {
                // Иконка
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(color)
                    )
                
                // Текст
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(value)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Стрелка (если есть действие)
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(Constants.Layout.padding)
            .background(ThemeManager.shared.cardBackgroundColor)
            .cornerRadius(Constants.Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}
