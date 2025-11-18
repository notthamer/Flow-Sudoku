//
//  UpgradePromptView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import SwiftUI
import AppKit

struct UpgradePromptView: View {
    @State private var showContent: Bool = false
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(alignment: .center, spacing: 30) {
                // Checkmark icon
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.black.opacity(0.3))
                    .scaleEffect(showContent ? 1.0 : 0.8)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: showContent)
                
                VStack(spacing: 12) {
                    Text("DAILY SESSION COMPLETE")
                        .font(.custom("Anta-Regular", size: 24))
                        .foregroundColor(.black)
                        .tracking(2)
                    
                    Text("Come back tomorrow for your next session")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.black.opacity(0.5))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                
                // Divider
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 80, height: 1)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: showContent)
                
                // Upgrade message
                VStack(spacing: 16) {
                    Text("Want unlimited sessions?")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Button(action: {
                        openUpgradeWebsite()
                    }) {
                        HStack(spacing: 12) {
                            Text("UNLIMITED AT:")
                                .font(.custom("Anta-Regular", size: 14))
                                .foregroundColor(.black)
                                .tracking(2)
                            
                            Text("flowsudoku.com")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.black.opacity(0.7))
                            
                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 13))
                                .foregroundColor(.black.opacity(0.6))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(isHovered ? Color.black.opacity(0.03) : Color.clear)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(isHovered ? 1.03 : 1.0)
                    .animation(.easeOut(duration: 0.2), value: isHovered)
                    .onHover { hovering in
                        isHovered = hovering
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                
                // Studio features preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Studio includes:")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.black.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    FeatureRow(text: "Unlimited daily sessions")
                    FeatureRow(text: "Unlimited goals & pomodoros")
                    FeatureRow(text: "Full session history")
                    FeatureRow(text: "Premium themes")
                }
                .padding(20)
                .frame(width: 350)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.02))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: showContent)
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
    
    private func openUpgradeWebsite() {
        if let url = URL(string: "https://flowsudoku.com") {
            NSWorkspace.shared.open(url)
        }
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 12))
                .foregroundColor(.black.opacity(0.4))
            
            Text(text)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.black.opacity(0.6))
        }
    }
}

#Preview {
    UpgradePromptView()
}

