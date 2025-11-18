//
//  HowToPlayView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import SwiftUI

struct HowToPlayView: View {
    @State private var showContent: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 50) {
                // Title
                Text("HOW TO PLAY")
                    .font(.custom("Anta-Regular", size: 22))
                    .foregroundColor(.black)
                    .tracking(0.5)
                    .opacity(showContent ? 1 : 0)
                
                // Flow Ritual Concept
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(title: "THE FLOW RITUAL")
                    
                    Text("Flow Sudoku is not just a puzzle — it's a focus ritual designed to prepare your mind for deep work.")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.black)
                        .lineSpacing(6)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        RitualStep(
                            number: "01",
                            title: "Warm Up Your Brain",
                            description: "Solve Sudoku puzzles to activate logical thinking and pattern recognition."
                        )
                        
                        RitualStep(
                            number: "02",
                            title: "Declutter Your Mind",
                            description: "Write freely to clear mental noise and surface what's really on your mind."
                        )
                        
                        RitualStep(
                            number: "03",
                            title: "Enter Flow State",
                            description: "Start your day with clarity, focus, and intention."
                        )
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.1), value: showContent)
                
                // Sudoku Rules
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(title: "SUDOKU RULES")
                    
                    Text("Fill the 9×9 grid so that each row, column, and 3×3 box contains the digits 1-9 without repetition.")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.black)
                        .lineSpacing(6)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        RuleItem(
                            icon: "square.grid.3x3",
                            text: "Each row must contain numbers 1-9"
                        )
                        RuleItem(
                            icon: "square.split.3x3",
                            text: "Each column must contain numbers 1-9"
                        )
                        RuleItem(
                            icon: "square.grid.3x3.fill",
                            text: "Each 3×3 box must contain numbers 1-9"
                        )
                        RuleItem(
                            icon: "pencil",
                            text: "Use notes mode to mark possible numbers"
                        )
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                
                // Declutter Writing
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(title: "DECLUTTER WRITING")
                    
                    Text("The declutter section is your mental workspace. Use it to:")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.black)
                        .lineSpacing(6)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        DeclutterTip(text: "Dump whatever is on your mind")
                        DeclutterTip(text: "List tasks that are causing anxiety")
                        DeclutterTip(text: "Note ideas that keep distracting you")
                        DeclutterTip(text: "Process emotions before starting work")
                        DeclutterTip(text: "Set clear intentions for your session")
                    }
                    
                    Text("There are no rules — just type freely. The goal is to clear mental space.")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.black.opacity(0.6))
                        .lineSpacing(6)
                        .italic()
                        .padding(.top, 8)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: showContent)
                
                // Tips for Best Experience
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(title: "TIPS FOR SUCCESS")
                    
                    VStack(alignment: .leading, spacing: 12) {
                        TipItem(
                            number: "1",
                            text: "Do this ritual at the same time each day to build a habit"
                        )
                        TipItem(
                            number: "2",
                            text: "Find a quiet space where you won't be interrupted"
                        )
                        TipItem(
                            number: "3",
                            text: "Don't rush — the process matters more than completion"
                        )
                        TipItem(
                            number: "4",
                            text: "Use the declutter section honestly and freely"
                        )
                        TipItem(
                            number: "5",
                            text: "Make mistakes part of the learning process"
                        )
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                
                // Difficulty Levels
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(title: "DIFFICULTY LEVELS")
                    
                    VStack(alignment: .leading, spacing: 16) {
                        DifficultyInfo(
                            level: "EASY",
                            description: "More given numbers, good for warming up or building confidence"
                        )
                        DifficultyInfo(
                            level: "MEDIUM",
                            description: "Balanced challenge, requires logic and attention"
                        )
                        DifficultyInfo(
                            level: "HARD",
                            description: "Fewer clues, demands advanced techniques and patience"
                        )
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
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
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom("Anta-Regular", size: 18))
            .foregroundColor(.black.opacity(0.3))
            .tracking(2)
    }
}

struct RitualStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Text(number)
                .font(.custom("Anta-Regular", size: 20))
                .foregroundColor(.black.opacity(0.25))
                .tracking(2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.custom("Anta-Regular", size: 16))
                    .foregroundColor(.black)
                    .tracking(0.5)
                
                Text(description)
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(.black.opacity(0.6))
                    .lineSpacing(4)
            }
        }
    }
}

struct RuleItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.4))
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.black)
        }
    }
}

struct DeclutterTip: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.black.opacity(0.2))
                .frame(width: 6, height: 6)
            
            Text(text)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.black)
        }
    }
}

struct TipItem: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.custom("Anta-Regular", size: 16))
                .foregroundColor(.black.opacity(0.3))
                .tracking(1)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.black)
                .lineSpacing(4)
        }
    }
}

struct DifficultyInfo: View {
    let level: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(level)
                .font(.custom("Anta-Regular", size: 15))
                .foregroundColor(.black)
                .tracking(1)
            
            Text(description)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.black.opacity(0.6))
                .lineSpacing(4)
        }
        .padding(.leading, 12)
        .padding(.vertical, 8)
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(width: 3),
            alignment: .leading
        )
    }
}

#Preview {
    HowToPlayView()
}

