//
//  ExerciseDetailView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct ExerciseDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let exercise: Exercise
    @State private var showingEditView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Изображение упражнения
                if let imageData = exercise.image,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "dumbbell")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Название и категория
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name ?? "Без названия")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let category = exercise.category {
                            Text(category)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Статистика упражнения
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Статистика")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Всего тренировок")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(exercise.details?.count ?? 0)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Максимальный вес")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", maxWeight)) кг")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // История тренировок
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Последние тренировки")
                            .font(.headline)
                        
                        if let details = exercise.details?.allObjects as? [WorkoutDetail],
                           !details.isEmpty {
                            let sortedDetails = details.sorted { 
                                ($0.workout?.date ?? Date.distantPast) > ($1.workout?.date ?? Date.distantPast)
                            }
                            
                            ForEach(Array(sortedDetails.prefix(5)), id: \.id) { detail in
                                WorkoutDetailRowView(detail: detail)
                            }
                        } else {
                            Text("Пока нет тренировок с этим упражнением")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Редактировать") {
                    showingEditView = true
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditExerciseView(exercise: exercise)
        }
    }
    
    private var maxWeight: Double {
        guard let details = exercise.details?.allObjects as? [WorkoutDetail] else { return 0 }
        return details.compactMap { $0.weight }.max() ?? 0
    }
}

struct WorkoutDetailRowView: View {
    let detail: WorkoutDetail
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dateFormatter.string(from: detail.workout?.date ?? Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(detail.sets) x \(detail.reps) @ \(String(format: "%.1f", detail.weight)) кг")
                    .font(.subheadline)
            }
            
            Spacer()
            
            if let comment = detail.comment, !comment.isEmpty {
                Text(comment)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let exercise = Exercise(context: context)
    exercise.name = "Жим лежа"
    exercise.category = "Грудь"
    
    return ExerciseDetailView(exercise: exercise)
        .environment(\.managedObjectContext, context)
}
