//
//  ExerciseListView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct ExerciseListView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    
    private var exercises: [Exercise] {
        guard let user = authManager.currentUser else { return [] }
        return (user.exercises?.allObjects as? [Exercise])?.sorted { 
            ($0.name ?? "") < ($1.name ?? "") 
        } ?? []
    }
    
    @State private var showingAddExercise = false
    @State private var searchText = ""
    @State private var selectedCategory = "Все"
    
    private let categories = ["Все"] + Constants.exerciseCategories  // All + strength categories only
    
    var filteredExercises: [Exercise] {
        let filtered = exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty || 
                exercise.name?.localizedCaseInsensitiveContains(searchText) == true
            let matchesCategory = selectedCategory == "Все" || 
                exercise.category == selectedCategory
            return matchesSearch && matchesCategory
        }
        return Array(filtered)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поиск и фильтры
                VStack(spacing: 16) {
                    // Поиск
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Поиск упражнений", text: $searchText)
                            .font(.system(size: 16, weight: .regular))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Кнопка выбора категории
                    HStack {
                        Picker("Категория", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.quaternary, lineWidth: 0.5)
                                )
                        )
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(ThemeManager.shared.cardBackgroundColor)
                
                // Список упражнений
                if filteredExercises.isEmpty {
                    // Watermark в центре экрана
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "dumbbell")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.secondary)
                        
                        Text("Упражнения не найдены")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Попробуйте изменить поисковый запрос или категорию")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredExercises, id: \.id) { exercise in
                            NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                ExerciseRowView(exercise: exercise)
                            }
                        }
                        .onDelete(perform: deleteExercises)
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewContext.refreshAllObjects()
                    }
                    .background(Color.clear)
                    .listRowSpacing(12)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
            .navigationTitle("Упражнения")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExercise = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView(authManager: authManager)
        }
    }
        .background(ThemeManager.shared.backgroundColor.ignoresSafeArea())
        .listRowBackground(ThemeManager.shared.cardBackgroundColor)  // Gray rows
    }
    
    private func deleteExercises(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredExercises[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка упражнения
            if let imageData = exercise.image,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "dumbbell")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.name ?? "Без названия")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                if let category = exercise.category {
                    Text(category)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(ThemeManager.shared.cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return ExerciseListView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}
