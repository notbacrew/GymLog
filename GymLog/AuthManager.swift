//
//  AuthManager.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import Foundation
import CoreData
import CryptoKit
import SwiftUI
import Combine

class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let context: NSManagedObjectContext
    private let userDefaults = UserDefaults.standard
    private let currentUserIdKey = "currentUserId"
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadCurrentUser()
    }
    
    // MARK: - Authentication State
    
    func loadCurrentUser() {
        guard let userIdString = userDefaults.string(forKey: currentUserIdKey),
              let userId = UUID(uuidString: userIdString) else {
            isAuthenticated = false
            return
        }
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", userId as CVarArg)
        
        do {
            let users = try context.fetch(request)
            if let user = users.first {
                currentUser = user
                isAuthenticated = true
            } else {
                // Пользователь не найден, очищаем сохраненный ID
                userDefaults.removeObject(forKey: currentUserIdKey)
                isAuthenticated = false
            }
        } catch {
            print("Ошибка загрузки пользователя: \(error)")
            isAuthenticated = false
        }
    }
    
    func saveCurrentUser() {
        if let userId = currentUser?.id {
            userDefaults.set(userId.uuidString, forKey: currentUserIdKey)
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        userDefaults.removeObject(forKey: currentUserIdKey)
    }
    
    // MARK: - Registration
    
    func register(username: String, email: String?, password: String, avatar: Data?) -> Result<User, AuthError> {
        // Проверка уникальности username
        if isUsernameTaken(username) {
            return .failure(.usernameAlreadyExists)
        }
        
        // Проверка email если предоставлен
        if let email = email, !email.isEmpty {
            if isEmailTaken(email) {
                return .failure(.emailAlreadyExists)
            }
        }
        
        // Создание пользователя
        let user = User(context: context)
        user.id = UUID()
        user.username = username
        user.email = email?.isEmpty == true ? nil : email
        user.passwordHash = hashPassword(password)
        user.avatar = avatar
        user.createdAt = Date()
        
        do {
            try context.save()
            currentUser = user
            isAuthenticated = true
            saveCurrentUser()
            return .success(user)
        } catch {
            return .failure(.registrationFailed)
        }
    }
    
    // MARK: - Login
    
    func login(username: String, password: String) -> Result<User, AuthError> {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let users = try context.fetch(request)
            guard let user = users.first else {
                return .failure(.userNotFound)
            }
            
            let passwordHash = hashPassword(password)
            if user.passwordHash == passwordHash {
                currentUser = user
                isAuthenticated = true
                saveCurrentUser()
                return .success(user)
            } else {
                return .failure(.invalidPassword)
            }
        } catch {
            return .failure(.loginFailed)
        }
    }
    
    // MARK: - Profile Management
    
    func updateProfile(username: String?, email: String?, avatar: Data?) -> Result<User, AuthError> {
        guard let user = currentUser else {
            return .failure(.notAuthenticated)
        }
        
        // Проверка уникальности username если изменяется
        if let newUsername = username, newUsername != user.username {
            if isUsernameTaken(newUsername) {
                return .failure(.usernameAlreadyExists)
            }
            user.username = newUsername
        }
        
        // Проверка email если изменяется
        if let newEmail = email, newEmail != user.email {
            if !newEmail.isEmpty && isEmailTaken(newEmail) {
                return .failure(.emailAlreadyExists)
            }
            user.email = newEmail.isEmpty ? nil : newEmail
        }
        
        // Обновление аватара
        if let newAvatar = avatar {
            user.avatar = newAvatar
        }
        
        do {
            try context.save()
            return .success(user)
        } catch {
            return .failure(.updateFailed)
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) -> Result<Void, AuthError> {
        guard let user = currentUser else {
            return .failure(.notAuthenticated)
        }
        
        // Проверка текущего пароля
        let currentPasswordHash = hashPassword(currentPassword)
        if user.passwordHash != currentPasswordHash {
            return .failure(.invalidPassword)
        }
        
        // Обновление пароля
        user.passwordHash = hashPassword(newPassword)
        
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(.updateFailed)
        }
    }
    
    // MARK: - Helper Methods
    
    private func isUsernameTaken(_ username: String) -> Bool {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    private func isEmailTaken(_ email: String) -> Bool {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - User Statistics
    
    func getUserStatistics() -> UserStatistics {
        guard let user = currentUser else {
            return UserStatistics(workoutCount: 0, exerciseCount: 0, totalSets: 0, totalWeight: 0.0)
        }
        
        let workoutCount = user.workouts?.count ?? 0
        let exerciseCount = user.exercises?.count ?? 0
        
        var totalSets = 0
        var totalWeight = 0.0
        
        if let workouts = user.workouts?.allObjects as? [Workout] {
            for workout in workouts {
                if let details = workout.details?.allObjects as? [WorkoutDetail] {
                    for detail in details {
                        totalSets += Int(detail.sets)
                        totalWeight += detail.weight * Double(detail.sets)
                    }
                }
            }
        }
        
        return UserStatistics(
            workoutCount: workoutCount,
            exerciseCount: exerciseCount,
            totalSets: totalSets,
            totalWeight: totalWeight
        )
    }
}

// MARK: - Supporting Types

struct UserStatistics {
    let workoutCount: Int
    let exerciseCount: Int
    let totalSets: Int
    let totalWeight: Double
}

enum AuthError: LocalizedError {
    case usernameAlreadyExists
    case emailAlreadyExists
    case userNotFound
    case invalidPassword
    case registrationFailed
    case loginFailed
    case updateFailed
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .usernameAlreadyExists:
            return "Пользователь с таким именем уже существует"
        case .emailAlreadyExists:
            return "Пользователь с таким email уже существует"
        case .userNotFound:
            return "Пользователь не найден"
        case .invalidPassword:
            return "Неверный пароль"
        case .registrationFailed:
            return "Ошибка регистрации"
        case .loginFailed:
            return "Ошибка входа"
        case .updateFailed:
            return "Ошибка обновления профиля"
        case .notAuthenticated:
            return "Пользователь не авторизован"
        }
    }
}
