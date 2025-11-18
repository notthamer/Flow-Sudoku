//
//  CloudSyncService.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import Foundation
import Combine

// MARK: - Cloud Sync Service
// Currently local-only. Can be extended with Firebase/Supabase later.
class CloudSyncService: ObservableObject {
    static let shared = CloudSyncService()
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    
    private let authService = AuthService.shared
    private let sessionManager = SessionManager.shared
    
    private init() {
        loadLastSyncDate()
    }
    
    // MARK: - Sync Operations
    
    func syncSessions(completion: @escaping (Result<Void, SyncError>) -> Void) {
        guard authService.isAuthenticated else {
            completion(.failure(.notAuthenticated))
            return
        }
        
        syncStatus = .syncing
        
        Task {
            do {
                // 1. Upload local sessions to server
                let localSessions = sessionManager.sessions
                if !localSessions.isEmpty {
                    let syncData = localSessions.map { session -> SessionSyncData in
                        let iso8601 = ISO8601DateFormatter()
                        return SessionSyncData(
                            id: session.id.uuidString,
                            timestamp: iso8601.string(from: session.timestamp),
                            duration: session.duration,
                            difficulty: session.difficulty,
                            declutterText: session.declutterText,
                            mistakeCount: session.mistakeCount,
                            isCompleted: session.isCompleted,
                            puzzleId: session.puzzleId
                        )
                    }
                    
                    // Upload each session to Supabase
                    for data in syncData {
                        struct SessionInsert: Codable {
                            let id: String
                            let userId: String
                            let timestamp: String
                            let duration: Int
                            let difficulty: String
                            let declutterText: String
                            let mistakeCount: Int
                            let isCompleted: Bool
                            let puzzleId: Int?
                            
                            enum CodingKeys: String, CodingKey {
                                case id
                                case userId = "user_id"
                                case timestamp, duration, difficulty
                                case declutterText = "declutter_text"
                                case mistakeCount = "mistake_count"
                                case isCompleted = "is_completed"
                                case puzzleId = "puzzle_id"
                            }
                        }
                        
                        let insert = SessionInsert(
                            id: data.id,
                            userId: authService.currentUser?.id ?? "",
                            timestamp: data.timestamp,
                            duration: data.duration,
                            difficulty: data.difficulty,
                            declutterText: data.declutterText,
                            mistakeCount: data.mistakeCount,
                            isCompleted: data.isCompleted,
                            puzzleId: data.puzzleId
                        )
                        
                        let _: [SessionInsert] = try await NetworkService.shared.request(
                            endpoint: "/rest/v1/sessions",
                            method: .post,
                            body: insert,
                            requiresAuth: true
                        )
                    }
                }
                
                // 2. Download sessions from server (optional - for multi-device sync)
                // let response: SessionsResponse = try await NetworkService.shared.request(
                //     endpoint: "/sessions",
                //     method: .get,
                //     requiresAuth: true
                // )
                // Merge with local sessions if needed
                
                await MainActor.run {
                    self.lastSyncDate = Date()
                    self.saveLastSyncDate()
                    self.syncStatus = .synced
                    completion(.success(()))
                    print("✅ Sessions synced to server")
                }
            } catch {
                await MainActor.run {
                    self.syncStatus = .error("Sync failed")
                    completion(.failure(.networkError))
                    print("❌ Sync failed: \(error)")
                }
            }
        }
    }
    
    func uploadSession(_ session: SessionData, completion: @escaping (Result<Void, SyncError>) -> Void) {
        guard authService.isAuthenticated else {
            completion(.failure(.notAuthenticated))
            return
        }
        
        Task {
            do {
                let iso8601 = ISO8601DateFormatter()
                let syncData = SessionSyncData(
                    id: session.id.uuidString,
                    timestamp: iso8601.string(from: session.timestamp),
                    duration: session.duration,
                    difficulty: session.difficulty,
                    declutterText: session.declutterText,
                    mistakeCount: session.mistakeCount,
                    isCompleted: session.isCompleted,
                    puzzleId: session.puzzleId
                )
                
                struct SessionInsert: Codable {
                    let id: String
                    let userId: String
                    let timestamp: String
                    let duration: Int
                    let difficulty: String
                    let declutterText: String
                    let mistakeCount: Int
                    let isCompleted: Bool
                    let puzzleId: Int?
                    
                    enum CodingKeys: String, CodingKey {
                        case id
                        case userId = "user_id"
                        case timestamp, duration, difficulty
                        case declutterText = "declutter_text"
                        case mistakeCount = "mistake_count"
                        case isCompleted = "is_completed"
                        case puzzleId = "puzzle_id"
                    }
                }
                
                let insert = SessionInsert(
                    id: syncData.id,
                    userId: authService.currentUser?.id ?? "",
                    timestamp: syncData.timestamp,
                    duration: syncData.duration,
                    difficulty: syncData.difficulty,
                    declutterText: syncData.declutterText,
                    mistakeCount: syncData.mistakeCount,
                    isCompleted: syncData.isCompleted,
                    puzzleId: syncData.puzzleId
                )
                
                let _: [SessionInsert] = try await NetworkService.shared.request(
                    endpoint: "/rest/v1/sessions",
                    method: .post,
                    body: insert,
                    requiresAuth: true
                )
                
                await MainActor.run {
                    self.lastSyncDate = Date()
                    self.saveLastSyncDate()
                    completion(.success(()))
                    print("✅ Session uploaded to server")
                }
            } catch {
                await MainActor.run {
                    completion(.failure(.networkError))
                    print("❌ Upload failed: \(error)")
                }
            }
        }
    }
    
