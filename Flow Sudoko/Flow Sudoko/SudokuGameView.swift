//
//  SudokuGameView.swift
//  Flow Sudoko
//
//  Created by Thamer Al-Gahtani on 07/11/2025.
//

import SwiftUI

struct SudokuGameView: View {
    let difficulty: Difficulty
    let duration: Int
    var onExit: (() -> Void)? = nil
    
    @State private var timeElapsed: Int = 0
    @State private var timer: Timer?
    @State private var journalText: String = ""
    @State private var fontSize: CGFloat = 18
    @State private var isFullscreen: Bool = true
    @State private var mistakeCount: Int = 0
    @State private var showExitAlert: Bool = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                // Sudoku Board (60%)
                SudokuBoardView(difficulty: difficulty, mistakeCount: $mistakeCount, isFullscreen: $isFullscreen)
                    .frame(maxWidth: .infinity)
                
                // Sidebar (40%)
                VStack(alignment: .leading, spacing: 0) {
                    // Timer at top
                    HStack {
                        Text(formatTime(timeElapsed))
                            .font(.system(size: isFullscreen ? 18 : 14, weight: .light))
                            .foregroundColor(.black.opacity(0.4))
                            .tracking(1)
                        
                        Spacer()
                    }
                    .padding(.horizontal, isFullscreen ? 40 : 20)
                    .padding(.top, isFullscreen ? 40 : 20)
                    .padding(.bottom, isFullscreen ? 30 : 15)
                    
                    // Declutter section takes remaining space
                    VStack(alignment: .leading, spacing: isFullscreen ? 16 : 12) {
                        Text("DECLUTTER")
                            .font(.custom("Space Grotesk Bold", size: isFullscreen ? 12 : 10))
                            .foregroundColor(.black.opacity(0.3))
                            .tracking(3)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $journalText)
                                .font(.system(size: fontSize, weight: .light))
                                .foregroundColor(.black)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .tint(.black) // Typewriter cursor color
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            
                            if journalText.isEmpty {
                                Text("Type your first thought...")
                                    .font(.system(size: fontSize, weight: .light))
                                    .foregroundColor(.black.opacity(0.3))
                                    .padding(.top, 0)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .padding(.horizontal, isFullscreen ? 40 : 20)
                    .frame(maxHeight: .infinity)
                    
                    // Bottom toolbar
                    HStack(spacing: isFullscreen ? 20 : 12) {
                        // Font size control (clickable number)
                        Button(action: {
                            if fontSize < 26 {
                                fontSize += 2
                            } else {
                                fontSize = 18 // Reset to start
                            }
                        }) {
                            Text("\(Int(fontSize))px")
                                .font(.system(size: isFullscreen ? 15 : 12, weight: .light))
                                .foregroundColor(.black.opacity(0.6))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        // Main Menu button
                        Button(action: {
                            showExitAlert = true
                        }) {
                            Text("Main Menu")
                                .font(.system(size: isFullscreen ? 15 : 12, weight: .light))
                                .foregroundColor(.black.opacity(0.6))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Fullscreen/Minimize button
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
                    }
                    .padding(.horizontal, isFullscreen ? 40 : 20)
                    .padding(.vertical, isFullscreen ? 20 : 12)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
            }
            
            // Logo and Title at top corner
            HStack(spacing: 2) {
                Image("FlowLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isFullscreen ? 150 : 80, height: isFullscreen ? 150 : 80)
                
                Text("FLOW SUDOKU")
                    .font(.custom("Anta-Regular", size: isFullscreen ? 32 : 20))
                    .foregroundColor(.black)
                    .tracking(2)
            }
            .padding(.leading, isFullscreen ? 30 : 15)
            .padding(.top, isFullscreen ? 30 : 15)
            
            // Exit confirmation overlay
            if showExitAlert {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showExitAlert = false
                        }
                    
                    VStack(spacing: 30) {
                        Text("Are you sure you want to leave the session?")
                            .font(.custom("Anta-Regular", size: 18))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .tracking(1)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                showExitAlert = false
                            }) {
                                Text("CANCEL")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.black.opacity(0.6))
                                    .tracking(2)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                onExit?()
                            }) {
                                Text("LEAVE")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.white)
                                    .tracking(2)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.black)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(40)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                }
                .transition(.opacity)
            }
        }
        .background(Color.white)
        .onAppear {
            startTimer()
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
        .onDisappear {
            timer?.invalidate()
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeElapsed += 1
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

struct SudokuBoardView: View {
    let difficulty: Difficulty
    @Binding var mistakeCount: Int
    @Binding var isFullscreen: Bool
    
    @State private var board: [[SudokuCell]] = []
    @State private var selectedCell: (row: Int, col: Int)? = nil
    @State private var puzzle: SudokuPuzzle?
    @State private var isComplete: Bool = false
    @State private var blurRadius: CGFloat = 0
    @State private var notesMode: Bool = false
    
    var cellSize: CGFloat {
        isFullscreen ? 60 : 40
    }
    
    var body: some View {
        VStack(spacing: isFullscreen ? 40 : 20) {
            Spacer()
                .frame(height: isFullscreen ? 120 : 60)
            
            if !board.isEmpty {
                VStack(spacing: isFullscreen ? 30 : 15) {
                    // Difficulty and Mistakes counter at top
                    ZStack {
                        // Difficulty on the left
                        HStack {
                            Text("Difficulty: \(difficulty.rawValue.capitalized)")
                                .font(.system(size: isFullscreen ? 14 : 10, weight: .light))
                                .foregroundColor(.black.opacity(0.5))
                                .tracking(1)
                            
                            Spacer()
                        }
                        
                        // Mistakes centered
                        HStack {
                            Spacer()
                            Text("Mistakes: \(mistakeCount)/3")
                                .font(.system(size: isFullscreen ? 14 : 10, weight: .light))
                                .foregroundColor(mistakeCount >= 3 ? .red : .black.opacity(0.5))
                                .tracking(1)
                            Spacer()
                        }
                    }
                    .frame(width: cellSize * 9)
                    
                    // Sudoku Grid
                    VStack(spacing: 0) {
                        ForEach(0..<9, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<9, id: \.self) { col in
                                    SudokuCellView(
                                        value: board[row][col].value,
                                        isGiven: board[row][col].isGiven,
                                        isValid: board[row][col].isValid,
                                        notes: board[row][col].notes,
                                        isSelected: selectedCell?.row == row && selectedCell?.col == col,
                                        isHighlighted: shouldHighlight(row: row, col: col),
                                        isSameNumber: isSameNumber(row: row, col: col),
                                        row: row,
                                        col: col,
                                        cellSize: cellSize,
                                        isFullscreen: isFullscreen
                                    ) {
                                        selectedCell = (row, col)
                                    }
                                }
                            }
                        }
                    }
                    .overlay(
                        // Thick borders for 3x3 boxes
                        GeometryReader { geometry in
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                
                                // Vertical lines
                                for i in 0...3 {
                                    let x = CGFloat(i) * width / 3
                                    path.move(to: CGPoint(x: x, y: 0))
                                    path.addLine(to: CGPoint(x: x, y: height))
                                }
                                
                                // Horizontal lines
                                for i in 0...3 {
                                    let y = CGFloat(i) * height / 3
                                    path.move(to: CGPoint(x: 0, y: y))
                                    path.addLine(to: CGPoint(x: width, y: y))
                                }
                            }
                            .stroke(Color.black, lineWidth: 3)
                        }
                    )
                    .frame(width: cellSize * 9, height: cellSize * 9)
                    .blur(radius: blurRadius)
                }
                
                // Number input buttons
                VStack(spacing: isFullscreen ? 16 : 12) {
                    // Numbers 1-9
                    HStack(spacing: isFullscreen ? 20 : 12) {
                        ForEach(1...9, id: \.self) { number in
                            let isNumberComplete = isNumberCompleted(number)
                            
                            if !isNumberComplete {
                                Button(action: {
                                    if let cell = selectedCell, !board[cell.row][cell.col].isGiven, mistakeCount < 3 {
                                        if notesMode {
                                            // Notes mode: toggle note
                                            if board[cell.row][cell.col].notes.contains(number) {
                                                board[cell.row][cell.col].notes.remove(number)
                                            } else {
                                                board[cell.row][cell.col].notes.insert(number)
                                            }
                                        } else {
                                            // Normal mode: place number
                                            // Track previous state
                                            let hadWrongNumber = !board[cell.row][cell.col].isValid && board[cell.row][cell.col].value != 0
                                            
                                            board[cell.row][cell.col].value = number
                                            board[cell.row][cell.col].notes = [] // Clear notes when placing number
                                            
                                            // Validate the move
                                            if let puzzle = puzzle {
                                                let isCorrect = SudokuPuzzleLoader.shared.validateMove(
                                                    board: board,
                                                    row: cell.row,
                                                    col: cell.col,
                                                    value: number,
                                                    solution: puzzle.solution
                                                )
                                                board[cell.row][cell.col].isValid = isCorrect
                                                
                                                // Count mistakes
                                                if !isCorrect {
                                                    // New wrong number placed
                                                    if !hadWrongNumber {
                                                        mistakeCount += 1
                                                        print("❌ Mistake! Count: \(mistakeCount)")
                                                    }
                                                } else {
                                                    // Correct number placed
                                                    if hadWrongNumber {
                                                        mistakeCount -= 1
                                                        print("✅ Fixed mistake! Count: \(mistakeCount)")
                                                    }
                                                }
                                                
                                                // Check if puzzle is complete
                                                checkPuzzleCompletion()
                                            }
                                        }
                                    }
                                }) {
                                    Text("\(number)")
                                        .font(.custom("Anta-Regular", size: isFullscreen ? 40 : 28))
                                        .foregroundColor(.black)
                                        .frame(width: isFullscreen ? 50 : 35, height: isFullscreen ? 50 : 35)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .disabled(mistakeCount >= 3)
                                .opacity(mistakeCount >= 3 ? 0.3 : 1.0)
                            } else {
                                // Empty spacer to maintain layout
                                Color.clear
                                    .frame(width: isFullscreen ? 50 : 35, height: isFullscreen ? 50 : 35)
                            }
                        }
                    }
                    
                    // Undo, Erase, and Notes buttons
                    HStack(spacing: isFullscreen ? 16 : 10) {
                        // Undo button
                        Button(action: {
                            if let cell = selectedCell, !board[cell.row][cell.col].isGiven {
                                // Clear the cell (don't affect mistake count)
                                board[cell.row][cell.col].value = 0
                                board[cell.row][cell.col].isValid = true
                                
                                // Reset completion state if undoing
                                if isComplete {
                                    isComplete = false
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        blurRadius = 0
                                    }
                                }
                            }
                        }) {
                            HStack(spacing: isFullscreen ? 8 : 6) {
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.system(size: isFullscreen ? 16 : 12, weight: .regular))
                                Text("Undo")
                                    .font(.custom("Anta-Regular", size: isFullscreen ? 16 : 12))
                                    .tracking(1)
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, isFullscreen ? 24 : 16)
                            .padding(.vertical, isFullscreen ? 12 : 8)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: isFullscreen ? 20 : 15)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Erase button
                        Button(action: {
                            if let cell = selectedCell, !board[cell.row][cell.col].isGiven {
                                if notesMode {
                                    // Clear all notes
                                    board[cell.row][cell.col].notes = []
                                } else {
                                    // Clear number (don't affect mistake count)
                                    board[cell.row][cell.col].value = 0
                                    board[cell.row][cell.col].isValid = true
                                    
                                    if isComplete {
                                        isComplete = false
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            blurRadius = 0
                                        }
                                    }
                                }
                            }
                        }) {
                            HStack(spacing: isFullscreen ? 8 : 6) {
                                Image(systemName: "xmark")
                                    .font(.system(size: isFullscreen ? 16 : 12, weight: .regular))
                                Text("Erase")
                                    .font(.custom("Anta-Regular", size: isFullscreen ? 16 : 12))
                                    .tracking(1)
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, isFullscreen ? 24 : 16)
                            .padding(.vertical, isFullscreen ? 12 : 8)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: isFullscreen ? 20 : 15)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Notes toggle button
                        Button(action: {
                            notesMode.toggle()
                        }) {
                            HStack(spacing: isFullscreen ? 8 : 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: isFullscreen ? 16 : 12, weight: .regular))
                                Text("Notes")
                                    .font(.custom("Anta-Regular", size: isFullscreen ? 16 : 12))
                                    .tracking(1)
                            }
                            .foregroundColor(notesMode ? .white : .black)
                            .padding(.horizontal, isFullscreen ? 24 : 16)
                            .padding(.vertical, isFullscreen ? 12 : 8)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: isFullscreen ? 20 : 15)
                                    .fill(notesMode ? Color.black : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: isFullscreen ? 20 : 15)
                                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Spacer()
        }
        .background(Color.white)
        .onAppear {
            loadPuzzle()
        }
    }
    
    private func loadPuzzle() {
        guard let loadedPuzzle = SudokuPuzzleLoader.shared.getRandomPuzzle(for: difficulty) else {
            print("❌ Failed to load puzzle for difficulty: \(difficulty)")
            return
        }
        
        puzzle = loadedPuzzle
        board = SudokuPuzzleLoader.shared.convertToBoard(loadedPuzzle)
    }
    
    private func shouldHighlight(row: Int, col: Int) -> Bool {
        guard let selected = selectedCell else { return false }
        
        // Don't highlight the selected cell itself
        if row == selected.row && col == selected.col {
            return false
        }
        
        // Highlight if in same row, column, or 3x3 box
        let sameRow = row == selected.row
        let sameCol = col == selected.col
        let sameBox = (row / 3 == selected.row / 3) && (col / 3 == selected.col / 3)
        
        return sameRow || sameCol || sameBox
    }
    
    private func isSameNumber(row: Int, col: Int) -> Bool {
        guard let selected = selectedCell else { return false }
        
        // Don't highlight the selected cell itself
        if row == selected.row && col == selected.col {
            return false
        }
        
        // Highlight if same number as selected cell (and not empty)
        let selectedValue = board[selected.row][selected.col].value
        let currentValue = board[row][col].value
        
        return selectedValue != 0 && currentValue == selectedValue
    }
    
    private func isNumberCompleted(_ number: Int) -> Bool {
        var count = 0
        for row in board {
            for cell in row {
                if cell.value == number {
                    count += 1
                }
            }
        }
        return count >= 9
    }
    
    private func checkPuzzleCompletion() {
        // Check if all cells are filled
        var isFilled = true
        var allValid = true
        
        for row in board {
            for cell in row {
                if cell.value == 0 {
                    isFilled = false
                }
                if !cell.isValid {
                    allValid = false
                }
            }
        }
        
        if isFilled && allValid {
            isComplete = true
            // Animate blur effect
            withAnimation(.easeInOut(duration: 1.5)) {
                blurRadius = 40
            }
        }
    }
}

