//
//  FlowSudokuWidget.swift
//  FlowSudokuWidget
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct GoalEntry: TimelineEntry {
    let date: Date
    let goals: [Goal]
    
    var incompleteGoals: [Goal] {
        goals.filter { !$0.isCompleted }
    }
    
    var completedGoals: [Goal] {
        goals.filter { $0.isCompleted }
    }
}

// MARK: - Widget Provider
struct GoalProvider: TimelineProvider {
    func placeholder(in context: Context) -> GoalEntry {
        GoalEntry(
            date: Date(),
            goals: [
                Goal(text: "Complete morning routine", isCompleted: false),
                Goal(text: "Finish project proposal", isCompleted: true),
                Goal(text: "Call mom", isCompleted: false)
            ]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GoalEntry) -> Void) {
        let entry = loadGoalsEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GoalEntry>) -> Void) {
        let entry = loadGoalsEntry()
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadGoalsEntry() -> GoalEntry {
        // Load goals directly from App Group UserDefaults (widget runs in separate process)
        let appGroupIdentifier = "group.com.flowsudoku.shared"
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = sharedDefaults.data(forKey: "flow_sudoku_goals") else {
            return GoalEntry(date: Date(), goals: [])
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let allGoals = try decoder.decode([Goal].self, from: data)
            
            // Filter for today's goals
            let today = Date()
            let calendar = Calendar.current
            let todayGoals = allGoals.filter { calendar.isDate($0.date, inSameDayAs: today) }
            
            return GoalEntry(date: Date(), goals: todayGoals)
        } catch {
            print("⚠️ Widget: Failed to decode goals: \(error)")
            return GoalEntry(date: Date(), goals: [])
        }
    }
}

// MARK: - Widget View
struct FlowSudokuWidgetEntryView: View {
    var entry: GoalProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("TODAY'S GOALS")
                    .font(.custom("Anta-Regular", size: 14))
                    .foregroundColor(.black)
                    .tracking(2)
                
                Spacer()
                
                Text("\(entry.incompleteGoals.count)")
                    .font(.custom("Anta-Regular", size: 16))
                    .foregroundColor(.black.opacity(0.6))
            }
            
            // Goals list
            if entry.goals.isEmpty {
                VStack(spacing: 8) {
                    Text("No goals set")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.black.opacity(0.4))
                        .italic()
                    
                    Text("Add goals in Flow Sudoku")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(.black.opacity(0.3))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    // Incomplete goals first
                    ForEach(entry.incompleteGoals.prefix(5)) { goal in
                        GoalRowWidgetView(goal: goal)
                    }
                    
                    // Completed goals (if any and space available)
                    if !entry.completedGoals.isEmpty && entry.incompleteGoals.count < 5 {
                        Divider()
                            .padding(.vertical, 4)
                        
                        ForEach(entry.completedGoals.prefix(5 - entry.incompleteGoals.count)) { goal in
                            GoalRowWidgetView(goal: goal)
                        }
                    }
                    
                    // More indicator
                    if entry.goals.count > 5 {
                        Text("+ \(entry.goals.count - 5) more")
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(.black.opacity(0.3))
                            .padding(.top, 4)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
}

// MARK: - Goal Row Widget View
struct GoalRowWidgetView: View {
    let goal: Goal
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(goal.isCompleted ? .black.opacity(0.6) : .black.opacity(0.3))
            
            Text(goal.text)
                .font(.system(size: 11, weight: .light))
                .foregroundColor(goal.isCompleted ? .black.opacity(0.5) : .black)
                .strikethrough(goal.isCompleted)
                .lineLimit(1)
        }
    }
}

// MARK: - Widget Configuration
struct FlowSudokuWidget: Widget {
    let kind: String = "FlowSudokuWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GoalProvider()) { entry in
            FlowSudokuWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Flow Sudoku Goals")
        .description("View your daily goals from Flow Sudoku.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    FlowSudokuWidget()
} timeline: {
    GoalEntry(
        date: Date(),
        goals: [
            Goal(text: "Complete morning routine", isCompleted: false),
            Goal(text: "Finish project proposal", isCompleted: true),
            Goal(text: "Call mom", isCompleted: false)
        ]
    )
}

