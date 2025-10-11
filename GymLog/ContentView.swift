//
//  ContentView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            HomeView(authManager: authManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
            
            WorkoutListView(authManager: authManager)
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Тренировки")
                }
            
            ExerciseListView(authManager: authManager)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Упражнения")
                }
            
            ProgressStatsView(authManager: authManager)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Прогресс")
                }
            
            ProfileView(authManager: authManager)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Профиль")
                }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return ContentView(authManager: authManager)
        .environment(\.managedObjectContext, context)
}
