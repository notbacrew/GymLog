//
//  ThemeManager.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme?
    
    init() {
        loadTheme()
    }
    
    func setTheme(_ theme: AppTheme) {
        switch theme {
        case .system:
            colorScheme = nil
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        }
        
        UserDefaults.standard.set(theme.rawValue, forKey: "app_theme")
    }
    
    func loadTheme() {
        let themeRawValue = UserDefaults.standard.string(forKey: "app_theme") ?? AppTheme.system.rawValue
        if let theme = AppTheme(rawValue: themeRawValue) {
            setTheme(theme)
        }
    }
    
    var currentTheme: AppTheme {
        switch colorScheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .none:
            return .system
        @unknown default:
            return .system
        }
    }
}

enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system:
            return "Системная"
        case .light:
            return "Светлая"
        case .dark:
            return "Темная"
        }
    }
    
    var icon: String {
        switch self {
        case .system:
            return "gear"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

struct ThemePickerView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                Button(action: {
                    themeManager.setTheme(theme)
                }) {
                    HStack {
                        Image(systemName: theme.icon)
                            .foregroundColor(themeManager.currentTheme == theme ? .blue : .secondary)
                            .frame(width: 24)
                        
                        Text(theme.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if themeManager.currentTheme == theme {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.currentTheme == theme ? Color.blue.opacity(0.1) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
}
