//
//  PreviousSessionsView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import SwiftUI

struct PreviousSessionsView: View {
    @ObservedObject private var sessionManager = SessionManager.shared
    @State private var selectedSession: SessionData? = nil
    @State private var filterDifficulty: String = "all"
    @State private var showContent: Bool = false
    
    var filteredSessions: [SessionData] {
        sessionManager.getSessions(filteredBy: filterDifficulty == "all" ? nil : filterDifficulty)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if filteredSessions.isEmpty {
                emptyStateView
            } else {
                sessionsListView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            print("📊 PreviousSessionsView appeared")
            print("📊 Total sessions: \(sessionManager.sessions.count)")
            print("📊 Filtered sessions: \(filteredSessions.count)")
            
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                showContent = true
            }
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Text("NO SESSIONS YET")
                .font(.custom("Anta-Regular", size: 22))
                .foregroundColor(.black.opacity(0.3))
                .tracking(2)
            
            Text("Complete your first session to see it here")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.black.opacity(0.4))
        }
        .opacity(showContent ? 1 : 0)
    }
    
    var sessionsListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with filters
            HStack(spacing: 30) {
                Text("PREVIOUS SESSIONS")
                    .font(.custom("Anta-Regular", size: 22))
                    .foregroundColor(.black)
                    .tracking(0.5)
                
                Spacer()
                
                // Difficulty filter
                HStack(spacing: 12) {
                    FilterButton(title: "All", isSelected: filterDifficulty == "all") {
                        withAnimation(.easeOut(duration: 0.3)) {
                            filterDifficulty = "all"
                        }
                    }
                    FilterButton(title: "Easy", isSelected: filterDifficulty == "easy") {
                        withAnimation(.easeOut(duration: 0.3)) {
                            filterDifficulty = "easy"
                        }
                    }
                    FilterButton(title: "Medium", isSelected: filterDifficulty == "medium") {
                        withAnimation(.easeOut(duration: 0.3)) {
                            filterDifficulty = "medium"
                        }
                    }
                    FilterButton(title: "Hard", isSelected: filterDifficulty == "hard") {
                        withAnimation(.easeOut(duration: 0.3)) {
                            filterDifficulty = "hard"
                        }
                    }
                }
            }
            .padding(.horizontal, 60)
            .padding(.top, 40)
            .padding(.bottom, 30)
            .opacity(showContent ? 1 : 0)
            
            // Sessions list or detail view
            if let selected = selectedSession {
                SessionDetailView(session: selected) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        selectedSession = nil
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(filteredSessions.enumerated()), id: \.element.id) { index, session in
                            SessionRowView(session: session) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    selectedSession = session
                                }
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(x: showContent ? 0 : 30)
                            .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.05), value: showContent)
                        }
                    }
                    .padding(.horizontal, 60)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.custom("Anta-Regular", size: 14))
                .foregroundColor(isSelected ? .black : .black.opacity(0.4))
                .tracking(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isSelected ? Color.black.opacity(0.05) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black.opacity(isSelected ? 0.2 : 0.1), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct SessionRowView: View {
    let session: SessionData
    let onTap: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 30) {
                // Date and time
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(session.timestamp))
                        .font(.custom("Anta-Regular", size: 16))
                        .foregroundColor(.black)
                        .tracking(0.5)
                    
                    Text(formatTime(session.timestamp))
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.black.opacity(0.4))
                }
                .frame(width: 120, alignment: .leading)
                
                // Difficulty badge
                Text(session.difficulty.uppercased())
                    .font(.custom("Anta-Regular", size: 12))
                    .foregroundColor(.black.opacity(0.6))
                    .tracking(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(difficultyColor(session.difficulty))
                    )
                    .frame(width: 100)
                
                // Duration
                VStack(alignment: .leading, spacing: 2) {
                    Text("DURATION")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(.black.opacity(0.3))
                        .tracking(2)
                    Text(session.formattedDuration)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.black)
                }
                .frame(width: 80, alignment: .leading)
                
                // Completion status
                HStack(spacing: 6) {
                    Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14))
                        .foregroundColor(session.isCompleted ? .black : .black.opacity(0.3))
                    
                    Text(session.isCompleted ? "Completed" : "Incomplete")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.black.opacity(0.5))
                }
                .frame(width: 100, alignment: .leading)
                
                // Declutter snippet
                if !session.declutterText.isEmpty {
                    Text(session.declutterSnippet)
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.black.opacity(0.6))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("No notes")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.black.opacity(0.3))
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.black.opacity(0.3))
                    .offset(x: isHovered ? 5 : 0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? Color.black.opacity(0.02) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .padding(.bottom, 12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "easy":
            return Color.black.opacity(0.05)
        case "medium":
            return Color.black.opacity(0.08)
        case "hard":
            return Color.black.opacity(0.12)
        default:
            return Color.black.opacity(0.05)
        }
    }
}

struct SessionDetailView: View {
    let session: SessionData
    let onBack: () -> Void
    
    @State private var showContent: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with back button
            HStack(spacing: 20) {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14))
                        Text("BACK")
                            .font(.custom("Anta-Regular", size: 14))
                            .tracking(2)
                    }
                    .foregroundColor(.black.opacity(0.6))
                }
                .buttonStyle(.plain)
                
                Text("SESSION DETAILS")
                    .font(.custom("Anta-Regular", size: 22))
                    .foregroundColor(.black)
                    .tracking(0.5)
            }
            .padding(.horizontal, 60)
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            // Session info and declutter text
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    // Session metadata
                    HStack(spacing: 50) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DATE")
                                .font(.system(size: 11, weight: .light))
                                .foregroundColor(.black.opacity(0.3))
                                .tracking(2)
                            Text(session.formattedDate)
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(.black)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DIFFICULTY")
                                .font(.system(size: 11, weight: .light))
                                .foregroundColor(.black.opacity(0.3))
                                .tracking(2)
                            Text(session.difficulty.uppercased())
                                .font(.custom("Anta-Regular", size: 15))
                                .foregroundColor(.black)
                                .tracking(1)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DURATION")
                                .font(.system(size: 11, weight: .light))
                                .foregroundColor(.black.opacity(0.3))
                                .tracking(2)
                            Text(session.formattedDuration)
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(.black)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("STATUS")
                                .font(.system(size: 11, weight: .light))
                                .foregroundColor(.black.opacity(0.3))
                                .tracking(2)
                            HStack(spacing: 6) {
                                Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 14))
                                Text(session.isCompleted ? "Completed" : "Incomplete")
                                    .font(.system(size: 14, weight: .light))
                            }
                            .foregroundColor(.black)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MISTAKES")
                                .font(.system(size: 11, weight: .light))
                                .foregroundColor(.black.opacity(0.3))
                                .tracking(2)
                            Text("\(session.mistakeCount)")
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(.black)
                        }
                    }
                    
                    // Declutter section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("DECLUTTER NOTES")
                            .font(.custom("Anta-Regular", size: 16))
                            .foregroundColor(.black.opacity(0.3))
                            .tracking(2)
                        
                        if !session.declutterText.isEmpty {
                            Text(session.declutterText)
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.black)
                                .lineSpacing(6)
                                .textSelection(.enabled)
                        } else {
                            Text("No notes for this session")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.black.opacity(0.3))
                                .italic()
                        }
                    }
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                showContent = true
            }
        }
    }
}

#Preview {
    PreviousSessionsView()
}

