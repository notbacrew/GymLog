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
    
    private let categories = ["Все", "Грудь", "Спина", "Ноги", "Плечи", "Руки", "Пресс", "Кардио"]
    
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
                    
                    // Категории
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "tag")
                                            .font(.system(size: 12, weight: .medium))
                                        
                                        Text(category)
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(selectedCategory == category ? .blue : .secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedCategory == category ? Color.blue.opacity(0.1) : Color(.systemGray5))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .background(Color(.systemGroupedBackground))
                
                // Список упражнений
                if filteredExercises.isEmpty {
                    VStack(spacing: 16) {
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredExercises, id: \.id) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    ExerciseRowView(exercise: exercise)
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
                    .background(Color(.systemGroupedBackground))
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
        .background(Color(.systemBackground))
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
