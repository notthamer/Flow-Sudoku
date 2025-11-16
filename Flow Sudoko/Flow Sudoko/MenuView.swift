//
//  MenuView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 07/11/2025.
//

import SwiftUI

struct MenuView: View {
    @State private var selectedMenuItem: MenuItem? = nil
    @State private var showMenu: Bool = false
    @State private var startGame: Bool = false
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var selectedDuration: Int = 15
    @State private var isFullscreen: Bool = true
    
    var body: some View {
        if startGame {
            SudokuGameView(difficulty: selectedDifficulty, duration: selectedDuration, onExit: {
                startGame = false
            })
        } else {
            menuView
        }
    }
    
    var menuView: some View {
        ZStack {
            // Pure white background
            Color.white
                .ignoresSafeArea()
            
            ZStack(alignment: .bottomTrailing) {
                HStack(spacing: 0) {
                // Left Menu
                VStack(alignment: .leading, spacing: 0) {
                    // Logo + Name
                    HStack(spacing: 4) {
                        Image("FlowLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                        
                        Text("FLOW SUDOKU")
                            .font(.custom("Anta-Regular", size: 28))
                            .foregroundColor(.black)
                            .tracking(2)
                    }
                    .padding(.leading, 30)
                    .padding(.top, 30)
                    .padding(.bottom, 80)
                    .opacity(showMenu ? 1 : 0)
                    .offset(y: showMenu ? 0 : -20)
                    
                    // Menu Items with staggered animation
                    VStack(alignment: .leading, spacing: 40) {
                        ForEach(Array(MenuItem.allCases.enumerated()), id: \.element) { index, item in
                            MenuItemView(
                                number: String(format: "%02d", index + 1),
                                title: item.title,
                                isSelected: selectedMenuItem == item
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedMenuItem = item
                                }
                            }
                            .opacity(showMenu ? 1 : 0)
                            .offset(x: showMenu ? 0 : -30)
                            .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: showMenu)
                        }
                    }
                    .padding(.leading, 50)
                    
                    Spacer()
                    
                    // Footer
                    Text("FLOW SUDOKU © 2025")
                        .font(.custom("Anta-Regular", size: 11))
                        .foregroundColor(.black.opacity(0.3))
                        .tracking(1)
                        .padding(.leading, 50)
                        .padding(.bottom, 40)
                        .opacity(showMenu ? 1 : 0)
                }
                .frame(width: 400)
                
                // Right Content Area
                if let selectedItem = selectedMenuItem {
                    ContentPanel(
                        menuItem: selectedItem,
                        selectedDifficulty: $selectedDifficulty,
                        selectedDuration: $selectedDuration,
                        startGame: $startGame
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
                } else {
                    Spacer()
                }
            }
            
            // Bottom right button
            Button(action: {
                if let window = NSApplication.shared.windows.first {
                    window.toggleFullScreen(nil)
                }
            }) {
                Text(isFullscreen ? "Minimize" : "Fullscreen")
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(.black.opacity(0.6))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 30)
            .padding(.bottom, 20)
            .opacity(showMenu ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showMenu = true
            }
            
            // Check if window is in fullscreen on appear
            if let window = NSApplication.shared.windows.first {
                isFullscreen = window.styleMask.contains(.fullScreen)
            }
            
            // Observe fullscreen changes
            NotificationCenter.default.addObserver(
                forName: NSWindow.didEnterFullScreenNotification,
                object: nil,
                queue: .main
            ) { _ in
                isFullscreen = true
            }
            
            NotificationCenter.default.addObserver(
                forName: NSWindow.didExitFullScreenNotification,
                object: nil,
                queue: .main
            ) { _ in
                isFullscreen = false
            }
        }
    }
}

struct MenuItemView: View {
    let number: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Text(number)
                    .font(.custom("Anta-Regular", size: 16))
                    .foregroundColor(.black.opacity(0.25))
                    .tracking(2)
                
                Text("→")
                    .font(.system(size: 22, weight: .ultraLight))
                    .foregroundColor(.black.opacity(isSelected ? 1.0 : 0.3))
                    .offset(x: isHovered ? 5 : 0)
                
                Text(title.uppercased())
                    .font(.custom("Anta-Regular", size: 24))
                    .foregroundColor(.black)
                    .tracking(0.5)
                
                Spacer()
                
