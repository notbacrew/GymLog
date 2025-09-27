//
//  GymLogApp.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

@main
struct GymLogApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authManager: AuthManager

    init() {
        let context = persistenceController.container.viewContext
        _authManager = StateObject(wrappedValue: AuthManager(context: context))
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView(authManager: authManager)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .preferredColorScheme(themeManager.colorScheme)
            } else {
                WelcomeView(authManager: authManager)
                    .preferredColorScheme(themeManager.colorScheme)
            }
        }
    }
}
