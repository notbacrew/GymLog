//
//  ToastManager.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import Combine

class ToastManager: ObservableObject {
    @Published var isShowing = false
    @Published var message = ""
    
    func show(message: String) {
        self.message = message
        self.isShowing = true
        
        // Автоматически скрываем через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isShowing = false
        }
    }
}

