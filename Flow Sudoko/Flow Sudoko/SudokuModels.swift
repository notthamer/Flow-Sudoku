//
//  SudokuModels.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 08/11/2025.
//

import Foundation

// MARK: - Cell Model
struct SudokuCell {
    var value: Int          // 0 = empty, 1-9 = number
    var isGiven: Bool       // true = pre-filled, false = editable
    var isValid: Bool       // for validation feedback
    var notes: Set<Int>     // Notes (small numbers) in the cell
    
    init(value: Int, isGiven: Bool) {
        self.value = value
        self.isGiven = isGiven
        self.isValid = true
        self.notes = []
    }
}

// MARK: - Puzzle Model
struct SudokuPuzzle: Codable {
    let id: Int
    let puzzle: [[Int]]
    let solution: [[Int]]
}

// MARK: - Puzzles Collection
struct SudokuPuzzles: Codable {
    let easy: [SudokuPuzzle]
    let medium: [SudokuPuzzle]
    let hard: [SudokuPuzzle]
}

// MARK: - Puzzle Loader
class SudokuPuzzleLoader {
    static let shared = SudokuPuzzleLoader()
    
    private var puzzles: SudokuPuzzles?
    
    private init() {
        loadPuzzles()
    }
    
    private func loadPuzzles() {
        guard let url = Bundle.main.url(forResource: "SudokuPuzzles", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to load SudokuPuzzles.json")
            return
        }
        
        do {
            puzzles = try JSONDecoder().decode(SudokuPuzzles.self, from: data)
            print("✅ Loaded Sudoku puzzles successfully")
        } catch {
            print("❌ Failed to decode puzzles: \(error)")
        }
    }
    
    func getRandomPuzzle(for difficulty: Difficulty) -> SudokuPuzzle? {
        guard let puzzles = puzzles else { return nil }
        
        let collection: [SudokuPuzzle]
        switch difficulty {
        case .easy:
            collection = puzzles.easy
        case .medium:
            collection = puzzles.medium
        case .hard:
            collection = puzzles.hard
        }
        
        return collection.randomElement()
    }
    
    func convertToBoard(_ puzzle: SudokuPuzzle) -> [[SudokuCell]] {
        var board: [[SudokuCell]] = []
        
        for row in 0..<9 {
            var rowCells: [SudokuCell] = []
            for col in 0..<9 {
                let value = puzzle.puzzle[row][col]
                let cell = SudokuCell(value: value, isGiven: value != 0)
                rowCells.append(cell)
            }
            board.append(rowCells)
        }
        
        return board
    }
    
    func validateMove(board: [[SudokuCell]], row: Int, col: Int, value: Int, solution: [[Int]]) -> Bool {
        return solution[row][col] == value
    }
    
    func isBoardComplete(board: [[SudokuCell]]) -> Bool {
        for row in board {
            for cell in row {
                if cell.value == 0 {
                    return false
                }
            }
        }
        return true
    }
}

