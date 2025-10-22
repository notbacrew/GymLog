//
//  EditPersonalRecordView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct EditPersonalRecordView: View {
    let record: PersonalRecord
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var weight: Double
    @State private var date: Date
    @State private var notes: String
    
    init(record: PersonalRecord, authManager: AuthManager) {
        self.record = record
        self.authManager = authManager
        self._weight = State(initialValue: record.weight)
        self._date = State(initialValue: record.date)
        self._notes = State(initialValue: record.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Упражнение")) {
                    HStack {
                        Text("Название")
                        Spacer()
                        Text(record.exerciseName)
                            .foregroundColor(.secondary)
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
                
                Section(header: Text("Заметки")) {
                    TextField("Добавьте заметку...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button("Удалить рекорд") {
                        deleteRecord()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Редактировать рекорд")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        updateRecord()
                    }
                    .disabled(weight <= 0)
                }
            }
        }
    }
    
    private func updateRecord() {
        guard let userId = authManager.currentUser?.id?.uuidString else { return }
        
        let updatedRecord = PersonalRecord(
            id: record.id,
            exerciseName: record.exerciseName,
            weight: weight,
            date: date,
            notes: notes.isEmpty ? nil : notes
        )
        
        PersonalRecordManager.shared.updateRecord(updatedRecord, for: userId)
        dismiss()
    }
    
    private func deleteRecord() {
        guard let userId = authManager.currentUser?.id?.uuidString else { return }
        
        PersonalRecordManager.shared.deleteRecord(record, for: userId)
        dismiss()
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    let record = PersonalRecord(exerciseName: "Жим лежа", weight: 100.0, date: Date(), notes: "Отличный результат!")
    return EditPersonalRecordView(record: record, authManager: authManager)
        .environment(\.managedObjectContext, context)
}
