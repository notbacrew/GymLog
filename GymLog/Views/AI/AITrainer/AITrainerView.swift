//
//  AITrainerView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI
import CoreData

struct AITrainerView: View {
    @StateObject private var chatManager: AITrainerManager
    @ObservedObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var messageText = ""
    @State private var showingInsights = false
    
    init(authManager: AuthManager, context: NSManagedObjectContext) {
        self.authManager = authManager
        self._chatManager = StateObject(wrappedValue: AITrainerManager(context: context, authManager: authManager))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Quick Actions
                QuickActionsView(chatManager: chatManager)
                
                // Chat Messages
                ChatView(messages: chatManager.messages, isLoading: chatManager.isLoading)
                
                // Message Input
                MessageInputView(
                    text: $messageText,
                    onSend: {
                        if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            chatManager.sendMessage(messageText)
                            messageText = ""
                        }
                    }
                )
            }
            .navigationTitle("AI Тренер")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingInsights = true
                    }) {
                        ZStack {
                            Image(systemName: "lightbulb")
                            if chatManager.unreadInsightsCount > 0 {
                                Text("\(chatManager.unreadInsightsCount)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingInsights) {
            InsightsView(insights: chatManager.insights, onInsightTap: { insight in
                chatManager.markInsightAsRead(insight)
            })
        }
        .onAppear {
            chatManager.generateInsights()
        }
    }
}

// MARK: - Quick Actions View
struct QuickActionsView: View {
    @ObservedObject var chatManager: AITrainerManager
    
    let quickActions = [
        ("Анализ недели", "chart.line.uptrend.xyaxis"),
        ("Следующая тренировка", "dumbbell.fill"),
        ("Почему не растет?", "questionmark.circle"),
        ("Совет по питанию", "fork.knife"),
        ("Мотивация", "heart.fill")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(quickActions, id: \.0) { action in
                    Button(action: {
                        chatManager.sendQuickMessage(action.0)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: action.1)
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text(action.0)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Chat View
struct ChatView: View {
    let messages: [ChatMessage]
    let isLoading: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubbleView(message: message)
                            .id(message.id)
                    }
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("AI думает...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

// MARK: - Chat Bubble View
struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding()
                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Message Input View
struct MessageInputView: View {
    @Binding var text: String
    let onSend: () -> Void
    
    var body: some View {
        HStack {
            TextField("Напишите сообщение...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSend()
                }
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Insights View
struct InsightsView: View {
    let insights: [AIInsight]
    let onInsightTap: (AIInsight) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(insights) { insight in
                    InsightRowView(insight: insight) {
                        onInsightTap(insight)
                    }
                }
            }
            .navigationTitle("AI Инсайты")
            .navigationBarTitleDisplayMode(.large)
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

// MARK: - Insight Row View
struct InsightRowView: View {
    let insight: AIInsight
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: insight.type.icon)
                    .foregroundColor(Color(insight.type.color))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(insight.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack {
                    Text(insight.priority.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(priorityColor.opacity(0.2))
                        .foregroundColor(priorityColor)
                        .cornerRadius(8)
                    
                    Spacer()
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var priorityColor: Color {
        switch insight.priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let authManager = AuthManager(context: context)
    return AITrainerView(authManager: authManager, context: context)
        .environment(\.managedObjectContext, context)
}
