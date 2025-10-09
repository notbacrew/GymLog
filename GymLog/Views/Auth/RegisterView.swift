//
//  RegisterView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import PhotosUI
import CoreData

struct RegisterView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var selectedAvatar: PhotosPickerItem?
    @State private var avatarData: Data?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    avatarSection
                    formSection
                    registerButton
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 32)
            }
            .navigationTitle("Регистрация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .alert("Ошибка регистрации", isPresented: $showingAlert) {
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
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Создать аккаунт")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Заполните форму для регистрации")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    private var avatarSection: some View {
        VStack(spacing: 12) {
            Text("Аватар (необязательно)")
                .font(.headline)
            
            if let avatarData = avatarData,
               let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                    )
            } else {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    )
            }
            
            PhotosPicker(selection: $selectedAvatar, matching: .images) {
                Text("Выбрать фото")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            if avatarData != nil {
                Button("Удалить фото") {
                    avatarData = nil
                    selectedAvatar = nil
                }
                .font(.caption)
                .foregroundColor(.red)
            }
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            // Имя пользователя
            VStack(alignment: .leading, spacing: 8) {
                Text("Имя пользователя *")
                    .font(.headline)
                
                TextField("Введите имя пользователя", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            // Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email (необязательно)")
                    .font(.headline)
                
                TextField("Введите email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            // Пароль
            VStack(alignment: .leading, spacing: 8) {
                Text("Пароль *")
                    .font(.headline)
                
                SecureField("Введите пароль", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Подтверждение пароля
            VStack(alignment: .leading, spacing: 8) {
                Text("Подтвердите пароль *")
                    .font(.headline)
                
                SecureField("Повторите пароль", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    private var registerButton: some View {
        Button(action: register) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "person.badge.plus")
                }
                Text("Зарегистрироваться")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid ? Color.blue : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!isFormValid || isLoading)
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func register() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let emailToUse = email.isEmpty ? nil : email
            let result = authManager.register(
                username: username,
                email: emailToUse,
                password: password,
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
}

#Preview {
    RegisterView(authManager: AuthManager(context: PersistenceController.preview.container.viewContext))
}
