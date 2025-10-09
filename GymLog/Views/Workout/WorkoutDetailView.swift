//
//  WorkoutDetailView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct WorkoutDetailView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    let workout: Workout
    
    @State private var showingEditView = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }
    
    var workoutDetails: [WorkoutDetail] {
        guard let details = workout.details?.allObjects as? [WorkoutDetail] else { return [] }
        return details.sorted { ($0.exercise?.name ?? "") < ($1.exercise?.name ?? "") }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок тренировки
                VStack(alignment: .leading, spacing: 12) {
                    Text(dateFormatter.string(from: workout.date ?? Date()))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let notes = workout.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                Divider()
                
                // Статистика тренировки
                VStack(alignment: .leading, spacing: 12) {
                    Text("Статистика тренировки")
                        .font(.headline)
                    
                    let totalSets = workoutDetails.reduce(0) { $0 + $1.sets }
                    let totalReps = workoutDetails.reduce(0) { $0 + $1.reps }
                    let totalWeight = workoutDetails.reduce(0) { $0 + ($1.weight * Double($1.sets)) }
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("\(totalSets)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Подходов")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("\(totalReps)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Повторений")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(String(format: "%.0f", totalWeight))
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Общий вес (кг)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                Divider()
                
                // Список упражнений
                VStack(alignment: .leading, spacing: 12) {
                    Text("Упражнения (\(workoutDetails.count))")
                        .font(.headline)
                    
                    if workoutDetails.isEmpty {
                        Text("В этой тренировке пока нет упражнений")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(workoutDetails, id: \.id) { detail in
                            WorkoutDetailCardView(detail: detail)
                        }
                    }
                }
            }
            .padding()
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
            EditWorkoutView(authManager: authManager, workout: workout)
        }
    }
}

struct WorkoutDetailCardView: View {
    let detail: WorkoutDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Изображение упражнения
                if let imageData = detail.exercise?.image,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 50)
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
            
            // Параметры упражнения
            HStack {
                VStack(alignment: .leading) {
                    Text("Подходы")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(detail.sets)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Повторения")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(detail.reps)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Вес")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", detail.weight)) кг")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            // Комментарий
            if let comment = detail.comment, !comment.isEmpty {
                Text(comment)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let workout = Workout(context: context)
    workout.date = Date()
    workout.notes = "Отличная тренировка!"
    
    return WorkoutDetailView(authManager: AuthManager(context: context), workout: workout)
        .environment(\.managedObjectContext, context)
}
