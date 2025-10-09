//
//  AIInsight.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import Foundation

struct AIInsight: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let type: InsightType
    let priority: Priority
    let timestamp: Date
    let isRead: Bool
    
    enum InsightType: String, Codable, CaseIterable {
        case progress = "progress"
        case warning = "warning"
        case recommendation = "recommendation"
        case achievement = "achievement"
        case nutrition = "nutrition"
        case recovery = "recovery"
        
        var icon: String {
            switch self {
            case .progress: return "chart.line.uptrend.xyaxis"
            case .warning: return "exclamationmark.triangle"
            case .recommendation: return "lightbulb"
            case .achievement: return "trophy"
            case .nutrition: return "fork.knife"
            case .recovery: return "bed.double"
            }
        }
        
        var color: String {
            switch self {
            case .progress: return "green"
            case .warning: return "orange"
            case .recommendation: return "blue"
            case .achievement: return "yellow"
            case .nutrition: return "purple"
            case .recovery: return "cyan"
            }
        }
    }
    
    enum Priority: String, Codable, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        
        var displayName: String {
            switch self {
            case .low: return "Низкий"
            case .medium: return "Средний"
            case .high: return "Высокий"
            }
        }
    }
    
    init(title: String, description: String, type: InsightType, priority: Priority = .medium) {
        self.title = title
        self.description = description
        self.type = type
        self.priority = priority
        self.timestamp = Date()
        self.isRead = false
    }
}

// MARK: - Sample Insights
extension AIInsight {
    static let sampleInsights = [
        AIInsight(
            title: "Отличный прогресс!",
            description: "За последнюю неделю ваш объем тренировок вырос на 15%. Продолжайте в том же духе!",
            type: .progress,
            priority: .high
        ),
        AIInsight(
            title: "Время увеличить вес",
            description: "В жиме лежа вы легко делаете 8 повторений с текущим весом. Попробуйте добавить 2.5кг.",
            type: .recommendation,
            priority: .medium
        ),
        AIInsight(
            title: "Не забывайте про восстановление",
            description: "Вы тренировались 6 дней подряд. Рекомендую день отдыха для оптимального роста.",
            type: .recovery,
            priority: .high
        )
    ]
}
