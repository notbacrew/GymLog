//
//  ThemeManager.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("app_theme") var appThemeRaw: String = AppTheme.system.rawValue
    @Published var colorScheme: ColorScheme? {
        didSet {
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }
    
    init() {
        loadTheme()
    }
    
    func setTheme(_ theme: AppTheme) {
        appThemeRaw = theme.rawValue
        switch theme {
        case .system:
            colorScheme = nil
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        }
    }
    
    func loadTheme() {
        if let theme = AppTheme(rawValue: appThemeRaw) {
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
    
    // Custom colors - gray for dark
    var backgroundColor: Color {
        if currentTheme == .dark {
            return Color(red: 0.13, green: 0.13, blue: 0.13)
        }
        return Color(.systemBackground)
    }
    
    var cardBackgroundColor: Color {
        if currentTheme == .dark {
            return Color(.secondarySystemGroupedBackground)  // Match Progress page grouped style for dark
        }
        return Color(.systemBackground)
    }
    
    var primaryTextColor: Color {
        if currentTheme == .dark {
            return .white
        }
        return .primary
    }
    
    var secondaryTextColor: Color {
        if currentTheme == .dark {
            return Color.gray.opacity(0.8)
        }
        return .secondary
    }
    
    var accentColor: Color {
        if currentTheme == .dark {
            return Color(red: 0.5, green: 0.5, blue: 0.5)
        }
        return Color.blue
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
            return "iphone"  // Changed to more appropriate system icon
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.stars.fill"  // Updated to stars for better dark theme representation
        }
    }
    
    var description: String? {
        switch self {
        case .system:
            return nil
        case .light:
            return "Яркая тема для дневного использования"
        case .dark:
            return "Темная тема для комфортного просмотра ночью"
        }
    }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}

// Replace the existing ThemePickerView with this improved version
struct ThemePickerView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with illustration
                    VStack(spacing: 12) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 60, weight: .ultraLight))
                            .foregroundColor(themeManager.accentColor)
                            .frame(maxWidth: .infinity)
                        
                        Text("Выберите тему")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.primaryTextColor)
                            .multilineTextAlignment(.center)
                        
                        Text("Настройте внешний вид приложения под себя")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.secondaryTextColor)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Theme options
                    VStack(spacing: 16) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Button(action: {
                                if themeManager.currentTheme != theme {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        themeManager.setTheme(theme)
                                    }
                                }
                            }) {
                                HStack(spacing: 20) {
                                    // Theme icon (without color swatch)
                                    VStack(spacing: 8) {
                                        Image(systemName: theme.icon)
                                            .font(.system(size: 28, weight: .medium))
                                            .foregroundColor(themeManager.currentTheme == theme ? .white : themeManager.primaryTextColor)
                                            .frame(width: 48, height: 48)
                                            .background(
                                                Circle()
                                                    .fill(
                                                        themeManager.currentTheme == theme 
                                                            ? themeManager.accentColor 
                                                            : Color.gray.opacity(0.2)
                                                    )
                                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                            )
                                        // Removed color swatch here
                                    }
                                    
                                    // Description
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(theme.displayName)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(themeManager.currentTheme == theme ? .white : themeManager.primaryTextColor)
                                        
                                        if let description = theme.description {
                                            Text(description)
                                                .font(.system(size: 15, weight: .regular))
                                                .foregroundColor(themeManager.currentTheme == theme ? Color.white.opacity(0.8) : themeManager.secondaryTextColor)
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Selection indicator
                                    if themeManager.currentTheme == theme {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(themeManager.accentColor)
                                            .scaleEffect(1.1)
                                            .animation(.easeInOut(duration: 0.2), value: themeManager.currentTheme)
                                    } else {
                                        Image(systemName: "circle")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(Color.gray.opacity(0.3))
                                    }
                                }
                                .padding(24)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            themeManager.currentTheme == theme 
                                                ? themeManager.accentColor.opacity(0.1)
                                                : themeManager.cardBackgroundColor
                                        )
                                        .shadow(
                                            color: (themeManager.currentTheme == theme ? themeManager.accentColor : .black).opacity(0.1), 
                                            radius: 8, 
                                            x: 0, 
                                            y: 4
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .animation(.easeInOut(duration: 0.2), value: themeManager.currentTheme)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Removed footer
                }
                .padding(.bottom, 40)
            }
            .background(themeManager.backgroundColor.ignoresSafeArea())
            .navigationTitle("Выбор темы")
            .navigationBarTitleDisplayMode(.inline)
            // Removed toolbar
        }
    }
    
    // Helper to get representative color for theme (can be removed if not used, but keeping for now)
    private func themeColor(for theme: AppTheme) -> Color {
        switch theme {
        case .light:
            return Color.blue.opacity(0.1)
        case .dark:
            return Color.gray.opacity(0.3)
        case .system:
            return Color.gray.opacity(0.2)
        }
    }
}
