//
//  Constants.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import Foundation
import SwiftUI

struct Constants {
    
    // MARK: - Exercise Categories
    static let exerciseCategories = [
        "Грудь",
        "Спина", 
        "Ноги",
        "Плечи",
        "Руки",
        "Пресс",
        "Кардио"
    ]
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
        
        // Category colors
        static let chest = Color.red
        static let back = Color.blue
        static let legs = Color.green
        static let shoulders = Color.orange
        static let arms = Color.purple
        static let abs = Color.yellow
        static let cardio = Color.pink
    }
    
    // MARK: - Icons
    struct Icons {
        static let dumbbell = "dumbbell.fill"
        static let list = "list.bullet"
        static let chart = "chart.line.uptrend.xyaxis"
        static let plus = "plus"
        static let edit = "pencil"
        static let delete = "trash"
        static let photo = "photo"
        static let camera = "camera"
        static let calendar = "calendar"
        static let clock = "clock"
        static let weight = "scalemass"
        static let repeatIcon = "repeat"
        static let arrowClockwise = "arrow.clockwise"
    }
    
    // MARK: - Layout
    struct Layout {
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let imageSize: CGFloat = 50
        static let smallImageSize: CGFloat = 40
    }
    
    // MARK: - Limits
    struct Limits {
        static let maxSets = 20
        static let maxReps = 100
        static let maxWeight: Double = 500.0
        static let minWeight: Double = 0.0
        static let maxNotesLength = 500
        static let maxExerciseNameLength = 100
    }
    
    // MARK: - Date Formats
    struct DateFormats {
        static let full = "EEEE, d MMMM yyyy 'в' HH:mm"
        static let medium = "d MMMM yyyy"
        static let short = "dd.MM.yyyy"
        static let time = "HH:mm"
        static let chart = "dd.MM"
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormats.full
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    static let medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormats.medium
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormats.short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormats.time
        return formatter
    }()
    
    static let chart: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormats.chart
        return formatter
    }()
}

extension Color {
    static func categoryColor(for category: String) -> Color {
        switch category {
        case "Грудь":
            return Constants.Colors.chest
        case "Спина":
            return Constants.Colors.back
        case "Ноги":
            return Constants.Colors.legs
        case "Плечи":
            return Constants.Colors.shoulders
        case "Руки":
            return Constants.Colors.arms
        case "Пресс":
            return Constants.Colors.abs
        case "Кардио":
            return Constants.Colors.cardio
        default:
            return Constants.Colors.secondary
        }
    }
}
