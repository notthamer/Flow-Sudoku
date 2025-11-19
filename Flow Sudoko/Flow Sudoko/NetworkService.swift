//
//  NetworkService.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import Foundation

// MARK: - Network Service
class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://htrilyrrbercixpyxqrj.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0cmlseXJyYmVyY2l4cHl4cXJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzMTI3ODksImV4cCI6MjA3ODg4ODc4OX0.5K_8QWPE7L9ZqPvweErJwgDHP1Y2oq8qYkupqIbnjLk"
    
    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "access_token") }
    }
    
    private init() {}
    
    // MARK: - Generic Request Method
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: Codable? = nil,
        requiresAuth: Bool = false,
        preferUpsert: Bool = false
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
        // Add Prefer header for upsert (merge-duplicates)
        if preferUpsert {
            request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        }
        
        // Add auth token if required
        if requiresAuth, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            // For non-auth endpoints, still use the supabase key
            request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if present
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            // Check for network connectivity issues
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                    throw NetworkError.noConnection
                case .timedOut:
                    throw NetworkError.serverError("Request timed out. Please check your connection.")
                default:
                    throw NetworkError.serverError("Network error: \(urlError.localizedDescription)")
                }
            }
            throw NetworkError.serverError("Network error: \(error.localizedDescription)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Debug logging
        print("🌐 Request: \(method.rawValue) \(url)")
        print("🌐 Status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("🌐 Response: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error response
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                let errorMessage = errorResponse.error?.message ?? errorResponse.error_description ?? "Unknown error"
                let errorCode = errorResponse.error?.code ?? ""
                let messageLower = errorMessage.lowercased()
                let codeLower = errorCode.lowercased()
                
                print("❌ Error: \(errorMessage) (Code: \(errorCode))")
                
                // Parse Supabase error codes and messages
                // Supabase uses "invalid_grant" for invalid credentials
                if codeLower == "invalid_grant" || messageLower.contains("invalid login") || messageLower.contains("invalid password") || messageLower.contains("invalid credentials") {
                    // For invalid_grant, we can't distinguish between wrong email vs wrong password
                    // But typically Supabase returns this for wrong password when email exists
                    // We'll show "Incorrect password" as it's more common
                    throw NetworkError.invalidPassword
                } else if messageLower.contains("user not found") || messageLower.contains("email not found") || messageLower.contains("no user found") {
                    throw NetworkError.userNotFound
                } else if codeLower == "user_already_registered" || messageLower.contains("user already registered") || messageLower.contains("email already exists") || messageLower.contains("already registered") || messageLower.contains("already exists") {
                    throw NetworkError.emailExists
                } else {
                    throw NetworkError.serverError(errorMessage)
                }
            }
            
            // Try parsing as plain string
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Server error (raw): \(errorString)")
                let lowercased = errorString.lowercased()
                
                // Parse common error patterns
                if lowercased.contains("invalid_grant") || lowercased.contains("invalid login") || lowercased.contains("invalid password") || lowercased.contains("invalid credentials") {
                    throw NetworkError.invalidPassword
                } else if lowercased.contains("user not found") || lowercased.contains("email not found") || lowercased.contains("no user found") {
                    throw NetworkError.userNotFound
                } else if lowercased.contains("already registered") || lowercased.contains("email exists") || lowercased.contains("already exists") {
                    throw NetworkError.emailExists
                }
            }
            
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Token Management
    
    func saveToken(_ token: String) {
        accessToken = token
    }
    
    func clearToken() {
        accessToken = nil
    }
    
    func hasToken() -> Bool {
        return accessToken != nil
    }
}

// MARK: - Empty Response (for endpoints that don't return data)

struct EmptyResponse: Codable {
    // Empty response for endpoints that don't return data
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case decodingError
    case noConnection
    case invalidPassword
    case userNotFound
    case emailExists
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .serverError(let message):
            return message
        case .decodingError:
            return "Failed to decode response"
        case .noConnection:
            return "No internet connection. Please check your network."
        case .invalidPassword:
            return "Incorrect password"
        case .userNotFound:
            return "Email not found"
        case .emailExists:
            return "Email already registered"
        }
    }
}

// MARK: - Request/Response Models

struct SignUpRequest: Codable {
    let email: String
    let password: String
}

struct SignInRequest: Codable {
    let email: String
    let password: String
}

// Supabase Auth Response
struct SupabaseAuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: SupabaseUser
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
}

struct SupabaseUser: Codable {
    let id: String
    let email: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case createdAt = "created_at"
    }
}

struct SessionSyncRequest: Codable {
    let sessions: [SessionSyncData]
}

struct SessionSyncData: Codable {
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

struct SessionSyncResponse: Codable {
    let synced: Int
    let conflicts: Int
}

struct SessionsResponse: Codable {
    let sessions: [SessionSyncData]
    let total: Int
}

struct ErrorResponse: Codable {
    let error: ErrorDetail?
    let error_description: String? // Supabase auth format
    
    // Supabase auth errors can also be just a string
    enum CodingKeys: String, CodingKey {
        case error
        case error_description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        error_description = try? container.decode(String.self, forKey: .error_description)
        
        // Try to decode error as ErrorDetail first
        if let errorDetail = try? container.decode(ErrorDetail.self, forKey: .error) {
            error = errorDetail
        } else if let errorString = try? container.decode(String.self, forKey: .error) {
            // If error is a string (Supabase auth format), convert to ErrorDetail
            error = ErrorDetail(code: errorString, message: error_description ?? errorString)
        } else {
            error = nil
        }
    }
}

struct ErrorDetail: Codable {
    let code: String
    let message: String
    
    init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

