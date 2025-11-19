//
//  AuthService.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import Foundation
import Combine

// MARK: - Auth Service
// Currently local-only. Can be extended with Firebase/Supabase later.
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    private let userKey = "flow_sudoku_user"
    
    private init() {
        loadUser()
    }
    
    // MARK: - Authentication
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            completion(.failure(.unknown("Please enter both email and password")))
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            completion(.failure(.unknown("Please enter a valid email address")))
            return
        }
        
        Task {
            do {
                let request = SignInRequest(email: email.lowercased().trimmingCharacters(in: .whitespaces), password: password)
                let response: SupabaseAuthResponse = try await NetworkService.shared.request(
                    endpoint: "/auth/v1/token?grant_type=password",
                    method: .post,
                    body: request
                )
                
                // Save token
                NetworkService.shared.saveToken(response.accessToken)
                
                // Fetch user profile to get tier
                let tier = await fetchUserTier(userId: response.user.id)
                
                // Create user from response
                let user = User(
                    id: response.user.id,
                    email: response.user.email,
                    tier: tier,
                    createdAt: Date()
                )
                
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.saveUser()
                    
                    // Update SessionManager tier
                    var prefs = SessionManager.shared.preferences
                    prefs.tier = tier
                    SessionManager.shared.updatePreferences(prefs)
                    
                    completion(.success(user))
                }
            } catch {
                await MainActor.run {
                    print("🔴 Sign in error caught: \(error)")
                    print("🔴 Error type: \(type(of: error))")
                    if let networkError = error as? NetworkError {
                        print("🔴 NetworkError: \(networkError)")
                    }
                    let authError = self.mapError(error)
                    print("❌ Sign in error mapped: \(authError.localizedDescription ?? "Unknown error")")
                    completion(.failure(authError))
                }
            }
        }
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        // Validate input
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            completion(.failure(.unknown("Please fill in all fields")))
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            completion(.failure(.unknown("Please enter a valid email address")))
            return
        }
        
        guard password.count >= 6 else {
            completion(.failure(.unknown("Password must be at least 6 characters")))
            return
        }
        
        Task {
            do {
                let request = SignUpRequest(email: email.lowercased().trimmingCharacters(in: .whitespaces), password: password)
                let response: SupabaseAuthResponse = try await NetworkService.shared.request(
                    endpoint: "/auth/v1/signup",
                    method: .post,
                    body: request
                )
                
                // Save token
                NetworkService.shared.saveToken(response.accessToken)
                
                // Try to update/create user profile with first and last name
                // If this fails, that's okay - user is already created and we can continue
                do {
                    struct UserProfileInsert: Codable {
                        let id: String
                        let email: String
                        let tier: String
                        let firstName: String
                        let lastName: String
                        
                        enum CodingKeys: String, CodingKey {
                            case id, email, tier
                            case firstName = "first_name"
                            case lastName = "last_name"
                        }
                    }
                    
                    let profileInsert = UserProfileInsert(
                        id: response.user.id,
                        email: response.user.email,
                        tier: "free",
                        firstName: firstName,
                        lastName: lastName
                    )
                    
                    // Try to update existing profile using PATCH
                    struct UserProfileUpdate: Codable {
                        let firstName: String
                        let lastName: String
                        
                        enum CodingKeys: String, CodingKey {
                            case firstName = "first_name"
                            case lastName = "last_name"
                        }
                    }
                    
                    let profileUpdate = UserProfileUpdate(firstName: firstName, lastName: lastName)
                    
                    // First try to update if it exists
                    do {
                        let _: [UserProfileUpdate] = try await NetworkService.shared.request(
                            endpoint: "/rest/v1/user_profiles?id=eq.\(response.user.id)",
                            method: .patch,
                            body: profileUpdate,
                            requiresAuth: true
                        )
                        print("✅ Updated existing user profile")
                    } catch {
                        // If update fails, try to insert (might fail if already exists, that's okay)
                        do {
                            let _: [UserProfileInsert] = try await NetworkService.shared.request(
                                endpoint: "/rest/v1/user_profiles",
                                method: .post,
                                body: profileInsert,
                                requiresAuth: true
                            )
                            print("✅ Created new user profile")
                        } catch {
                            print("⚠️ Profile already exists or couldn't be created, continuing anyway: \(error)")
                        }
                    }
                } catch {
                    print("⚠️ Could not update profile, but continuing sign-up: \(error)")
                }
                
                // Fetch user tier (defaults to free if profile doesn't exist yet)
                let tier = await fetchUserTier(userId: response.user.id)
                
                // Create user from response
                let user = User(
                    id: response.user.id,
                    email: response.user.email,
                    tier: tier,
                    createdAt: Date()
                )
                
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.saveUser()
                    
                    // Update SessionManager tier
                    var prefs = SessionManager.shared.preferences
                    prefs.tier = tier
                    SessionManager.shared.updatePreferences(prefs)
                    
                    completion(.success(user))
                }
            } catch {
                print("❌ Sign up error: \(error)")
                await MainActor.run {
                    let authError = self.mapError(error)
                    completion(.failure(authError))
                }
            }
        }
    }
    
    // MARK: - Helper to fetch user tier from profile
    
    private func fetchUserTier(userId: String) async -> UserTier {
        do {
            struct ProfileResponse: Codable {
                let tier: String
            }
            
            let profiles: [ProfileResponse] = try await NetworkService.shared.request(
                endpoint: "/rest/v1/user_profiles?id=eq.\(userId)&select=tier",
                method: .get,
                requiresAuth: true
            )
            
            if let profile = profiles.first {
                return UserTier(rawValue: profile.tier) ?? .free
            }
            return .free
        } catch {
            print("⚠️ Failed to fetch user tier: \(error)")
            return .free
        }
    }
    
    func signOut() {
        Task {
            // Try to call Supabase sign out endpoint if we have a token
            // Note: Supabase logout might fail if token is expired, which is fine
            if NetworkService.shared.hasToken() {
                do {
                    // Supabase sign out endpoint - POST with auth header
                    let _: EmptyResponse = try await NetworkService.shared.request(
                        endpoint: "/auth/v1/logout",
                        method: .post,
                        requiresAuth: true
                    )
                    print("✅ Signed out from Supabase")
                } catch {
                    // If logout fails (e.g., token expired), that's okay - we'll clear local state anyway
                    print("⚠️ Supabase sign out failed (token may be expired, continuing): \(error)")
                }
            }
            
            await MainActor.run {
                currentUser = nil
                isAuthenticated = false
                UserDefaults.standard.removeObject(forKey: userKey)
                NetworkService.shared.clearToken()
                
                // Reset SessionManager to free tier
                var prefs = SessionManager.shared.preferences
                prefs.tier = .free
                SessionManager.shared.updatePreferences(prefs)
                
                print("👋 User signed out")
            }
        }
    }
    
    func continueAsGuest() {
        // User can use app without account (local only)
        isAuthenticated = false
        currentUser = nil
        print("👤 Continuing as guest")
    }
    
    // MARK: - Apple Sign In (Placeholder)
    
    func signInWithApple(completion: @escaping (Result<User, AuthError>) -> Void) {
        // TODO: Implement Apple Sign In
        completion(.failure(.notImplemented))
    }
    
    // MARK: - Persistence
    
    private func saveUser() {
        guard let user = currentUser else { return }
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: userKey)
            print("✅ User saved")
        } catch {
            print("❌ Failed to save user: \(error)")
        }
    }
    
    private func loadUser() {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isAuthenticated = true
            print("✅ User loaded: \(user.email)")
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapError(_ error: Error) -> AuthError {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidPassword:
                return .invalidPassword
            case .userNotFound:
                return .userNotFound
            case .emailExists:
                return .emailAlreadyExists
            case .noConnection:
                return .networkError
            case .decodingError:
                // Decoding error might mean wrong response format - show actual error
                return .unknown("Server response format error. Please try again.")
            case .serverError(let message):
                // Check if server error message indicates specific auth issues
                let messageLower = message.lowercased()
                if messageLower.contains("invalid") && (messageLower.contains("password") || messageLower.contains("login") || messageLower.contains("credentials")) {
                    return .invalidPassword
                } else if messageLower.contains("not found") || messageLower.contains("email not found") {
                    return .userNotFound
                } else if messageLower.contains("already") || messageLower.contains("exists") {
                    return .emailAlreadyExists
                } else {
                    // Return as unknown with the actual message
                    return .unknown(message)
                }
            case .httpError(let code):
                // HTTP errors - check if it's a known auth error code
                if code == 400 {
                    return .unknown("Invalid request. Please check your email and password.")
                } else if code == 401 {
                    return .invalidPassword
                } else if code == 404 {
                    return .userNotFound
                } else {
                    return .unknown("Server error (HTTP \(code)). Please try again.")
                }
            default:
                // For other network errors, check the description
                let desc = networkError.localizedDescription.lowercased()
                if desc.contains("cannot connect") || desc.contains("network") || desc.contains("connection") {
                    return .networkError
                }
                return .unknown(networkError.localizedDescription)
            }
        }
        
        // Check error message for common patterns
        let errorMessage = error.localizedDescription.lowercased()
        if errorMessage.contains("password") || errorMessage.contains("invalid login") || errorMessage.contains("invalid credentials") {
            return .invalidPassword
        } else if errorMessage.contains("not found") || errorMessage.contains("email not found") {
            return .userNotFound
        } else if errorMessage.contains("already") || errorMessage.contains("exists") {
            return .emailAlreadyExists
        } else if errorMessage.contains("cannot connect") || errorMessage.contains("network") || errorMessage.contains("connection") {
            return .networkError
        }
        
        return .unknown(error.localizedDescription)
    }
}

// MARK: - User Model

struct User: Codable {
    let id: String
    let email: String
    var tier: UserTier
    let createdAt: Date
    var lastSyncDate: Date?
    
    var displayEmail: String {
        // Mask email for privacy: t***@gmail.com
        let components = email.split(separator: "@")
        guard components.count == 2 else { return email }
        
        let username = String(components[0])
        let domain = String(components[1])
        
        if username.count <= 2 {
            return email
        }
        
        let masked = String(username.prefix(1)) + "***"
        return "\(masked)@\(domain)"
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidCredentials
    case invalidPassword
    case userNotFound
    case emailAlreadyExists
    case networkError
    case notImplemented
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidPassword:
            return "Incorrect password"
        case .userNotFound:
            return "Email not found"
        case .emailAlreadyExists:
            return "Email already registered"
        case .networkError:
            return "Network error. Please check your connection and try again"
        case .notImplemented:
            return "Feature coming soon"
        case .unknown(let message):
            return message
        }
    }
}

