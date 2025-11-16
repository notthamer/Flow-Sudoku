//
//  OnboardingView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 07/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentStep: OnboardingStep = .breathing
    @State private var opacity: Double = 0
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Group {
                switch currentStep {
                case .breathing:
                    BreathingView(onComplete: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentStep = .intention
                        }
                    })
                case .intention:
                    IntentionView(onComplete: { intention in
                        withAnimation(.easeInOut(duration: 0.8)) {
                            opacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            isOnboardingComplete = true
                        }
                    })
                }
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                opacity = 1
            }
        }
    }
}

enum OnboardingStep {
    case breathing
    case intention
}