    func downloadSessions(completion: @escaping (Result<[SessionData], SyncError>) -> Void) {
        guard authService.isAuthenticated else {
            completion(.failure(.notAuthenticated))
            return
        }
        
        syncStatus = .syncing
        
        Task {
            do {
                struct SupabaseSession: Codable {
                    let id: String
                    let timestamp: String
                    let duration: Int
                    let difficulty: String
                    let declutterText: String
                    let mistakeCount: Int
                    let isCompleted: Bool
                    let puzzleId: Int?
                    
                    enum CodingKeys: String, CodingKey {
                        case id, timestamp, duration, difficulty
                        case declutterText = "declutter_text"
                        case mistakeCount = "mistake_count"
                        case isCompleted = "is_completed"
                        case puzzleId = "puzzle_id"
                    }
                }
                
                let response: [SupabaseSession] = try await NetworkService.shared.request(
                    endpoint: "/rest/v1/sessions?order=timestamp.desc",
                    method: .get,
                    requiresAuth: true
                )
                
                // Convert server sessions to local format
                let iso8601 = ISO8601DateFormatter()
                let sessions = response.compactMap { serverSession -> SessionData? in
                    guard let timestamp = iso8601.date(from: serverSession.timestamp),
                          let id = UUID(uuidString: serverSession.id) else {
                        return nil
                    }
                    
                    return SessionData(
                        id: id,
                        timestamp: timestamp,
                        duration: serverSession.duration,
                        difficulty: serverSession.difficulty,
                        declutterText: serverSession.declutterText,
                        mistakeCount: serverSession.mistakeCount,
                        isCompleted: serverSession.isCompleted,
                        puzzleId: serverSession.puzzleId
                    )
                }
                
                await MainActor.run {
                    self.syncStatus = .synced
                    self.lastSyncDate = Date()
                    self.saveLastSyncDate()
                    completion(.success(sessions))
                    print("✅ Downloaded \(sessions.count) sessions from server")
                }
            } catch {
                await MainActor.run {
                    self.syncStatus = .error("Download failed")
                    completion(.failure(.networkError))
                    print("❌ Download failed: \(error)")
                }
            }
        }
    }
    
    func autoSync() {
        guard authService.isAuthenticated else { return }
        
        // Auto-sync if last sync was more than 1 hour ago
        if let lastSync = lastSyncDate {
            let hoursSinceSync = Date().timeIntervalSince(lastSync) / 3600
            if hoursSinceSync < 1 {
                print("ℹ️ Skipping auto-sync (last sync was recent)")
                return
            }
        }
        
        syncSessions { result in
            switch result {
            case .success:
                print("✅ Auto-sync completed")
            case .failure(let error):
                print("⚠️ Auto-sync failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Sync Status
    
    var syncStatusText: String {
        switch syncStatus {
        case .idle:
            if let lastSync = lastSyncDate {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .short
                return "Synced \(formatter.localizedString(for: lastSync, relativeTo: Date()))"
            }
            return "Not synced"
        case .syncing:
            return "Syncing..."
        case .synced:
            return "Synced"
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    // MARK: - Persistence
    
    private func saveLastSyncDate() {
        if let date = lastSyncDate {
            UserDefaults.standard.set(date, forKey: "last_sync_date")
        }
    }
    
    private func loadLastSyncDate() {
        lastSyncDate = UserDefaults.standard.object(forKey: "last_sync_date") as? Date
    }
}

// MARK: - Supporting Types

enum SyncStatus: Equatable {
    case idle
    case syncing
    case synced
    case error(String)
}

enum SyncError: LocalizedError {
    case notAuthenticated
    case networkError
    case serverError
    case conflictError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to sync"
        case .networkError:
            return "Network error"
        case .serverError:
            return "Server error"
        case .conflictError:
            return "Sync conflict"
        case .unknown(let message):
            return message
        }
    }
}

