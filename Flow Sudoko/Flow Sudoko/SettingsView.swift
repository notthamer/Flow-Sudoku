//
//  SettingsView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var sessionManager = SessionManager.shared
    @ObservedObject private var authService = AuthService.shared
    @ObservedObject private var cloudSync = CloudSyncService.shared
    
    @State private var showContent: Bool = false
    @State private var showSignInSheet: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 50) {
                // Title
                Text("SETTINGS")
                    .font(.custom("Anta-Regular", size: 22))
                    .foregroundColor(.black)
                    .tracking(0.5)
                    .opacity(showContent ? 1 : 0)
                
                // Account Section
                VStack(alignment: .leading, spacing: 20) {
                    SettingsSectionHeader(title: "ACCOUNT")
                    
                    if authService.isAuthenticated, let user = authService.currentUser {
                        // Signed in state
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Signed in as")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(.black.opacity(0.5))
                                    
                                    Text(user.email)
                                        .font(.system(size: 16, weight: .light))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    authService.signOut()
                                }) {
                                    Text("SIGN OUT")
                                        .font(.custom("Anta-Regular", size: 13))
                                        .foregroundColor(.black.opacity(0.6))
                                        .tracking(1)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Sync status
                            HStack(spacing: 8) {
                                Image(systemName: cloudSync.syncStatus == .synced ? "checkmark.circle.fill" : "cloud")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black.opacity(0.4))
                                
                                Text(cloudSync.syncStatusText)
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(.black.opacity(0.5))
                                
                                Spacer()
                                
                                if cloudSync.syncStatus != .syncing {
                                    Button(action: {
                                        cloudSync.syncSessions { _ in }
                                    }) {
                                        Text("SYNC NOW")
                                            .font(.custom("Anta-Regular", size: 12))
                                            .foregroundColor(.black.opacity(0.6))
                                            .tracking(1)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.02))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                )
                        )
                    } else {
                        // Guest state
                        VStack(alignment: .leading, spacing: 12) {
                            Text("You're using Flow Sudoku as a guest")
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(.black.opacity(0.6))
                            
                            Text("Sign in to sync your sessions across devices")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.black.opacity(0.4))
                            
                            Button(action: {
                                showSignInSheet = true
                            }) {
                                Text("SIGN IN")
                                    .font(.custom("Anta-Regular", size: 14))
                                    .foregroundColor(.white)
                                    .tracking(2)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.black)
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.02))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.1), value: showContent)
                
                // Tier & Usage Section
                VStack(alignment: .leading, spacing: 20) {
                    SettingsSectionHeader(title: "YOUR PLAN")
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(sessionManager.preferences.tier == .free ? "FREE" : "STUDIO")
                                    .font(.custom("Anta-Regular", size: 18))
                                    .foregroundColor(.black)
                                    .tracking(1)
                                
                                Text(sessionManager.preferences.tier == .free ? "1 session per day" : "Unlimited sessions")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.black.opacity(0.5))
                            }
                            
                            Spacer()
                        }
                        
                        if sessionManager.preferences.tier == .free {
                            Button(action: {
                                openUpgradeWebsite()
                            }) {
                                HStack(spacing: 8) {
                                    Text("UPGRADE TO STUDIO")
                                        .font(.custom("Anta-Regular", size: 13))
                                        .foregroundColor(.black)
                                        .tracking(1)
                                    
                                    Image(systemName: "arrow.up.forward")
                                        .font(.system(size: 12))
                                        .foregroundColor(.black)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.02))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                
                // Preferences Section
                VStack(alignment: .leading, spacing: 20) {
                    SettingsSectionHeader(title: "PREFERENCES")
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Font Size
                        HStack {
                            Text("Default font size")
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    if sessionManager.preferences.fontSize > 14 {
                                        var prefs = sessionManager.preferences
                                        prefs.fontSize -= 2
                                        sessionManager.updatePreferences(prefs)
                                    }
                                }) {
                                    Text("−")
                                        .font(.system(size: 18))
                                        .foregroundColor(.black)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                                
                                Text("\(sessionManager.preferences.fontSize)px")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.black)
                                    .frame(width: 50)
                                
                                Button(action: {
                                    if sessionManager.preferences.fontSize < 28 {
                                        var prefs = sessionManager.preferences
                                        prefs.fontSize += 2
                                        sessionManager.updatePreferences(prefs)
                                    }
                                }) {
                                    Text("+")
                                        .font(.system(size: 18))
                                        .foregroundColor(.black)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Divider()
                            .background(Color.black.opacity(0.1))
                        
                        // Theme (locked for free tier)
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Theme")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(.black)
                                
                                if sessionManager.preferences.tier == .free {
                                    Text("Studio only")
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(.black.opacity(0.4))
                                        .italic()
                                }
                            }
                            
                            Spacer()
                            
                            Text("MINIMAL")
                                .font(.custom("Anta-Regular", size: 13))
                                .foregroundColor(.black.opacity(sessionManager.preferences.tier == .free ? 0.3 : 0.6))
                                .tracking(1)
                        }
                        .opacity(sessionManager.preferences.tier == .free ? 0.5 : 1.0)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.02))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: showContent)
                
                // Links Section
                VStack(alignment: .leading, spacing: 20) {
                    SettingsSectionHeader(title: "ABOUT")
                    
                    VStack(spacing: 0) {
                        SettingsLinkButton(title: "Privacy Policy", action: {
                            openPrivacyPolicy()
                        })
                        
                        Divider()
                            .background(Color.black.opacity(0.1))
                        
                        SettingsLinkButton(title: "Terms of Service", action: {
                            openTerms()
                        })
                        
                        Divider()
                            .background(Color.black.opacity(0.1))
                        
                        SettingsLinkButton(title: "Visit Website", action: {
                            openWebsite()
                        })
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.02))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                
                // App Info
                VStack(spacing: 8) {
                    Text("FLOW SUDOKU")
                        .font(.custom("Anta-Regular", size: 14))
                        .foregroundColor(.black.opacity(0.3))
                        .tracking(2)
                    
                    Text("Version 1.0.0")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.black.opacity(0.3))
                    
                    Text("© 2025 Flow Sudoku. All rights reserved.")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.black.opacity(0.25))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: showContent)
            }
            .padding(.horizontal, 60)
            .padding(.top, 40)
            .padding(.bottom, 100)
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
        .sheet(isPresented: $showSignInSheet) {
            SignInSheet(isPresented: $showSignInSheet)
        }
    }
    
    private func openUpgradeWebsite() {
        if let url = URL(string: "https://flowsudoku.com") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://flowsudoku.com/privacy") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openTerms() {
        if let url = URL(string: "https://flowsudoku.com/terms") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openWebsite() {
        if let url = URL(string: "https://flowsudoku.com") {
            NSWorkspace.shared.open(url)
        }
    }
}

