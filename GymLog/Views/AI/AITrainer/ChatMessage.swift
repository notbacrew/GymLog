//
//  ChatMessage.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import Foundation

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let messageType: MessageType
    
    enum MessageType: String, Codable {
        case text = "text"
        case insight = "insight"
        case recommendation = "recommendation"
        case workoutPlan = "workoutPlan"
        case analysis = "analysis"
    }
    
    init(content: String, isUser: Bool, messageType: MessageType = .text) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.messageType = messageType
    }
}

// MARK: - Sample Messages
extension ChatMessage {
    static let welcomeMessage = ChatMessage(
        content: "Привет! Я твой персональный AI-тренер. Готов помочь с тренировками, анализом прогресса и мотивацией! 💪",
        isUser: false,
        messageType: .text
    )
    
    static let quickActions = [
        "Анализ недели",
        "Следующая тренировка", 
        "Почему не растет?",
        "Совет по питанию",
        "Мотивация"
    ]
}
