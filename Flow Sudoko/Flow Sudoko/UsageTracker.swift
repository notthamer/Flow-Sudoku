//
//  UsageTracker.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import Foundation
import Combine

// MARK: - Usage Tracker
class UsageTracker: ObservableObject {
    static let shared = UsageTracker()
    
    @Published var dailyStats: DailyUsageStats
    
    private let statsKey = "flow_sudoku_daily_stats"
    private var midnightResetTimer: Timer?
    
    private init() {
        // Load existing stats or create new
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let stats = try? JSONDecoder().decode(DailyUsageStats.self, from: data) {
            // Check if stats are from today
            if stats.isToday {
                dailyStats = stats
            } else {
                // New day, reset stats
                dailyStats = DailyUsageStats()
                saveStats()
            }
        } else {
            dailyStats = DailyUsageStats()
        }
        
        // Setup midnight reset
        setupMidnightReset()
        
        print("✅ UsageTracker initialized - Sessions: \(dailyStats.sessionsCompleted)")
    }
    
    // MARK: - Usage Tracking
    
    func incrementSessionCount() {
        ensureCurrentDay()
        dailyStats.sessionsCompleted += 1
        saveStats()
        print("📊 Session count: \(dailyStats.sessionsCompleted)")
    }
    
    func incrementGoalCount() {
        ensureCurrentDay()
        dailyStats.goalsSet += 1
        saveStats()
        print("📊 Goal count: \(dailyStats.goalsSet)")
    }
    
    func incrementPomodoroCount() {
        ensureCurrentDay()
        dailyStats.pomodorosCompleted += 1
        saveStats()
        print("📊 Pomodoro count: \(dailyStats.pomodorosCompleted)")
    }
    
    // MARK: - Limit Checking
    
    func canStartSession(for tier: UserTier) -> Bool {
        ensureCurrentDay()
        let limit = tier.sessionLimit
        let canStart = dailyStats.sessionsCompleted < limit
        print("🔍 Can start session? \(canStart) (used: \(dailyStats.sessionsCompleted)/\(limit))")
        return canStart
    }
    
    func canSetGoal(for tier: UserTier) -> Bool {
        ensureCurrentDay()
        let limit = tier.goalLimit
        return dailyStats.goalsSet < limit
    }
    
    func canStartPomodoro(for tier: UserTier) -> Bool {
        ensureCurrentDay()
        let limit = tier.pomodoroLimit
        return dailyStats.pomodorosCompleted < limit
    }
    
    func getRemainingCount(for feature: UsageFeature, tier: UserTier) -> Int {
        ensureCurrentDay()
        
        switch feature {
        case .sessions:
            let limit = tier.sessionLimit
            if limit == .max { return .max }
            return max(0, limit - dailyStats.sessionsCompleted)
        case .goals:
            let limit = tier.goalLimit
            if limit == .max { return .max }
            return max(0, limit - dailyStats.goalsSet)
        case .pomodoros:
            let limit = tier.pomodoroLimit
            if limit == .max { return .max }
            return max(0, limit - dailyStats.pomodorosCompleted)
        }
    }
    
    func getUsageText(for feature: UsageFeature, tier: UserTier) -> String {
        let remaining = getRemainingCount(for: feature, tier: tier)
        
        if remaining == .max {
            return "Unlimited"
        }
        
        switch feature {
        case .sessions:
            let used = dailyStats.sessionsCompleted
            let limit = tier.sessionLimit
            return "\(used)/\(limit) today"
        case .goals:
            let used = dailyStats.goalsSet
            let limit = tier.goalLimit
            return "\(used)/\(limit) today"
        case .pomodoros:
            let used = dailyStats.pomodorosCompleted
            let limit = tier.pomodoroLimit
            return "\(used)/\(limit) today"
        }
    }
    
    // MARK: - Private Helpers
    
    private func ensureCurrentDay() {
        if !dailyStats.isToday {
            resetStats()
        }
    }
    
    private func resetStats() {
        dailyStats = DailyUsageStats()
        saveStats()
        print("🔄 Daily stats reset")
    }
    
    private func saveStats() {
        do {
            let data = try JSONEncoder().encode(dailyStats)
            UserDefaults.standard.set(data, forKey: statsKey)
        } catch {
            print("❌ Failed to save daily stats: \(error)")
        }
    }
    
    // MARK: - Midnight Reset Timer
    
    private func setupMidnightReset() {
        // Calculate time until next midnight
        let calendar = Calendar.current
        let now = Date()
        
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) {
            let timeInterval = midnight.timeIntervalSince(now)
            
            // Schedule timer for midnight
            DispatchQueue.main.async { [weak self] in
                self?.midnightResetTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
                    self?.resetStats()
                    // Setup next midnight reset
                    self?.setupMidnightReset()
                }
            }
            
            print("⏰ Midnight reset scheduled in \(Int(timeInterval / 3600)) hours")
        }
    }
    
    deinit {
        midnightResetTimer?.invalidate()
    }
}

// MARK: - Supporting Types

enum UsageFeature {
    case sessions
    case goals
    case pomodoros
}

