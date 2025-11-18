//
//  SessionData.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import Foundation

// MARK: - Session Data Model
struct SessionData: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let duration: Int // in seconds
    let difficulty: String
    let declutterText: String
    let mistakeCount: Int
    let isCompleted: Bool
    let puzzleId: Int?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        duration: Int,
        difficulty: String,
        declutterText: String,
        mistakeCount: Int,
        isCompleted: Bool,
        puzzleId: Int? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.duration = duration
        self.difficulty = difficulty
        self.declutterText = declutterText
        self.mistakeCount = mistakeCount
        self.isCompleted = isCompleted
        self.puzzleId = puzzleId
    }
    
    // Formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    // Formatted duration
    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Declutter text snippet for list view
    var declutterSnippet: String {
        if declutterText.count <= 100 {
            return declutterText
        }
        let endIndex = declutterText.index(declutterText.startIndex, offsetBy: 100)
        return String(declutterText[..<endIndex]) + "..."
    }
}

// MARK: - User Preferences Model
struct UserPreferences: Codable {
    var tier: UserTier
    var maxDailyGoals: Int
    var theme: String
    var fontSize: Int
    var notificationsEnabled: Bool
    var lastSyncDate: Date?
    
    init(
        tier: UserTier = .free,
        maxDailyGoals: Int = 3,
        theme: String = "default",
        fontSize: Int = 18,
        notificationsEnabled: Bool = false,
        lastSyncDate: Date? = nil
    ) {
        self.tier = tier
        self.maxDailyGoals = maxDailyGoals
        self.theme = theme
        self.fontSize = fontSize
        self.notificationsEnabled = notificationsEnabled
        self.lastSyncDate = lastSyncDate
    }
}

// MARK: - User Tier Enum
enum UserTier: String, Codable {
    case free = "free"
    case studio = "studio"
    
    var sessionLimit: Int {
        switch self {
        case .free: return 1
        case .studio: return .max
        }
    }
    
    var goalLimit: Int {
        switch self {
        case .free: return 3
        case .studio: return .max
        }
    }
    
    var pomodoroLimit: Int {
        switch self {
        case .free: return 1
        case .studio: return .max
        }
    }
}

// MARK: - Daily Usage Stats
struct DailyUsageStats: Codable {
    var date: Date
    var sessionsCompleted: Int
    var goalsSet: Int
    var pomodorosCompleted: Int
    
    init(
        date: Date = Date(),
        sessionsCompleted: Int = 0,
        goalsSet: Int = 0,
        pomodorosCompleted: Int = 0
    ) {
        self.date = date
        self.sessionsCompleted = sessionsCompleted
        self.goalsSet = goalsSet
        self.pomodorosCompleted = pomodorosCompleted
    }
    
    // Check if this stats object is for today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

