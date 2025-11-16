//
//  BreathingView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 07/11/2025.
//

import SwiftUI

struct BreathingView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.3
    @State private var showText: Bool = false
    @State private var countdown: Int = 5
    
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 60) {
            Spacer()
            
            // Logo - replace "FlowLogo" with your image name from Assets
            Image("FlowLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.white)
            
            // Breathing Circle
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
            
            // Text
            VStack(spacing: 16) {
                if showText {
                    Text("Breathe")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white)
                        .transition(.opacity)
                    
                    Text("Clear your mind")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.7))
                        .transition(.opacity)
                }
            }
            .frame(height: 80)
            
            Spacer()
            
            // Countdown
            Text("\(countdown)")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .onAppear {
            startBreathingAnimation()
            startCountdown()
            
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                showText = true
            }
        }
    }
    
    private func startBreathingAnimation() {
        withAnimation(
            .easeInOut(duration: 4)
            .repeatForever(autoreverses: true)
        ) {
            scale = 1.3
            opacity = 0.8
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                onComplete()
            }
        }
    }
}

