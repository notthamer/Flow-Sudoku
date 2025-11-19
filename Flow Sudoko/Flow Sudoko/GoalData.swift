//
//  GoalData.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import Foundation

// MARK: - Goal Model
struct Goal: Codable, Identifiable {
    let id: UUID
    var text: String
    let date: Date
    var isCompleted: Bool
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        text: String,
        date: Date = Date(),
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.date = date
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
    
    // Check if goal is for today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - Goal Manager
class GoalManager: ObservableObject {
    static let shared = GoalManager()
    
    @Published var goals: [Goal] = []
    
    private let goalsKey = "flow_sudoku_goals"
    private let appGroupIdentifier = "group.com.flowsudoku.shared" // For widget sharing
    
    private init() {
        loadGoals()
    }
    
    // MARK: - Goal Management
    
    func addGoal(_ text: String, date: Date = Date()) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let goal = Goal(text: text.trimmingCharacters(in: .whitespaces), date: date)
        goals.append(goal)
        saveGoals()
        
        // Track usage
        UsageTracker.shared.incrementGoalCount()
        
        print("✅ Goal added: \(goal.text)")
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
        print("🗑️ Goal deleted")
    }
    
    func toggleGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted.toggle()
            saveGoals()
            print("✅ Goal toggled: \(goals[index].isCompleted ? "completed" : "incomplete")")
        }
    }
    
    func updateGoal(_ goal: Goal, newText: String) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            var updatedGoal = goals[index]
            updatedGoal.text = newText.trimmingCharacters(in: .whitespaces)
            goals[index] = updatedGoal
            saveGoals()
            print("✅ Goal updated")
        }
    }
    
    // MARK: - Query Goals
    
    func getGoals(for date: Date) -> [Goal] {
        let calendar = Calendar.current
        return goals.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getTodayGoals() -> [Goal] {
        return getGoals(for: Date())
    }
    
    func getCompletedGoals(for date: Date) -> [Goal] {
        return getGoals(for: date).filter { $0.isCompleted }
    }
    
    func getIncompleteGoals(for date: Date) -> [Goal] {
        return getGoals(for: date).filter { !$0.isCompleted }
    }
    
    // MARK: - Persistence
    
    private func saveGoals() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(goals)
            
            // Save to UserDefaults
            UserDefaults.standard.set(data, forKey: goalsKey)
            
            // Save to App Group for widget access
            if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                sharedDefaults.set(data, forKey: goalsKey)
                sharedDefaults.synchronize()
            }
            
            print("✅ Goals saved (\(goals.count) total)")
        } catch {
            print("❌ Failed to save goals: \(error)")
        }
    }
    
    private func loadGoals() {
        // Try App Group first (for widget compatibility)
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
           let data = sharedDefaults.data(forKey: goalsKey) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                goals = try decoder.decode([Goal].self, from: data)
                print("✅ Loaded \(goals.count) goals from App Group")
                return
            } catch {
                print("⚠️ Failed to decode goals from App Group: \(error)")
            }
        }
        
        // Fallback to standard UserDefaults
        if let data = UserDefaults.standard.data(forKey: goalsKey) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                goals = try decoder.decode([Goal].self, from: data)
                print("✅ Loaded \(goals.count) goals from UserDefaults")
                return
            } catch {
                print("⚠️ Failed to decode goals: \(error)")
            }
        }
        
        print("ℹ️ No existing goals found")
    }
    
    // MARK: - Cleanup
    
    func cleanupOldGoals(olderThan days: Int = 30) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let initialCount = goals.count
        goals = goals.filter { $0.date >= cutoffDate }
        
        if goals.count < initialCount {
            saveGoals()
            print("🧹 Cleaned up \(initialCount - goals.count) old goals")
        }
    }
}

