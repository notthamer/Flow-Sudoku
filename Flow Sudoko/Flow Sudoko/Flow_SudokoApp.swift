//
//  Flow_SudokoApp.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 07/11/2025.
//

import SwiftUI
import AppKit

@main
struct Flow_SudokoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .onAppear {
                    // Configure window appearance
                    if let window = NSApplication.shared.windows.first {
                        window.titlebarAppearsTransparent = true
                        window.titleVisibility = .hidden
                        window.backgroundColor = .white
                        window.appearance = NSAppearance(named: .aqua)
                        window.standardWindowButton(.closeButton)?.isHidden = true
                        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                        window.standardWindowButton(.zoomButton)?.isHidden = true
                        
                        // Set minimum size and lock aspect ratio to wide horizontal rectangle
                        window.minSize = NSSize(width: 700, height: 400)
                        window.setContentSize(NSSize(width: 1000, height: 600))
                        window.aspectRatio = NSSize(width: 5, height: 3)
                        window.resizeIncrements = NSSize(width: 5, height: 3)
                        window.center()
                        
                        // Enter fullscreen on launch
                        window.toggleFullScreen(nil)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1000, height: 600)
    }
}
