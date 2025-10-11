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
    @StateObject private var themeManager = ThemeManager()
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
                                value: "GymLog Team",
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
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
                DataManager.shared.createSampleData(context: viewContext, user: user)
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
                ThemePickerView(themeManager: themeManager)
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
            .background(Color(.systemBackground))
            .cornerRadius(Constants.Layout.cornerRadius)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
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
            .background(Color(.systemBackground))
            .cornerRadius(Constants.Layout.cornerRadius)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}
