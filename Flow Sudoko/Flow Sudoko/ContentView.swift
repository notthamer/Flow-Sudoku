//
//  ContentView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 07/11/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var isOnboardingComplete: Bool = false
    
    var body: some View {
        ZStack {
            if isOnboardingComplete {
                MainGameView()
            } else {
                CinematicOnboardingView(isOnboardingComplete: $isOnboardingComplete)
            }
        }
        .frame(minWidth: 1000, minHeight: 700)
    }
}

// Placeholder for main game view
struct MainGameView: View {
    var body: some View {
        MenuView()
    }
}

#Preview {
    ContentView()
}
