//
//  TestConfig.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 16/11/2025.
//

import Foundation

// MARK: - Test Configuration
// Set TEST_MODE to true for easier testing with lower limits
struct TestConfig {
    // Change this to true to test with 1 goal limit instead of 3
    static let TEST_MODE = false
    
    // Test mode limits (only used if TEST_MODE = true)
    static let testFreeGoalLimit = 1
    static let testFreeSessionLimit = 1
}