struct SudokuCellView: View {
    let value: Int
    let isGiven: Bool
    let isValid: Bool
    let notes: Set<Int>
    let isSelected: Bool
    let isHighlighted: Bool
    let isSameNumber: Bool
    let row: Int
    let col: Int
    let cellSize: CGFloat
    let isFullscreen: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
            
            if value != 0 {
                // Main number
                Text("\(value)")
                    .font(.custom("Anta-Regular", size: isFullscreen ? 32 : 22))
                    .foregroundStyle(!isValid && !isGiven ? Color.red : Color.black)
            } else if !notes.isEmpty {
                // Notes in 3x3 grid
                VStack(spacing: isFullscreen ? 2 : 1) {
                    ForEach(0..<3, id: \.self) { rowIndex in
                        HStack(spacing: isFullscreen ? 2 : 1) {
                            ForEach(0..<3, id: \.self) { colIndex in
                                let noteNumber = rowIndex * 3 + colIndex + 1
                                Text(notes.contains(noteNumber) ? "\(noteNumber)" : " ")
                                    .font(.custom("Anta-Regular", size: isFullscreen ? 10 : 7))
                                    .foregroundColor(.black.opacity(0.6))
                                    .frame(width: isFullscreen ? 18 : 12, height: isFullscreen ? 18 : 12)
                            }
                        }
                    }
                }
            }
        }
        .overlay(
            Rectangle()
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
        )
        .frame(width: cellSize, height: cellSize)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.black.opacity(0.15) // Darker grey for selected cell
        } else if isSameNumber {
            return Color.black.opacity(0.06) // Medium grey for same number
        } else if isHighlighted {
            return Color.black.opacity(0.03) // Very light grey for row/column/box
        } else {
            return Color.white
        }
    }
}

#Preview {
    @Previewable @State var mistakes = 0
    @Previewable @State var fullscreen = true
    SudokuBoardView(difficulty: .medium, mistakeCount: $mistakes, isFullscreen: $fullscreen)
}

