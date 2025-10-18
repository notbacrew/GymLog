//
//  EditExerciseView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData
import PhotosUI

struct EditExerciseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let exercise: Exercise
    
    @State private var name: String
    @State private var category: String
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingDeleteAlert = false
    
    private let categories = ["Грудь", "Спина", "Ноги", "Плечи", "Руки", "Пресс", "Кардио"]
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self._name = State(initialValue: exercise.name ?? "")
        self._category = State(initialValue: exercise.category ?? "")
        self._imageData = State(initialValue: exercise.image)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название упражнения", text: $name)
                    
                    Picker("Категория", selection: $category) {
                        Text("Выберите категорию").tag("")
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section("Изображение") {
                    VStack {
                        if let imageData = imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .frame(height: 200)
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.largeTitle)
                                            .foregroundColor(.gray)
                                        Text("Добавить фото")
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                        
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            Text("Выбрать фото")
                        }
                        .buttonStyle(.bordered)
                        
                        if imageData != nil {
                            Button("Удалить фото") {
                                imageData = nil
                                selectedImage = nil
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Редактировать упражнение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Сохранить") {
                            saveExercise()
                        }
                        .disabled(name.isEmpty || category.isEmpty)
                        
                        Button("Удалить", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .alert("Удалить упражнение?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    deleteExercise()
                }
            } message: {
                Text("Это действие необратимо удалит упражнение '\(exercise.name ?? "")'.")
            }
        }
        .onChange(of: selectedImage) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
    
    private func saveExercise() {
        withAnimation {
            exercise.name = name
            exercise.category = category
            exercise.image = imageData
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteExercise() {
        withAnimation {
            viewContext.delete(exercise)
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let exercise = Exercise(context: context)
    exercise.name = "Жим лежа"
    exercise.category = "Грудь"
    
    return EditExerciseView(exercise: exercise)
        .environment(\.managedObjectContext, context)
}
