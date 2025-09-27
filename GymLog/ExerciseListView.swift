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
            VStack {
                // Фильтры
                VStack(spacing: 12) {
                    // Поиск
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Поиск упражнений", text: $searchText)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Категории
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(selectedCategory == category ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                // Список упражнений
                List {
                    ForEach(filteredExercises, id: \.id) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            ExerciseRowView(exercise: exercise)
                        }
                    }
                    .onDelete(perform: deleteExercises)
                }
                .listStyle(PlainListStyle())
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
        HStack {
            // Иконка упражнения
            if let imageData = exercise.image,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "dumbbell")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name ?? "Без названия")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let category = exercise.category {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return ExerciseListView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}