                // Animated underline
                if isSelected {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 40, height: 2)
                        .transition(.scale(scale: 0, anchor: .leading).combined(with: .opacity))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isHovered)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct ContentPanel: View {
    let menuItem: MenuItem
    @Binding var selectedDifficulty: Difficulty
    @Binding var selectedDuration: Int
    @Binding var startGame: Bool
    
    var body: some View {
        VStack {
            switch menuItem {
            case .beginFlow:
                BeginFlowPanel(
                    selectedDifficulty: $selectedDifficulty,
                    selectedDuration: $selectedDuration,
                    startGame: $startGame
                )
            case .previousSessions:
                PlaceholderPanel(title: "Previous Sessions")
            case .howToPlay:
                PlaceholderPanel(title: "How to Play")
            case .settings:
                PlaceholderPanel(title: "Settings")
            }
        }
    }
}

struct BeginFlowPanel: View {
    @Binding var selectedDifficulty: Difficulty
    @Binding var selectedDuration: Int
    @Binding var startGame: Bool
    @State private var showContent: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(alignment: .center, spacing: 40) {
                // Difficulty Selection
                VStack(alignment: .center, spacing: 20) {
                    Text("SELECT DIFFICULTY")
                        .font(.custom("Anta-Regular", size: 22))
                        .foregroundColor(.black)
                        .tracking(0.5)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    HStack(spacing: 24) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            DifficultyButton(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: showContent)
                }
                
                // Duration Selection with Wheel Picker
                VStack(alignment: .center, spacing: 20) {
                    Text("DURATION")
                        .font(.custom("Anta-Regular", size: 22))
                        .foregroundColor(.black)
                        .tracking(0.5)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                    
                    DurationWheelPicker(selectedDuration: $selectedDuration)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: showContent)
                }
                
                // Start Button
                StartSessionButton(startGame: $startGame)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
            }
            .padding(.horizontal, 80)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

struct StartSessionButton: View {
    @Binding var startGame: Bool
    @State private var isHovered: Bool = false
    @State private var cursorVisible: Bool = true
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    startGame = true
                }
            }) {
                HStack(spacing: 4) {
                    Text("TRIGGER FLOW")
                        .font(.custom("Anta-Regular", size: 28))
                        .tracking(6)
                        .foregroundColor(.black)
                    
                    // Blinking cursor
                    Text("│")
                        .font(.system(size: 28, weight: .ultraLight))
                        .foregroundColor(.black)
                        .opacity(cursorVisible ? 1 : 0)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            .onAppear {
                // Blinking cursor animation
                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        cursorVisible.toggle()
                    }
                }
            }
            
            Text("press to begin")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(.black.opacity(0.4))
                .tracking(2)
        }
        .padding(.top, 40)
    }
}

struct DifficultyButton: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Text(difficulty.rawValue.uppercased())
                    .font(.custom("Anta-Regular", size: 16))
                    .foregroundColor(isSelected ? .black : .black.opacity(0.4))
                    .tracking(2)
                
                Rectangle()
                    .fill(isSelected ? Color.black : Color.black.opacity(0.15))
                    .frame(width: 50, height: 3)
                    .cornerRadius(2)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct DurationWheelPicker: View {
    @Binding var selectedDuration: Int
    @State private var minusHovered = false
    @State private var plusHovered = false
    
    var body: some View {
        HStack(spacing: 30) {
                // Minus button
                Button(action: {
                    if selectedDuration > 5 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedDuration -= 5
                        }
                    }
                }) {
                    Text("−")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .contentShape(Circle())
                        .background(
                            Circle()
                                .fill(Color.black.opacity(minusHovered ? 0.05 : 0))
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            .disabled(selectedDuration <= 5)
            .opacity(selectedDuration <= 5 ? 0.3 : 1.0)
            .scaleEffect(minusHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: minusHovered)
            .onHover { hovering in
                minusHovered = hovering
            }
            
            // Duration display
            VStack(spacing: 8) {
                Text("\(selectedDuration)")
                    .font(.system(size: 48, weight: .regular))
                    .foregroundColor(.black)
                    .tracking(1)
                
                Text("MINUTES")
                    .font(.custom("Anta-Regular", size: 14))
                    .foregroundColor(.black.opacity(0.4))
                    .tracking(3)
            }
            .frame(minWidth: 120)
            
                // Plus button
                Button(action: {
                    if selectedDuration < 120 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedDuration += 5
                        }
                    }
                }) {
                    Text("+")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .contentShape(Circle())
                        .background(
                            Circle()
                                .fill(Color.black.opacity(plusHovered ? 0.05 : 0))
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            .disabled(selectedDuration >= 120)
            .opacity(selectedDuration >= 120 ? 0.3 : 1.0)
            .scaleEffect(plusHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: plusHovered)
            .onHover { hovering in
                plusHovered = hovering
            }
        }
    }
}

struct PlaceholderPanel: View {
    let title: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(title.uppercased())
                .font(.custom("Anta-Regular", size: 24))
                .foregroundColor(.black.opacity(0.3))
            Text("COMING SOON")
                .font(.custom("Anta-Regular", size: 16))
                .foregroundColor(.black.opacity(0.3))
            Spacer()
        }
    }
}

enum MenuItem: CaseIterable {
    case beginFlow
    case previousSessions
    case howToPlay
    case settings
    
    var title: String {
        switch self {
        case .beginFlow:
            return "Begin Flow"
        case .previousSessions:
            return "Previous Sessions"
        case .howToPlay:
            return "How to Play"
        case .settings:
            return "Settings"
        }
    }
}

enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

#Preview {
    MenuView()
}

