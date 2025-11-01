import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var authManager: AuthManager
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        ZStack {
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
        .overlay(
            // Toast уведомление сверху экрана
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Spacer()
                        ToastView(message: toastManager.message, isShowing: $toastManager.isShowing)
                        Spacer()
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 16)
                    Spacer()
                }
            }
            .allowsHitTesting(false), // Позволяет нажатиям проходить сквозь overlay
            alignment: .top
        )
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return ContentView(authManager: authManager)
        .environment(\.managedObjectContext, context)
        .environmentObject(ToastManager())
}
