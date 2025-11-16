//
//  CinematicOnboardingView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 07/11/2025.
//

import SwiftUI

struct CinematicOnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    
    @State private var blurRadius: CGFloat = 50
    @State private var logoScale: CGFloat = 1.0
    @State private var logoOpacity: Double = 0
    @State private var typewriterText: String = ""
    @State private var showTypewriter: Bool = false
    @State private var gridOpacity: Double = 0
    @State private var animationStep: Int = 0
    @State private var showStartButton: Bool = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var buttonHovered: Bool = false
    @State private var buttonOffset: CGFloat = 0
    
    let fullText = "Trigger Your Flow State"
    
    var body: some View {
        ZStack {
            // White background with blur effect
            Color.white
                .blur(radius: blurRadius)
                .ignoresSafeArea()
            
            // Grid preview (fades in as blur clears)
            GridPreview()
                .opacity(gridOpacity)
                .blur(radius: blurRadius * 0.5)
            
            // Center content
            VStack(spacing: 30) {
                Spacer()
                
                // Logo
                Image("FlowLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                // Typewriter text
                if showTypewriter {
                    Text(typewriterText)
                        .font(.custom("Anta-Regular", size: 36))
                        .foregroundColor(.black)
                        .transition(.opacity)
                }
                
                Spacer()
            }
            
            // Start Button
            if showStartButton {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Button(action: {
                            startLockInTransition()
                        }) {
                            Text("TRIGGER FLOW")
                                .font(.custom("Anta-Regular", size: 32))
                                .foregroundColor(.black)
                                .tracking(4)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(buttonHovered ? 1.05 : buttonScale)
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                buttonHovered = hovering
                            }
                        }
                        
                        Text("press to begin")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.black.opacity(0.4))
                            .tracking(2)
                    }
                    .offset(y: buttonOffset)
                    .transition(.opacity.combined(with: .scale))
                    .onAppear {
                        // Start floating animation (more pronounced)
                        withAnimation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            buttonOffset = -15
                        }
                    }
                    
                    Spacer()
                        .frame(height: 80)
                }
            }
        }
        .onAppear {
            startCinematicSequence()
        }
    }
    
    private func startCinematicSequence() {
        // Step 1: Logo fades in sharp (1s)
        withAnimation(.easeIn(duration: 1.0)) {
            logoScale = 1.2
            logoOpacity = 1.0
        }
        
        // Step 2: After 1s, start typewriter (1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showTypewriter = true
            animateTypewriter()
        }
        
        // Step 3: After typewriter, blur clears outward (2s) and fade out text
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 2.0)) {
                blurRadius = 0
                gridOpacity = 0.3
            }
            
            // Fade out typewriter text
            withAnimation(.easeOut(duration: 0.8)) {
                showTypewriter = false
            }
        }
        
        // Step 4: Fade out grid, enlarge logo, show start button (1s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.2) {
            withAnimation(.easeInOut(duration: 0.8)) {
                logoScale = 3.0
                logoOpacity = 1.0
                gridOpacity = 0
            }
            
            // Show start button
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showStartButton = true
                }
            }
        }
    }
    
    private func animateTypewriter() {
        typewriterText = ""
        var currentIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { timer in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                typewriterText.append(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func startLockInTransition() {
        // Button press feedback
        withAnimation(.easeInOut(duration: 0.2)) {
            buttonScale = 0.95
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Fade everything out
            withAnimation(.easeOut(duration: 0.5)) {
                logoOpacity = 0
                showStartButton = false
            }
            
            // Complete transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isOnboardingComplete = true
            }
        }
    }
}

// Grid Preview Component
struct GridPreview: View {
    let cellSize: CGFloat = 50
    
    var body: some View {
        ZStack {
            // Background cells
            VStack(spacing: 0) {
                ForEach(0..<9) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<9) { col in
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: cellSize, height: cellSize)
                                .border(Color.black.opacity(0.15), width: 0.5)
                        }
                    }
                }
            }
            
            // Thick 3x3 box lines
            VStack(spacing: 0) {
                ForEach(0..<4) { i in
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: cellSize * 9, height: 2)
                        .offset(y: CGFloat(i) * cellSize * 3 - cellSize * 4.5 + 1)
                }
            }
            
            HStack(spacing: 0) {
                ForEach(0..<4) { i in
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 2, height: cellSize * 9)
                        .offset(x: CGFloat(i) * cellSize * 3 - cellSize * 4.5 + 1)
                }
            }
        }
    }
}

