//
//  IntentionView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 07/11/2025.
//

import SwiftUI

struct IntentionView: View {
    @State private var selectedIntention: Intention? = nil
    @State private var showOptions: Bool = false
    
    let onComplete: (Intention) -> Void
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            
            // Question
            VStack(spacing: 12) {
                Text("What brings you here?")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.white)
                
                Text("Set your intention")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Options
            VStack(spacing: 16) {
                if showOptions {
                    ForEach(Intention.allCases, id: \.self) { intention in
                        IntentionButton(
                            intention: intention,
                            isSelected: selectedIntention == intention
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedIntention = intention
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                onComplete(intention)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showOptions = true
            }
        }
    }
}

struct IntentionButton: View {
    let intention: Intention
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(intention.emoji)
                    .font(.system(size: 20))
                
                Text(intention.title)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(isSelected ? 1.0 : 0.3), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(isSelected ? 0.1 : 0))
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

enum Intention: CaseIterable {
    case focus
    case problemSolving
    case mentalReset
    case challenge
    
    var title: String {
        switch self {
        case .focus:
            return "Focus & Clarity"
        case .problemSolving:
            return "Problem Solving"
        case .mentalReset:
            return "Mental Reset"
        case .challenge:
            return "Challenge Myself"
        }
    }
    
    var emoji: String {
        switch self {
        case .focus:
            return "🎯"
        case .problemSolving:
            return "🧩"
        case .mentalReset:
            return "🌊"
        case .challenge:
            return "⚡"
        }
    }
}

