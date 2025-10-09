//
//  AddWorkoutDetailView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct AddWorkoutDetailView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let exercise: Exercise
    let workoutDate: Date
    var onExerciseAdded: (() -> Void)? = nil
    
    @State private var sets: Int16 = 1
    @State private var reps: Int16 = 1
    @State private var weight: Double = 0.0
    @State private var minutes: Int16 = 1
    @State private var comment = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        if let imageData = exercise.image,
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
                            Text(exercise.name ?? "Без названия")
                                .font(.headline)
                            if let category = exercise.category {
                                Text(category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                Section("Параметры") {
                    if exercise.category?.lowercased() == "кардио" {
                        HStack {
                            Text("Минуты")
                            Spacer()
                            Stepper(value: $minutes, in: 1...180) {
                                Text("\(minutes)")
                                    .frame(minWidth: 30)
                            }
                        }
                        
                        HStack {
                            Text("Интенсивность")
                            Spacer()
                            TextField("Легкая", text: .constant("Легкая"))
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .disabled(true)
                        }
                    } else {
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
                }
                
                Section("Комментарий") {
                    TextField("Комментарий (необязательно)", text: $comment, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Добавить упражнение")
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
                    .font(.system(size: 17, weight: .medium))
                }
            }
        }
    }
    
    private func saveWorkoutDetail() {
        guard let user = authManager.currentUser else { return }
        
        withAnimation {
            // Найти или создать тренировку для этой даты
            let workoutRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            workoutRequest.predicate = NSPredicate(format: "date == %@ AND user == %@", workoutDate as NSDate, user)
            
            let workout: Workout
            do {
                let workouts = try viewContext.fetch(workoutRequest)
                if let existingWorkout = workouts.first {
                    workout = existingWorkout
                } else {
                    workout = DataManager.shared.createWorkout(
                        date: workoutDate,
                        notes: nil,
                        user: user,
                        context: viewContext
                    )
                }
            } catch {
                workout = DataManager.shared.createWorkout(
                    date: workoutDate,
                    notes: nil,
                    user: user,
                    context: viewContext
                )
            }
            
            // Создать детали упражнения
            let workoutDetail = WorkoutDetail(context: viewContext)
            workoutDetail.id = UUID()
            
            if exercise.category?.lowercased() == "кардио" {
                workoutDetail.sets = 1  // Для кардио всегда 1 "подход"
                workoutDetail.reps = minutes  // Используем reps для хранения минут
                workoutDetail.weight = 0.0  // Для кардио вес = 0
            } else {
                workoutDetail.sets = sets
                workoutDetail.reps = reps
                workoutDetail.weight = weight
            }
            
            workoutDetail.comment = comment.isEmpty ? nil : comment
            workoutDetail.exercise = exercise
            workoutDetail.workout = workout
            
            do {
                try viewContext.save()
                onExerciseAdded?()
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
    
    return AddWorkoutDetailView(authManager: AuthManager(context: context), exercise: exercise, workoutDate: Date())
        .environment(\.managedObjectContext, context)
}