struct SettingsSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom("Anta-Regular", size: 16))
            .foregroundColor(.black.opacity(0.3))
            .tracking(2)
    }
}

struct SettingsLinkButton: View {
    let title: String
    let action: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 12))
                    .foregroundColor(.black.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
            .background(isHovered ? Color.black.opacity(0.02) : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct SignInSheet: View {
    @Binding var isPresented: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var isSignUp: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    private let authService = AuthService.shared
    
    private var isValidEmail: Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return isValidEmail && password.count >= 6 && !firstName.isEmpty && !lastName.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 40) {
                    Text(isSignUp ? "CREATE ACCOUNT" : "SIGN IN")
                        .font(.custom("Anta-Regular", size: 24))
                        .foregroundColor(.black)
                        .tracking(2)
                    
                    VStack(spacing: 20) {
                        if isSignUp {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("First Name")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(.black.opacity(0.6))
                                    
                                    TextField("First name", text: $firstName)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 16, weight: .light))
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                        )
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Last Name")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(.black.opacity(0.6))
                                    
                                    TextField("Last name", text: $lastName)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 16, weight: .light))
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                        )
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.black.opacity(0.6))
                            
                            TextField("", text: $email)
                                .textFieldStyle(.plain)
                                .font(.system(size: 16, weight: .light))
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(email.isEmpty || isValidEmail ? Color.black.opacity(0.2) : Color.red.opacity(0.5), lineWidth: 1)
                                )
                            
                            if isSignUp && !email.isEmpty && !isValidEmail {
                                Text("Please enter a valid email address")
                                    .font(.system(size: 11, weight: .light))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.black.opacity(0.6))
                            
                            SecureField("", text: $password)
                                .textFieldStyle(.plain)
                                .font(.system(size: 16, weight: .light))
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                )
                            
                            if isSignUp && !password.isEmpty && password.count < 6 {
                                Text("Password must be at least 6 characters")
                                    .font(.system(size: 11, weight: .light))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.red)
                        }
                        
                        Button(action: handleAuth) {
                            Text(isSignUp ? "CREATE ACCOUNT" : "SIGN IN")
                                .font(.custom("Anta-Regular", size: 14))
                                .foregroundColor(.white)
                                .tracking(2)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.black)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading || !isFormValid)
                        .opacity(isLoading || !isFormValid ? 0.5 : 1.0)
                    }
                    .frame(width: isSignUp ? 450 : 350)
                    
                    Button(action: {
                        isSignUp.toggle()
                        errorMessage = nil
                        // Clear fields when switching
                        email = ""
                        password = ""
                        firstName = ""
                        lastName = ""
                    }) {
                        Text(isSignUp ? "Already have an account? Sign in" : "Don't have an account? Sign up")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
        }
        .frame(width: 500, height: 600)
    }
    
    private func handleAuth() {
        isLoading = true
        errorMessage = nil
        
        let completion: (Result<User, AuthError>) -> Void = { result in
            isLoading = false
            switch result {
            case .success:
                isPresented = false
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        
        if isSignUp {
            authService.signUp(email: email, password: password, firstName: firstName, lastName: lastName, completion: completion)
        } else {
            authService.signIn(email: email, password: password, completion: completion)
        }
    }
}

#Preview {
    SettingsView()
}

