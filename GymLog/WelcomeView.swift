//
//  WelcomeView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct WelcomeView: View {
    @ObservedObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var showingRegister = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    private var isLoginButtonDisabled: Bool {
        username.isEmpty || password.isEmpty
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Градиентный фон
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.1),
                            Color.purple.opacity(0.05),
                            Color.blue.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Верхняя секция с логотипом
                        WelcomeHeaderView()
                            .frame(height: geometry.size.height * 0.4)
                        
                        // Форма входа
                        WelcomeFormView(
                            username: $username,
                            password: $password,
                            isLoading: isLoading,
                            isLoginButtonDisabled: isLoginButtonDisabled,
                            onLogin: login,
                            onRegister: { showingRegister = true }
                        )
                        .frame(height: geometry.size.height * 0.6)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingRegister) {
                RegisterView(authManager: authManager)
            }
            .alert("Ошибка входа", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // Удален старый loginButton - теперь используется в WelcomeFormView
    
    private func login() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let result = authManager.login(username: username, password: password)
            
            switch result {
            case .success:
                // Успешный вход - ContentView автоматически покажется
                break
            case .failure(let error):
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            
            isLoading = false
        }
    }
}

#Preview {
    WelcomeView(authManager: AuthManager(context: PersistenceController.preview.container.viewContext))
}

// MARK: - Welcome Header
struct WelcomeHeaderView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)
            
            // Логотип с анимацией
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 15)
                
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Заголовок и описание
            VStack(spacing: 12) {
                Text("GymLog")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Ваш персональный дневник тренировок")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer(minLength: 20)
        }
    }
}

// MARK: - Welcome Form
struct WelcomeFormView: View {
    @Binding var username: String
    @Binding var password: String
    let isLoading: Bool
    let isLoginButtonDisabled: Bool
    let onLogin: () -> Void
    let onRegister: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Карточка с формой
            VStack(spacing: 20) {
                // Заголовок формы
                VStack(spacing: 6) {
                    Text("Добро пожаловать!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Войдите в свой аккаунт")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Поля ввода
                VStack(spacing: 16) {
                    // Поле имени пользователя
                    CustomTextField(
                        title: "Имя пользователя",
                        placeholder: "Введите имя пользователя",
                        text: $username,
                        icon: "person.fill"
                    )
                    
                    // Поле пароля
                    CustomTextField(
                        title: "Пароль",
                        placeholder: "Введите пароль",
                        text: $password,
                        icon: "lock.fill",
                        isSecure: true
                    )
                }
                
                // Кнопка входа
                ModernButton(
                    title: "Войти",
                    icon: "arrow.right.circle.fill",
                    isLoading: isLoading,
                    isDisabled: isLoginButtonDisabled,
                    color: .blue,
                    action: onLogin
                )
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
            .padding(.horizontal, 20)
            
            // Ссылка на регистрацию
            VStack(spacing: 12) {
                Text("Нет аккаунта?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Button(action: onRegister) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 14, weight: .medium))
                        
                        Text("Создать аккаунт")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer(minLength: 20)
        }
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 16, weight: .regular))
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16, weight: .regular))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(text.isEmpty ? Color.clear : Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Modern Button
struct ModernButton: View {
    let title: String
    let icon: String
    let isLoading: Bool
    let isDisabled: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: isDisabled ? [Color.gray, Color.gray.opacity(0.8)] : [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: isDisabled ? .clear : color.opacity(0.3),
                radius: isDisabled ? 0 : 8,
                x: 0,
                y: isDisabled ? 0 : 4
            )
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(PlainButtonStyle())
    }
}
