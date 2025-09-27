//
//  WorkoutFiltersView.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import SwiftUI

struct WorkoutFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPeriod: WorkoutListView.FilterPeriod
    @Binding var selectedCategory: String
    let categories: [String]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Период") {
                    ForEach(WorkoutListView.FilterPeriod.allCases, id: \.self) { period in
                        HStack {
                            Text(period.rawValue)
                            Spacer()
                            if selectedPeriod == period {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPeriod = period
                        }
                    }
                }
                
                Section("Категория упражнений") {
                    ForEach(categories, id: \.self) { category in
                        HStack {
                            Text(category)
                            Spacer()
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCategory = category
                        }
                    }
                }
                
                Section {
                    Button("Сбросить фильтры") {
                        selectedPeriod = .all
                        selectedCategory = "Все"
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
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
    WorkoutFiltersView(
        selectedPeriod: .constant(WorkoutListView.FilterPeriod.all),
        selectedCategory: .constant("Все"),
        categories: ["Все", "Грудь", "Спина", "Ноги"]
    )
}
