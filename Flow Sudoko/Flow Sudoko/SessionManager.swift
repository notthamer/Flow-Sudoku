//
//  SessionManager.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import Foundation
import Combine

// MARK: - Session Manager
class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var sessions: [SessionData] = []
    @Published var preferences: UserPreferences = UserPreferences()
    
    private let sessionsKey = "flow_sudoku_sessions"
    private let preferencesKey = "flow_sudoku_preferences"
    private let fileManager = FileManager.default
    
    private init() {
        loadSessions()
        loadPreferences()
    }
    
    // MARK: - Session Management
    
    func saveSession(_ session: SessionData) {
        sessions.insert(session, at: 0) // Add to beginning for newest-first
        saveSessions()
        print("✅ Session saved: \(session.formattedDate)")
    }
    
    func deleteSession(_ session: SessionData) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
        print("🗑️ Session deleted")
    }
    
    func getSessions(filteredBy difficulty: String? = nil, sortedBy sortOption: SessionSortOption = .dateDescending) -> [SessionData] {
        var filtered = sessions
        
        // Filter by difficulty if specified
        if let difficulty = difficulty, difficulty != "all" {
            filtered = filtered.filter { $0.difficulty.lowercased() == difficulty.lowercased() }
        }
        
        // Sort
        switch sortOption {
        case .dateDescending:
            filtered.sort { $0.timestamp > $1.timestamp }
        case .dateAscending:
            filtered.sort { $0.timestamp < $1.timestamp }
        case .durationDescending:
            filtered.sort { $0.duration > $1.duration }
        case .durationAscending:
            filtered.sort { $0.duration < $1.duration }
        }
        
        return filtered
    }
    
    // MARK: - Preferences Management
    
    func updatePreferences(_ preferences: UserPreferences) {
        self.preferences = preferences
        savePreferences()
        print("✅ Preferences updated")
    }
    
    func updateTier(_ tier: UserTier) {
        preferences.tier = tier
        savePreferences()
        print("✅ Tier updated to: \(tier.rawValue)")
    }
    
    // MARK: - Persistence (Local)
    
    private func saveSessions() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(sessions)
            
            // Save to UserDefaults for small datasets
            UserDefaults.standard.set(data, forKey: sessionsKey)
            
            // Also save to file for backup
            if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("sessions.json")
                try data.write(to: fileURL)
            }
        } catch {
            print("❌ Failed to save sessions: \(error)")
        }
    }
    
    private func loadSessions() {
        // Try UserDefaults first
        if let data = UserDefaults.standard.data(forKey: sessionsKey) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                sessions = try decoder.decode([SessionData].self, from: data)
                print("✅ Loaded \(sessions.count) sessions from UserDefaults")
                return
            } catch {
                print("⚠️ Failed to decode sessions from UserDefaults: \(error)")
            }
        }
        
        // Try file backup
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("sessions.json")
            if let data = try? Data(contentsOf: fileURL) {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    sessions = try decoder.decode([SessionData].self, from: data)
                    print("✅ Loaded \(sessions.count) sessions from file")
                    return
                } catch {
                    print("⚠️ Failed to decode sessions from file: \(error)")
                }
            }
        }
        
        print("ℹ️ No existing sessions found")
    }
    
    private func savePreferences() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(preferences)
            UserDefaults.standard.set(data, forKey: preferencesKey)
        } catch {
            print("❌ Failed to save preferences: \(error)")
        }
    }
    
    private func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: preferencesKey) {
            do {
                let decoder = JSONDecoder()
                preferences = try decoder.decode(UserPreferences.self, from: data)
                print("✅ Loaded preferences")
            } catch {
                print("⚠️ Failed to decode preferences: \(error)")
            }
        }
    }
    
    // MARK: - Statistics
    
    func getSessionStats() -> SessionStats {
        let total = sessions.count
        let completed = sessions.filter { $0.isCompleted }.count
        let totalDuration = sessions.reduce(0) { $0 + $1.duration }
        let averageDuration = total > 0 ? totalDuration / total : 0
        
        return SessionStats(
            totalSessions: total,
            completedSessions: completed,
            totalDuration: totalDuration,
            averageDuration: averageDuration
        )
    }
}

// MARK: - Supporting Types

enum SessionSortOption {
    case dateDescending
    case dateAscending
    case durationDescending
    case durationAscending
}

struct SessionStats {
    let totalSessions: Int
    let completedSessions: Int
    let totalDuration: Int // in seconds
    let averageDuration: Int // in seconds
    
    var formattedTotalDuration: String {
        let hours = totalDuration / 3600
        let minutes = (totalDuration % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    var formattedAverageDuration: String {
        let minutes = averageDuration / 60
        let seconds = averageDuration % 60
        return "\(minutes)m \(seconds)s"
    }
}

