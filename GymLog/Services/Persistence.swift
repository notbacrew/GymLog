//
//  Persistence.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Создаем тестовые данные для предварительного просмотра
        let exercise1 = Exercise(context: viewContext)
        exercise1.id = UUID()
        exercise1.name = "Жим лежа"
        exercise1.category = "Грудь"
        exercise1.timestamp = Date()
        
        let exercise2 = Exercise(context: viewContext)
        exercise2.id = UUID()
        exercise2.name = "Приседания"
        exercise2.category = "Ноги"
        exercise2.timestamp = Date()
        
        let workout = Workout(context: viewContext)
        workout.id = UUID()
        workout.date = Date()
        workout.notes = "Тестовая тренировка"
        
        let detail = WorkoutDetail(context: viewContext)
        detail.id = UUID()
        detail.sets = 3
        detail.reps = 10
        detail.weight = 80.0
        detail.exercise = exercise1
        detail.workout = workout
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GymLog")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
