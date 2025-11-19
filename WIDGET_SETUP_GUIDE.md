# Widget Extension Setup Guide

## Overview
This guide will help you add a macOS Widget Extension to display daily goals from Flow Sudoku.

## Step 1: Add Widget Extension Target in Xcode

1. Open `Flow Sudoko.xcodeproj` in Xcode
2. Go to **File → New → Target**
3. Select **Widget Extension** (under macOS)
4. Name it: `FlowSudokuWidget`
5. Uncheck "Include Configuration Intent" (we don't need it for now)
6. Click **Finish**
7. When prompted, click **Activate** to activate the scheme

## Step 2: Configure App Group

1. Select the **Flow Sudoko** target (main app)
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Add group: `group.com.flowsudoku.shared`
6. Repeat for the **FlowSudokuWidget** target

## Step 3: Add Files to Widget Target

1. Select `GoalData.swift` in the project navigator
2. In the File Inspector (right panel), under **Target Membership**, check **FlowSudokuWidget**
3. Do the same for any other shared files needed

## Step 4: Update Widget Code

Replace the default widget code with the provided `FlowSudokuWidget.swift` file.

## Step 5: Build and Run

1. Select the **FlowSudokuWidget** scheme
2. Build and run (Cmd+R)
3. The widget will appear in the widget gallery
4. Add it to your desktop or Notification Center

---

## Files Created

- `FlowSudokuWidget/FlowSudokuWidget.swift` - Main widget implementation
- `FlowSudokuWidget/FlowSudokuWidgetBundle.swift` - Widget bundle

Make sure these files are added to the **FlowSudokuWidget** target.

