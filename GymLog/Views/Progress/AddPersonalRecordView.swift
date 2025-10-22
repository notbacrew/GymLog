//
//  AddPersonalRecordView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct AddPersonalRecordView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseName = ""
    @State private var weight = 0.0
    @State private var date = Date()
    @State private var notes = ""
    
    private var exercises: [Exercise] {
        guard let user = authManager.currentUser else { return [] }
        return (user.exercises?.allObjects as? [Exercise])?.sorted { 
            ($0.name ?? "") < ($1.name ?? "") 
        } ?? []
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Упражнение")) {
                    Picker("Выберите упражнение", selection: $exerciseName) {
                        Text("Выберите упражнение").tag("")
                        ForEach(exercises, id: \.id) { exercise in
                            Text(exercise.name ?? "Без названия").tag(exercise.name ?? "")
                        }
                    }
                }
                
                Section(header: Text("Рекорд")) {
                    HStack {
                        Text("Вес")
                        Spacer()
                        TextField("0.0", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("кг")
                            .foregroundColor(.secondary)
                    }
                    
                    DatePicker("Дата установки", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Заметки (необязательно)")) {
                    TextField("Добавьте заметку...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Новый рекорд")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveRecord()
                    }
                    .disabled(exerciseName.isEmpty || weight <= 0)
                }
            }
        }
    }
    
    private func saveRecord() {
        guard let userId = authManager.currentUser?.id?.uuidString else { return }
        
        let record = PersonalRecord(
            exerciseName: exerciseName,
            weight: weight,
            date: date,
            notes: notes.isEmpty ? nil : notes
        )
        
        PersonalRecordManager.shared.addRecord(record, for: userId)
        dismiss()
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return AddPersonalRecordView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}
