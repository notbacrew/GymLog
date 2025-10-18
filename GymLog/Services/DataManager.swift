//
//  DataManager.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    // MARK: - Exercise Management
    
    func createExercise(name: String, category: String, image: Data? = nil, user: User, context: NSManagedObjectContext) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.name = name
        exercise.category = category
        exercise.image = image
        exercise.timestamp = Date()
        exercise.user = user
        return exercise
    }
    
    func deleteExercise(_ exercise: Exercise, context: NSManagedObjectContext) {
        context.delete(exercise)
        saveContext(context)
    }
    
    // MARK: - Workout Management
    
    func createWorkout(date: Date, notes: String? = nil, user: User, context: NSManagedObjectContext) -> Workout {
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.date = date
        workout.notes = notes
        workout.user = user
        return workout
    }
    
    func deleteWorkout(_ workout: Workout, context: NSManagedObjectContext) {
        context.delete(workout)
        saveContext(context)
    }
    
    // MARK: - Workout Detail Management
    
    func createWorkoutDetail(exercise: Exercise, workout: Workout, sets: Int16, reps: Int16, weight: Double, comment: String? = nil, context: NSManagedObjectContext) -> WorkoutDetail {
        let detail = WorkoutDetail(context: context)
        detail.id = UUID()
        detail.exercise = exercise
        detail.workout = workout
        detail.sets = sets
        detail.reps = reps
        detail.weight = weight
        detail.comment = comment
        return detail
    }
    
    func deleteWorkoutDetail(_ detail: WorkoutDetail, context: NSManagedObjectContext) {
        context.delete(detail)
        saveContext(context)
    }
    
    // MARK: - Statistics
    
    func getWorkoutStats(for workouts: [Workout]) -> (totalSets: Int, totalReps: Int, totalWeight: Double, workoutCount: Int) {
        var totalSets = 0
        var totalReps = 0
        var totalWeight = 0.0
        
        for workout in workouts {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    totalSets += Int(detail.sets)
                    totalReps += Int(detail.reps)
                    totalWeight += detail.weight * Double(detail.sets)
                }
            }
        }
        
        return (totalSets, totalReps, totalWeight, workouts.count)
    }
    
    func getExerciseProgress(for exercise: Exercise, workouts: [Workout]) -> [(date: Date, weight: Double)] {
        var progressData: [(date: Date, weight: Double)] = []
        
        for workout in workouts {
            if let details = workout.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    if detail.exercise?.id == exercise.id {
                        progressData.append((date: workout.date ?? Date(), weight: detail.weight))
                    }
                }
            }
        }
        
        return progressData.sorted { $0.date < $1.date }
    }
    
    // MARK: - Helper Methods
    
    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // MARK: - Sample Data
    
    func createSampleData(context: NSManagedObjectContext, user: User) {
        // Создаем примеры упражнений (strength only)
        let exercises = [
            ("Жим лежа", "Грудь"),
            ("Приседания", "Ноги"),
            ("Становая тяга", "Спина"),
            ("Жим стоя", "Плечи"),
            ("Подтягивания", "Спина"),
            ("Отжимания", "Грудь"),
            ("Планка", "Пресс"),
            // Removed ("Бег", "Кардио")
            ("Жим гантелей", "Грудь"),
            ("Тяга верхнего блока", "Спина"),
            ("Разгибание ног", "Ноги"),
            ("Жим гантелей сидя", "Плечи"),
            ("Сгибание рук", "Руки"),
            ("Подъём на бицепс", "Руки"),
            ("Скручивания", "Пресс"),
            ("Жим узким хватом", "Грудь"),
            ("Тяга гантели в наклоне", "Спина"),
            ("Выпады", "Ноги"),
            ("Разведение гантелей", "Плечи"),
            ("Французский жим", "Руки")
        ]
        
        var createdExercises: [Exercise] = []
        
        for (name, category) in exercises {
            let exercise = createExercise(name: name, category: category, user: user, context: context)
            createdExercises.append(exercise)
        }
        
        // Создаем примеры тренировок за последний месяц (30 дней)
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<30 {
            if let workoutDate = calendar.date(byAdding: .day, value: -i, to: today) {
                let workout = createWorkout(date: workoutDate, notes: i % 7 == 0 ? "Тренировка фокус на \(i + 1) день" : nil, user: user, context: context)
                
                // Добавляем 3-6 случайных упражнений в тренировку
                let randomExercises = createdExercises.shuffled().prefix(Int.random(in: 3...6))
                
                for exercise in randomExercises {
                    let sets = Int16.random(in: 2...5)
                    let reps = Int16.random(in: 8...15)
                    let weight = Double.random(in: 20...150)
                    
                    _ = createWorkoutDetail(
                        exercise: exercise,
                        workout: workout,
                        sets: sets,
                        reps: reps,
                        weight: weight,
                        comment: Int.random(in: 0...9) < 3 ? "Хорошая серия" : nil,  // 30% with notes
                        context: context
                    )
                }
            }
        }
        
        saveContext(context)
    }
}
