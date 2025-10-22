//
//  PersonalRecord.swift
//  GymLog
//
//  Created by maksimchernukha on 25.09.2025.
//

import Foundation
import Combine

struct PersonalRecord: Identifiable, Codable {
    let id: UUID
    let exerciseName: String
    let weight: Double
    let date: Date
    let notes: String?
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    init(id: UUID = UUID(), exerciseName: String, weight: Double, date: Date = Date(), notes: String? = nil) {
        self.id = id
        self.exerciseName = exerciseName
        self.weight = weight
        self.date = date
        self.notes = notes
    }
}

class PersonalRecordManager: ObservableObject {
    static let shared = PersonalRecordManager()
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    private let userDefaults = UserDefaults.standard
    private let recordsKey = "personal_records"
    
    private init() {}
    
    func getRecords(for userId: String) -> [PersonalRecord] {
        let key = "\(recordsKey)_\(userId)"
        guard let data = userDefaults.data(forKey: key),
              let records = try? JSONDecoder().decode([PersonalRecord].self, from: data) else {
            return []
        }
        return records
    }
    
    func addRecord(_ record: PersonalRecord, for userId: String) {
        var records = getRecords(for: userId)
        
        // Удаляем старый рекорд для того же упражнения, если он есть
        records.removeAll { $0.exerciseName == record.exerciseName }
        
        // Добавляем новый рекорд
        records.append(record)
        
        saveRecords(records, for: userId)
        notifyChange()
    }
    
    func updateRecord(_ record: PersonalRecord, for userId: String) {
        var records = getRecords(for: userId)
        
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            saveRecords(records, for: userId)
            notifyChange()
        }
    }
    
    func deleteRecord(_ record: PersonalRecord, for userId: String) {
        var records = getRecords(for: userId)
        records.removeAll { $0.id == record.id }
        saveRecords(records, for: userId)
        notifyChange()
    }
    
    private func saveRecords(_ records: [PersonalRecord], for userId: String) {
        let key = "\(recordsKey)_\(userId)"
        if let data = try? JSONEncoder().encode(records) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    func getRecord(for exerciseName: String, userId: String) -> PersonalRecord? {
        let records = getRecords(for: userId)
        return records.first { $0.exerciseName == exerciseName }
    }
    
    private func notifyChange() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
