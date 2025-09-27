//
//  AddExerciseView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData
import PhotosUI

struct AddExerciseView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var category = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingImagePicker = false
    
    private let categories = ["Грудь", "Спина", "Ноги", "Плечи", "Руки", "Пресс", "Кардио"]
    
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
            .navigationTitle("Новое упражнение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveExercise()
                    }
                    .disabled(name.isEmpty || category.isEmpty)
                }
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
        guard let user = authManager.currentUser else { return }
        
        withAnimation {
            let newExercise = DataManager.shared.createExercise(
                name: name,
                category: category,
                image: imageData,
                user: user,
                context: viewContext
            )
            
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
    let authManager = AuthManager(context: context)
    return AddExerciseView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}
