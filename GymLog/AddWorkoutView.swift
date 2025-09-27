//
//  AddWorkoutView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct AddWorkoutView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutDate = Date()
    @State private var notes = ""
    @State private var selectedExercises: Set<Exercise> = []
    @State private var showingExercisePicker = false
    
    @FetchRequest private var workoutDetails: FetchedResults<WorkoutDetail>
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        self._workoutDetails = FetchRequest<WorkoutDetail>(
            sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutDetail.exercise?.name, ascending: true)]
        )
    }
    
    private var currentWorkoutDetails: [WorkoutDetail] {
        guard let user = authManager.currentUser else { return [] }
        return workoutDetails.filter { detail in
            detail.workout?.user == user &&
            Calendar.current.isDate(detail.workout?.date ?? Date.distantPast, inSameDayAs: workoutDate)
        }
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)],
        animation: .default)
    private var exercises: FetchedResults<Exercise>
    
    var body: some View {
        NavigationView {
            Form {
                Section("Дата тренировки") {
                    DatePicker("Дата", selection: $workoutDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Заметки") {
                    TextField("Заметки к тренировке (необязательно)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Упражнения") {
                    // Показываем добавленные упражнения с деталями
                    ForEach(currentWorkoutDetails, id: \.id) { detail in
                            NavigationLink(destination: AddWorkoutDetailView(authManager: authManager, exercise: detail.exercise!, workoutDate: workoutDate, onExerciseAdded: {
                                // Удаляем упражнение из selectedExercises после добавления деталей
                                selectedExercises.remove(detail.exercise!)
                            })) {
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
                                    if let category = detail.exercise?.category {
                                        Text(category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("\(detail.sets) x \(detail.reps)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if detail.weight > 0 {
                                        Text("\(Int(detail.weight)) кг")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Показываем выбранные упражнения без деталей
                    ForEach(Array(selectedExercises), id: \.id) { exercise in
                        // Проверяем, не добавлено ли уже это упражнение
                        if !currentWorkoutDetails.contains(where: { $0.exercise == exercise }) {
                            NavigationLink(destination: AddWorkoutDetailView(authManager: authManager, exercise: exercise, workoutDate: workoutDate, onExerciseAdded: {
                                // Удаляем упражнение из selectedExercises после добавления деталей
                                selectedExercises.remove(exercise)
                            })) {
                                HStack {
                                    if let imageData = exercise.image,
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
                                        Text(exercise.name ?? "Без названия")
                                            .font(.headline)
                                        if let category = exercise.category {
                                            Text(category)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("Нажмите для добавления деталей")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    Button("Добавить упражнения") {
                        showingExercisePicker = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Новая тренировка")
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
                    .disabled(selectedExercises.isEmpty)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(authManager: authManager, selectedExercises: $selectedExercises)
            }
        }
    }
    
    private func saveWorkout() {
        guard let user = authManager.currentUser else { return }
        
        withAnimation {
            // Найти существующую тренировку или создать новую
            let workoutRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            workoutRequest.predicate = NSPredicate(format: "date == %@ AND user == %@", workoutDate as NSDate, user)
            
            let workout: Workout
            do {
                let workouts = try viewContext.fetch(workoutRequest)
                if let existingWorkout = workouts.first {
                    workout = existingWorkout
                    workout.notes = notes.isEmpty ? nil : notes
                } else {
                    workout = DataManager.shared.createWorkout(
                        date: workoutDate,
                        notes: notes.isEmpty ? nil : notes,
                        user: user,
                        context: viewContext
                    )
                }
            } catch {
                workout = DataManager.shared.createWorkout(
                    date: workoutDate,
                    notes: notes.isEmpty ? nil : notes,
                    user: user,
                    context: viewContext
                )
            }
            
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

struct ExercisePickerView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedExercises: Set<Exercise>
    
    private var exercises: [Exercise] {
        guard let user = authManager.currentUser else { return [] }
        return (user.exercises?.allObjects as? [Exercise])?.sorted { 
            ($0.name ?? "") < ($1.name ?? "") 
        } ?? []
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(exercises, id: \.id) { exercise in
                    Button(action: {
                        if selectedExercises.contains(exercise) {
                            selectedExercises.remove(exercise)
                        } else {
                            selectedExercises.insert(exercise)
                        }
                    }) {
                        HStack {
                            if let imageData = exercise.image,
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
                                Text(exercise.name ?? "Без названия")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                if let category = exercise.category {
                                    Text(category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedExercises.contains(exercise) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Выберите упражнения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return AddWorkoutView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}
