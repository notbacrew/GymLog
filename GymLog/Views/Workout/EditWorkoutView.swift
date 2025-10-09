//
//  EditWorkoutView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct EditWorkoutView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let workout: Workout
    
    @State private var workoutDate: Date
    @State private var notes: String
    
    init(authManager: AuthManager, workout: Workout) {
        self.authManager = authManager
        self.workout = workout
        self._workoutDate = State(initialValue: workout.date ?? Date())
        self._notes = State(initialValue: workout.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Дата тренировки") {
                    DatePicker("Дата", selection: $workoutDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Заметки") {
                    TextField("Заметки к тренировке", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Упражнения") {
                    if let details = workout.details?.allObjects as? [WorkoutDetail],
                       !details.isEmpty {
                        ForEach(details.sorted { ($0.exercise?.name ?? "") < ($1.exercise?.name ?? "") }, id: \.id) { detail in
                            NavigationLink(destination: EditWorkoutDetailView(authManager: authManager, detail: detail)) {
                                HStack {
                                    if let imageData = detail.exercise?.image,
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 40, height: 40)
                                            .clipped()
                                            .cornerRadius(6)
                                    } else {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(.systemGray5))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "dumbbell")
                                                    .foregroundColor(.gray)
                                            )
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(detail.exercise?.name ?? "Без названия")
                                            .font(.headline)
                                        Text("\(detail.sets) x \(detail.reps) @ \(String(format: "%.1f", detail.weight)) кг")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .onDelete(perform: deleteWorkoutDetails)
                    } else {
                        Text("Нет упражнений")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: deleteWorkout) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Удалить тренировку")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Редактировать тренировку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveWorkout()
                    }
                }
            }
        }
    }
    
    private func saveWorkout() {
        withAnimation {
            workout.date = workoutDate
            workout.notes = notes.isEmpty ? nil : notes
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteWorkout() {
        withAnimation {
            viewContext.delete(workout)
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteWorkoutDetails(offsets: IndexSet) {
        withAnimation {
            guard let details = workout.details?.allObjects as? [WorkoutDetail] else { return }
            let sortedDetails = details.sorted { ($0.exercise?.name ?? "") < ($1.exercise?.name ?? "") }
            
            offsets.map { sortedDetails[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct EditWorkoutDetailView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let detail: WorkoutDetail
    
    @State private var sets: Int16
    @State private var reps: Int16
    @State private var weight: Double
    @State private var comment: String
    
    init(authManager: AuthManager, detail: WorkoutDetail) {
        self.authManager = authManager
        self.detail = detail
        self._sets = State(initialValue: detail.sets)
        self._reps = State(initialValue: detail.reps)
        self._weight = State(initialValue: detail.weight)
        self._comment = State(initialValue: detail.comment ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        if let imageData = detail.exercise?.image,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "dumbbell")
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        VStack(alignment: .leading) {
                            Text(detail.exercise?.name ?? "Без названия")
                                .font(.headline)
                            if let category = detail.exercise?.category {
                                Text(category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                Section("Параметры") {
                    HStack {
                        Text("Подходы")
                        Spacer()
                        Stepper(value: $sets, in: 1...20) {
                            Text("\(sets)")
                                .frame(minWidth: 30)
                        }
                    }
                    
                    HStack {
                        Text("Повторения")
                        Spacer()
                        Stepper(value: $reps, in: 1...100) {
                            Text("\(reps)")
                                .frame(minWidth: 30)
                        }
                    }
                    
                    HStack {
                        Text("Вес (кг)")
                        Spacer()
                        TextField("0.0", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section("Комментарий") {
                    TextField("Комментарий", text: $comment, axis: .vertical)
                        .lineLimit(2...4)
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
                    Button("Сохранить") {
                        saveWorkoutDetail()
                    }
                }
            }
        }
    }
    
    private func saveWorkoutDetail() {
        withAnimation {
            detail.sets = sets
            detail.reps = reps
            detail.weight = weight
            detail.comment = comment.isEmpty ? nil : comment
            
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
    let workout = Workout(context: context)
    workout.date = Date()
    workout.notes = "Отличная тренировка!"
    
    return EditWorkoutView(authManager: authManager, workout: workout)
        .environment(\.managedObjectContext, context)
}

