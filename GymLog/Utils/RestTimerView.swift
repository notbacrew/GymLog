//
//  RestTimerView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import AVFoundation
import Combine

struct RestTimerView: View {
    @State private var timeRemaining: Int = 0
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var selectedMinutes: Int = 1
    @State private var selectedSeconds: Int = 30
    @State private var showingSettings = false
    
    @StateObject private var audioPlayer = AudioPlayer()
    
    private var totalSeconds: Int {
        selectedMinutes * 60 + selectedSeconds
    }
    
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalSeconds)
    }
    
    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Круглый таймер
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 20)
                        .frame(width: 250, height: 250)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: progress)
                    
                    VStack(spacing: 8) {
                        Text(formattedTime)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                        
                        Text(isRunning ? "Осталось" : "Готов к старту")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Кнопки управления
                HStack(spacing: 20) {
                    if !isRunning {
                        Button(action: startTimer) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Старт")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .cornerRadius(25)
                        }
                    } else {
                        Button(action: pauseTimer) {
                            HStack {
                                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                Text(isRunning ? "Пауза" : "Продолжить")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(Color.orange)
                            .cornerRadius(25)
                        }
                        
                        Button(action: resetTimer) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Сброс")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(Color.red)
                            .cornerRadius(25)
                        }
                    }
                }
                
                // Настройки времени
                VStack(spacing: 16) {
                    Text("Время отдыха")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("Минуты")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("Минуты", selection: $selectedMinutes) {
                                ForEach(0..<10) { minute in
                                    Text("\(minute)")
                                        .tag(minute)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 80, height: 100)
                            .disabled(isRunning)
                        }
                        
                        Text(":")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        VStack {
                            Text("Секунды")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("Секунды", selection: $selectedSeconds) {
                                ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { second in
                                    Text("\(second)")
                                        .tag(second)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 80, height: 100)
                            .disabled(isRunning)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Таймер отдыха")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Настройки") {
                        showingSettings = true
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                TimerSettingsView()
            }
            .onAppear {
                timeRemaining = totalSeconds
            }
            .onChange(of: totalSeconds) { _, newValue in
                if !isRunning {
                    timeRemaining = newValue
                }
            }
        }
    }
    
    private func startTimer() {
        isRunning = true
        timeRemaining = totalSeconds
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timerFinished()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning.toggle()
        
        if isRunning {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timerFinished()
                }
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func resetTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        timeRemaining = totalSeconds
    }
    
    private func timerFinished() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Воспроизводим звук
        audioPlayer.playSound()
        
        // Вибрация
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
}

class AudioPlayer: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "timer_sound", withExtension: "mp3") else {
            // Если файл не найден, используем системный звук
            AudioServicesPlaySystemSound(1005) // Звук уведомления
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Ошибка воспроизведения звука: \(error)")
            AudioServicesPlaySystemSound(1005)
        }
    }
}

struct TimerSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("timerSoundEnabled") private var soundEnabled = true
    @AppStorage("timerVibrationEnabled") private var vibrationEnabled = true
    @AppStorage("defaultRestTime") private var defaultRestTime = 90 // секунды
    
    var body: some View {
        NavigationView {
            Form {
                Section("Звуки и вибрация") {
                    Toggle("Звук таймера", isOn: $soundEnabled)
                    Toggle("Вибрация", isOn: $vibrationEnabled)
                }
                
                Section("Время по умолчанию") {
                    HStack {
                        Text("Время отдыха")
                        Spacer()
                        Text("\(defaultRestTime / 60):\(String(format: "%02d", defaultRestTime % 60))")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(defaultRestTime) },
                        set: { defaultRestTime = Int($0) }
                    ), in: 30...300, step: 15)
                }
                
                Section("Информация") {
                    Text("Таймер поможет вам соблюдать правильные интервалы отдыха между подходами для максимальной эффективности тренировок.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Настройки таймера")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RestTimerView()
}
