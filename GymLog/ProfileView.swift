//
//  ProfileView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData
import PhotosUI

struct ProfileView: View {
    @ObservedObject var authManager: AuthManager
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    
    private var userStatistics: UserStatistics {
        authManager.getUserStatistics()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Аватар и основная информация
                    VStack(spacing: 16) {
                        // Аватар
                        if let avatarData = authManager.currentUser?.avatar,
                           let uiImage = UIImage(data: avatarData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 3)
                                )
                        } else {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        // Имя пользователя
                        Text(authManager.currentUser?.username ?? "Пользователь")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Email
                        if let email = authManager.currentUser?.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Дата регистрации
                        if let createdAt = authManager.currentUser?.createdAt {
                            Text("Участник с \(DateFormatter.medium.string(from: createdAt))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Статистика
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Статистика")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatisticCard(
                                title: "Тренировок",
                                value: "\(userStatistics.workoutCount)",
                                icon: "dumbbell.fill",
                                color: .blue
                            )
                            
                            StatisticCard(
                                title: "Упражнений",
                                value: "\(userStatistics.exerciseCount)",
                                icon: "list.bullet",
                                color: .green
                            )
                            
                            StatisticCard(
                                title: "Подходов",
                                value: "\(userStatistics.totalSets)",
                                icon: "repeat",
                                color: .orange
                            )
                            
                            StatisticCard(
                                title: "Общий вес",
                                value: String(format: "%.0f кг", userStatistics.totalWeight),
                                icon: "scalemass",
                                color: .red
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Действия
                    VStack(spacing: 16) {
                        Text("Действия")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            ActionButtonCard(
                                icon: "pencil.circle.fill",
                                title: "Редактировать профиль",
                                subtitle: "Изменить данные профиля",
                                color: .blue,
                                action: { showingEditProfile = true }
                            )
                            
                            ActionButtonCard(
                                icon: "arrow.right.square.fill",
                                title: "Выйти из аккаунта",
                                subtitle: "Завершить текущую сессию",
                                color: .red,
                                action: { showingLogoutAlert = true }
                            )
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(authManager: authManager)
            }
            .alert("Выйти из аккаунта", isPresented: $showingLogoutAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Выйти", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("Вы уверены, что хотите выйти из аккаунта?")
            }
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct EditProfileView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var username: String
    @State private var email: String
    @State private var selectedAvatar: PhotosPickerItem?
    @State private var avatarData: Data?
    @State private var showingPasswordChange = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        self._username = State(initialValue: authManager.currentUser?.username ?? "")
        self._email = State(initialValue: authManager.currentUser?.email ?? "")
        self._avatarData = State(initialValue: authManager.currentUser?.avatar)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    // Аватар
                    HStack {
                        Text("Аватар")
                        
                        Spacer()
                        
                        if let avatarData = avatarData,
                           let uiImage = UIImage(data: avatarData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "person.circle")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    
                    PhotosPicker(selection: $selectedAvatar, matching: .images) {
                        Text("Изменить фото")
                    }
                    
                    if avatarData != nil {
                        Button("Удалить фото") {
                            avatarData = nil
                            selectedAvatar = nil
                        }
                        .foregroundColor(.red)
                    }
                    
                    // Имя пользователя
                    HStack {
                        Text("Имя пользователя")
                        Spacer()
                        TextField("Имя пользователя", text: $username)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // Email
                    HStack {
                        Text("Email")
                        Spacer()
                        TextField("Email", text: $email)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }
                
                Section("Безопасность") {
                    Button("Изменить пароль") {
                        showingPasswordChange = true
                    }
                }
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveProfile()
                    }
                    .disabled(isLoading)
                }
            }
            .sheet(isPresented: $showingPasswordChange) {
                ChangePasswordView(authManager: authManager)
            }
            .alert("Ошибка", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .onChange(of: selectedAvatar) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    avatarData = data
                }
            }
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        let result = authManager.updateProfile(
            username: username,
            email: email.isEmpty ? nil : email,
            avatar: avatarData
        )
        
        switch result {
        case .success:
            dismiss()
        case .failure(let error):
            alertMessage = error.localizedDescription
            showingAlert = true
        }
        
        isLoading = false
    }
}

struct ChangePasswordView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Текущий пароль") {
                    SecureField("Введите текущий пароль", text: $currentPassword)
                }
                
                Section("Новый пароль") {
                    SecureField("Введите новый пароль", text: $newPassword)
                    SecureField("Подтвердите новый пароль", text: $confirmPassword)
                }
            }
            .navigationTitle("Изменить пароль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        changePassword()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .alert("Результат", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    private func changePassword() {
        isLoading = true
        
        let result = authManager.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword
        )
        
        switch result {
        case .success:
            alertMessage = "Пароль успешно изменен"
            showingAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        case .failure(let error):
            alertMessage = error.localizedDescription
            showingAlert = true
        }
        
        isLoading = false
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    
    // Создаем тестового пользователя
    let user = User(context: context)
    user.id = UUID()
    user.username = "testuser"
    user.email = "test@example.com"
    user.createdAt = Date()
    authManager.currentUser = user
    authManager.isAuthenticated = true
    
    return ProfileView(authManager: authManager)
}

// MARK: - Action Button Card
struct ActionButtonCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Иконка
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                // Текст
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Стрелка
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
