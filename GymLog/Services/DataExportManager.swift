//
//  DataExportManager.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import Foundation
import CoreData
import SwiftUI
import UniformTypeIdentifiers

struct DataExportManager {
    
    // MARK: - Export to JSON
    
    static func exportToJSON(context: NSManagedObjectContext) -> URL? {
        var exportData = ExportData()
        
        // Экспорт упражнений
        let exerciseRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        if let exercises = try? context.fetch(exerciseRequest) {
            exportData.exercises = exercises.map { exercise in
                ExportExercise(
                    id: exercise.id?.uuidString ?? UUID().uuidString,
                    name: exercise.name ?? "",
                    category: exercise.category ?? "",
                    image: exercise.image?.base64EncodedString(),
                    timestamp: exercise.timestamp ?? Date()
                )
            }
        }
        
        // Экспорт тренировок
        let workoutRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        workoutRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
        
        if let workouts = try? context.fetch(workoutRequest) {
            exportData.workouts = workouts.map { workout in
                let details = (workout.details?.allObjects as? [WorkoutDetail]) ?? []
                
                return ExportWorkout(
                    id: workout.id?.uuidString ?? UUID().uuidString,
                    date: workout.date ?? Date(),
                    notes: workout.notes,
                    details: details.map { detail in
                        ExportWorkoutDetail(
                            id: detail.id?.uuidString ?? UUID().uuidString,
                            exerciseId: detail.exercise?.id?.uuidString ?? "",
                            sets: detail.sets,
                            reps: detail.reps,
                            weight: detail.weight,
                            comment: detail.comment
                        )
                    }
                )
            }
        }
        
        // Создание JSON файла
        do {
            let jsonData = try JSONEncoder().encode(exportData)
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "GymLog_Export_\(DateFormatter.short.string(from: Date())).json"
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            print("Ошибка экспорта: \(error)")
            return nil
        }
    }
    
    // MARK: - Import from JSON
    
    static func importFromJSON(url: URL, context: NSManagedObjectContext) -> Bool {
        do {
            let jsonData = try Data(contentsOf: url)
            let exportData = try JSONDecoder().decode(ExportData.self, from: jsonData)
            
            // Очистка существующих данных
            clearAllData(context: context)
            
            // Импорт упражнений
            var exerciseMap: [String: Exercise] = [:]
            for exportExercise in exportData.exercises {
                let exercise = Exercise(context: context)
                exercise.id = UUID(uuidString: exportExercise.id) ?? UUID()
                exercise.name = exportExercise.name
                exercise.category = exportExercise.category
                exercise.timestamp = exportExercise.timestamp
                
                if let imageBase64 = exportExercise.image,
                   let imageData = Data(base64Encoded: imageBase64) {
                    exercise.image = imageData
                }
                
                exerciseMap[exportExercise.id] = exercise
            }
            
            // Импорт тренировок
            for exportWorkout in exportData.workouts {
                let workout = Workout(context: context)
                workout.id = UUID(uuidString: exportWorkout.id) ?? UUID()
                workout.date = exportWorkout.date
                workout.notes = exportWorkout.notes
                
                // Импорт деталей тренировки
                for exportDetail in exportWorkout.details {
                    let detail = WorkoutDetail(context: context)
                    detail.id = UUID(uuidString: exportDetail.id) ?? UUID()
                    detail.sets = exportDetail.sets
                    detail.reps = exportDetail.reps
                    detail.weight = exportDetail.weight
                    detail.comment = exportDetail.comment
                    detail.workout = workout
                    
                    if let exercise = exerciseMap[exportDetail.exerciseId] {
                        detail.exercise = exercise
                    }
                }
            }
            
            try context.save()
            return true
        } catch {
            print("Ошибка импорта: \(error)")
            return false
        }
    }
    
    // MARK: - Clear All Data
    
    static func clearAllData(context: NSManagedObjectContext) {
        // Удаление деталей тренировок
        let detailRequest: NSFetchRequest<WorkoutDetail> = WorkoutDetail.fetchRequest()
        if let details = try? context.fetch(detailRequest) {
            for detail in details {
                context.delete(detail)
            }
        }
        
        // Удаление тренировок
        let workoutRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        if let workouts = try? context.fetch(workoutRequest) {
            for workout in workouts {
                context.delete(workout)
            }
        }
        
        // Удаление упражнений
        let exerciseRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        if let exercises = try? context.fetch(exerciseRequest) {
            for exercise in exercises {
                context.delete(exercise)
            }
        }
        
        try? context.save()
    }
    
    // MARK: - Share Sheet
    
    static func shareSheet(for url: URL) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // Настройка для iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = UIApplication.shared.windows.first
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return activityViewController
    }
}

// MARK: - Export Data Models

struct ExportData: Codable {
    let version: String = "1.0"
    let exportDate: Date = Date()
    var exercises: [ExportExercise] = []
    var workouts: [ExportWorkout] = []
}

struct ExportExercise: Codable {
    let id: String
    let name: String
    let category: String
    let image: String?
    let timestamp: Date
}

struct ExportWorkout: Codable {
    let id: String
    let date: Date
    let notes: String?
    let details: [ExportWorkoutDetail]
}

struct ExportWorkoutDetail: Codable {
    let id: String
    let exerciseId: String
    let sets: Int16
    let reps: Int16
    let weight: Double
    let comment: String?
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.selectedURL = url
            }
            parent.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}
