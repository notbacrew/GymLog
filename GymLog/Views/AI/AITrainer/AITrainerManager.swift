//
//  AITrainerManager.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import Foundation
import CoreData
import Combine

class AITrainerManager: ObservableObject {
    // MARK: - Published Properties
    @Published var messages: [ChatMessage] = []
    @Published var insights: [AIInsight] = []
    @Published var isLoading = false
    
    // MARK: - Private Properties
    private let aiService = AITrainerService()
    private let context: NSManagedObjectContext
    private let authManager: AuthManager
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext, authManager: AuthManager) {
        self.context = context
        self.authManager = authManager
        setupInitialMessages()
        loadInsights()
    }
    
    // MARK: - Public Methods
    
    func sendMessage(_ content: String) {
        // Add user message
        let userMessage = ChatMessage(content: content, isUser: true)
        messages.append(userMessage)
        
        // Show loading
        isLoading = true
        
        // Get user context
        let userContext = buildUserContext()
        
        // Send to AI service
        Task {
            let response = await aiService.sendMessage(content, context: userContext)
            
            await MainActor.run {
                let aiMessage = ChatMessage(content: response, isUser: false)
                messages.append(aiMessage)
                isLoading = false
            }
        }
    }
    
    func sendQuickMessage(_ action: String) {
        let quickMessages = [
            "Анализ недели": "Проанализируй мои тренировки за последнюю неделю",
            "Следующая тренировка": "Что мне делать на следующей тренировке?",
            "Почему не растет?": "Почему у меня не растет жим лежа?",
            "Совет по питанию": "Дай совет по питанию для набора массы",
            "Мотивация": "Мне нужна мотивация для тренировок"
        ]
        
        if let message = quickMessages[action] {
            sendMessage(message)
        }
    }
    
    func generateInsights() {
        Task {
            let userContext = buildUserContext()
            let newInsights = await aiService.analyzeProgress(workouts: getRecentWorkouts())
            
            await MainActor.run {
                insights.append(contentsOf: newInsights)
                saveInsights()
            }
        }
    }
    
    func markInsightAsRead(_ insight: AIInsight) {
        if let index = insights.firstIndex(where: { $0.id == insight.id }) {
            // Note: In a real implementation, you'd need to make AIInsight mutable
            // or use a different approach for tracking read status
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialMessages() {
        messages = [ChatMessage.welcomeMessage]
    }
    
    private func buildUserContext() -> UserContext {
        let user = authManager.currentUser
        let recentWorkouts = getRecentWorkouts()
        
        return UserContext(
            fitnessLevel: "Средний", // TODO: Get from user profile
            goals: ["Набор массы", "Увеличение силы"], // TODO: Get from user settings
            experience: 12, // TODO: Calculate from first workout
            preferences: ["Тренировки в зале", "3 раза в неделю"], // TODO: Get from settings
            recentWorkouts: recentWorkouts
        )
    }
    
    private func getRecentWorkouts() -> [Workout] {
        guard let user = authManager.currentUser else { return [] }
        
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
        request.fetchLimit = 10
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching recent workouts: \(error)")
            return []
        }
    }
    
    private func loadInsights() {
        // TODO: Load from Core Data or UserDefaults
        insights = AIInsight.sampleInsights
    }
    
    private func saveInsights() {
        // TODO: Save to Core Data or UserDefaults
    }
}

// MARK: - Extensions
extension AITrainerManager {
    var unreadInsightsCount: Int {
        insights.filter { !$0.isRead }.count
    }
    
    var highPriorityInsights: [AIInsight] {
        insights.filter { $0.priority == .high }
    }
}
