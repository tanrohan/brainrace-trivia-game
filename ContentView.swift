//
//  ContentView.swift
//  BrainBlast
//
//  Created by Rohan Tandon on 3/20/25.
//

import SwiftUI

// MARK: - Main Content View
/// Main view controller that manages the overall game flow and UI states
struct ContentView: View {
    // MARK: - Properties
    
    /// Game model that handles game logic and state
    @StateObject private var gameModel = GameModel()
    
    // Game state tracking
    @State private var gameStarted = false
    @State private var selectedTab = 0
    @State private var countdownNumber: Int?
    @State private var countdownTimer: Timer?
    
    // Default Player colors
    @State private var player1Color: Color = .cyan
    @State private var player2Color: Color = .red
    
    // UI state management
    @State private var showingColorSelection = false
    @State private var showingGameComplete = false
    
    /// Available player color options
    let availableColors: [Color] = [.cyan, .red, .green, .orange, .purple, .pink, .blue, .yellow]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Persistent background that stays consistent across all states
            if !gameStarted || showingColorSelection || countdownNumber != nil || showingGameComplete {
                // Background mesh gradient
                AnimatedMeshGradient()
                
                LinearGradient(
                    colors: [.black.opacity(0.9), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            }
            
            // Content views
            if !gameStarted {
                // Start Game View Content
                VStack(spacing: 30) {
                    Text("Brain Race")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .fontWidth(.expanded)
                        .foregroundStyle(.white)
                    
                    VStack(spacing: 10) {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                gameStarted = true
                                showingColorSelection = true
                            }
                        }) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 34))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(Color.white)
                                .frame(width: 88, height: 88)
                                .background(
                                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                                            .fill(Material.ultraThinMaterial).stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        Text("New Game")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .fontDesign(.rounded)
                    }
                    .padding(.horizontal, 150)
                }
            } else if showingColorSelection {
                // MARK: - Color Selection View
                // Allows players to choose their colors before starting the game
                VStack(spacing: 40) {
                    Text("Choose Colors")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .fontWidth(.expanded)
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 70) {
                        // Player 1 Color Selection
                        VStack(spacing: 20) {
                            Text("Player 1")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                            
                            ColorSelectionButton(
                                selectedColor: $player1Color,
                                availableColors: availableColors
                            )
                        }
                        
                        // Player 2 Color Selection
                        VStack(spacing: 20) {
                            Text("Player 2")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                            
                            ColorSelectionButton(
                                selectedColor: $player2Color,
                                availableColors: availableColors
                            )
                        }
                    }
                    
                    VStack(spacing: 10){
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                showingColorSelection = false
                                startCountdown()
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 34))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(Color.white)
                                .frame(width: 88, height: 88)
                                .background(
                                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                                            .fill(Material.ultraThinMaterial).stroke(Color.white.opacity(0.5), lineWidth: 1)
                                        )
                        }
                        Text("Ready")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .fontDesign(.rounded)
                    
                    }
                }
                .frame(width: 270) // Fixed width for consistent modal size
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.ultraThinMaterial)
                        .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                    )
                .padding(20)
                .transition(.move(edge: .bottom))
            } else if let countdown = countdownNumber {
                // MARK: - Countdown View
                // Shows countdown animation before game starts
                Text("\(countdown)")
                    .font(.system(size: 120, weight: .bold))
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .scaleEffect(1.2)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: countdown)
                    .transition(.move(edge: .bottom))
            } else if showingGameComplete {
                // MARK: - Game Complete View
                /// Displays the final results screen with player scores and navigation options
                GameCompleteView(
                    gameModel: gameModel,
                    player1Color: player1Color,
                    player2Color: player2Color,
                    onPlayAgain: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showingGameComplete = false
                            showingColorSelection = true
                        }
                    },
                    onMainMenu: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            gameStarted = false
                            showingGameComplete = false
                            gameModel.resetGame()
                        }
                    }
                )
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.ultraThinMaterial)
                        .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                )
                .padding(20)
                .transition(.asymmetric(
                    insertion: .modifier(
                        active: BlurModifier(radius: 20),
                        identity: BlurModifier(radius: 0)
                    ).combined(with: .opacity),
                    removal: .opacity
                ))
                
            } else {
                // MARK: - Game Play View
                // Main tab view containing Player 1 and Player 2 screens
                TabView(selection: $selectedTab) {
                    Player1View(
                        gameModel: gameModel,
                        gameStarted: $gameStarted,
                        playerColor: player1Color,
                        player1Color: player1Color,
                        player2Color: player2Color,
                        onGameComplete: {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                showingGameComplete = true
                            }
                        }
                    )
                    .tabItem {
                        Label("Player 1", systemImage: "person.fill")
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                    }
                    .tag(0)
                    
                    Player2View(
                        gameModel: gameModel,
                        gameStarted: $gameStarted,
                        playerColor: player2Color,
                        player1Color: player1Color,
                        player2Color: player2Color,
                        onGameComplete: {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                showingGameComplete = true
                            }
                        }
                    )
                .tabItem {
                        Label("Player 2", systemImage: "person.fill")
                            .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                    }
                    .tag(1)
                }
                .tint(selectedTab == 0 ? player1Color : player2Color)
                .transition(.asymmetric(
                    insertion: .modifier(
                        active: BlurModifier(radius: 20),
                        identity: BlurModifier(radius: 0)
                    ).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
    }
    
    // MARK: - Methods
    
    /// Starts the game countdown timer (3,2,1) before beginning the game
    private func startCountdown() {
        countdownNumber = 3
        gameStarted = true
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                if let current = countdownNumber, current > 1 {
                    countdownNumber = current - 1
                } else {
                    countdownTimer?.invalidate()
                    countdownTimer = nil
                    withAnimation(.easeInOut(duration: 0.8)) {
                        countdownNumber = nil
                    }
                    gameModel.resetGame()
                }
            }
        }
    }
}

// MARK: - Game Complete View
/// Displays the final results screen with player scores and navigation options
struct GameCompleteView: View {
    // MARK: - Properties
    let gameModel: GameModel
    let player1Color: Color
    let player2Color: Color
    let onPlayAgain: () -> Void
    let onMainMenu: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Final Result")
                .font(.largeTitle)
                .fontWeight(.medium)
                .fontWidth(.expanded)
                .foregroundStyle(.white)
            
            HStack(spacing: 70) {
                // Player 1 Score
                VStack(spacing: 20) {
                    Image(systemName: "brain.head.profile.fill")
                        .foregroundStyle(player1Color)
                        .font(.system(size: 24))
                        .font(.headline)
                    
                    Text("\(gameModel.player1Score)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(player1Color)
                    
                }
                .frame(width: 140) // Fixed width for player column
                
                // Player 2 Score
                VStack(spacing: 20) {
                    Image(systemName: "brain.head.profile.fill")
                        .foregroundStyle(player2Color)
                        .font(.system(size: 24))
                        .font(.headline)
                    
                    Text("\(gameModel.player2Score)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(player2Color)

                }
                .frame(width: 140) // Fixed width for player column
            }
            
            HStack(spacing: 30) {
                // Play Again Button
                VStack(spacing: 10) {
                    Button(action: onPlayAgain) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 34))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.white)
                            .frame(width: 88, height: 88)
                            .background(
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(Material.ultraThinMaterial).stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                    
                    Text("Play Again")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .fontDesign(.rounded)
                }
                
                // Main Menu Button
                VStack(spacing: 10) {
                    Button(action: onMainMenu) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 34))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.white)
                            .frame(width: 88, height: 88)
                            .background(
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(Material.ultraThinMaterial).stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                    
                    Text("Main Menu")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .fontDesign(.rounded)
                }
            }
        }
        .frame(width: 270) // Fixed width for consistent modal size

    }
}

// MARK: - Player 1 View
/// Displays the interface for Player 1 to answer questions and view results
struct Player1View: View {
    // MARK: - Properties
    @ObservedObject var gameModel: GameModel
    @Binding var gameStarted: Bool
    let playerColor: Color
    let player1Color: Color
    let player2Color: Color
    var onGameComplete: () -> Void
    
    // UI state management
    @State private var playerAnswer = ""
    @State private var showingResults = false
    @State private var timeRemaining: TimeInterval = 30
    @State private var timer: Timer?
    @State private var timerPaused = false
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        ZStack {
            // Background gradient for Player 1
            LinearGradient(
                colors: [playerColor.opacity(0.6), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Score Tracker and Timer - Always visible at top
                HStack {
                    ScoreTracker(player1Wins: gameModel.player1RoundWins, player2Wins: gameModel.player2RoundWins, isPlayer1: true, playerColor: player1Color)
                    Spacer()
                    // Timer
                    if gameModel.gameState == .player1Turn {
                        Text(String(format: "%.0f", timeRemaining))
                            .font(.system(size: 45, weight: .bold, design: .monospaced))
                            .foregroundColor(timerPaused ? .gray : playerColor)
                            .contentTransition(.numericText(countsDown: true))
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: timeRemaining)
                    }
                    Spacer()
                    ScoreTracker(player1Wins: gameModel.player1RoundWins, player2Wins: gameModel.player2RoundWins, isPlayer1: false, playerColor: player2Color)
                }
                .padding(.horizontal)
                .padding(.top)
                
                if gameModel.gameState == .player1Turn {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Question Card
                            VStack(spacing: 15) {
                                Text(gameModel.currentQuestion.text)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity)
                                    .id("question-\(gameModel.currentRound)")
                            }
                            .padding()
                            .padding(.horizontal, sizeClass == .compact ? 20 : 150)
                            .padding(.top, 20)

                            // Player Section
                            PlayerSection(
                                player: "",
                                answer: $playerAnswer,
                                isActive: true,
                                onSubmit: {
                                    stopTimer()
                                    let time = 30 - timeRemaining
                                    gameModel.submitPlayer1Answer(playerAnswer, time: time)
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        showingResults = true
                                    }
                                },
                                options: gameModel.currentQuestion.options,
                                has50_50Available: gameModel.player1RoundWins > 0,
                                question: gameModel.currentQuestion,
                                onHintShown: {
                                    pauseTimer()
                                },
                                onHintDismissed: {
                                    resumeTimer()
                                }
                            )
                            .padding(.horizontal, sizeClass == .compact ? 20 : 150)
                        }
                        .padding(.vertical)
                    }
                } else {
                    Spacer()
                    WaitingView(message: "Waiting for Player 2...")
                    Spacer()
                }
            }
            
            // Modal results view
            if showingResults {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack {
                    Spacer()
                    
                    Player1ResultsView(
                        gameModel: gameModel,
                        gameStarted: $gameStarted,
                        showingResults: $showingResults,
                        onGameComplete: onGameComplete
                    )
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(.ultraThinMaterial)
                            .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                    )
                    .padding(20)
                    .transition(.move(edge: .bottom))
                }
                .zIndex(1)
            }
        }
        // MARK: - View Lifecycle
        .onAppear {
            if gameModel.gameState == .player1Turn {
                startTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: gameModel.currentRound) { oldValue, newValue in
            // Reset timer when round changes and it's player 1's turn
            if gameModel.gameState == .player1Turn {
                startTimer()
            }
        }
        .onChange(of: gameModel.gameState) { oldValue, newValue in
            if newValue == .player1Turn {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    
    // MARK: - Timer Methods
    
    /// Starts the 30-second answer timer
    private func startTimer() {
        stopTimer()
        timeRemaining = 30
        timerPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            if !timerPaused && timeRemaining > 0 {
                timeRemaining -= 1
                
                if timeRemaining <= 0 {
                    stopTimer()
                    gameModel.submitPlayer1Answer("", time: 30)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showingResults = true
                    }
                }
            }
        }
    }
    
    /// Stops the timer and invalidates it
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Pauses the timer (used when hint is shown)
    private func pauseTimer() {
        print("Timer paused - Player 1")
        timerPaused = true
    }
    
    /// Resumes the timer (used when hint is dismissed)
    private func resumeTimer() {
        print("Timer resumed - Player 1")
        timerPaused = false
    }
}

// MARK: - Player 2 View
/// Displays the interface for Player 2 to answer questions and view results
struct Player2View: View {
    // MARK: - Properties
    @ObservedObject var gameModel: GameModel
    @Binding var gameStarted: Bool
    let playerColor: Color
    let player1Color: Color
    let player2Color: Color
    var onGameComplete: () -> Void
    
    // UI state management
    @State private var playerAnswer = ""
    @State private var showingResults = false
    @State private var timeRemaining: TimeInterval = 30
    @State private var timer: Timer?
    @State private var timerPaused = false
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        ZStack {
            // Background gradient for Player 1
            LinearGradient(
                colors: [playerColor.opacity(0.6), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Score Tracker and Timer - Always visible at top
                HStack {
                    ScoreTracker(player1Wins: gameModel.player1RoundWins, player2Wins: gameModel.player2RoundWins, isPlayer1: true, playerColor: player1Color)
                    Spacer()
                    // Timer
                    if gameModel.gameState == .player2Turn {
                        Text(String(format: "%.0f", timeRemaining))
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundColor(timerPaused ? .gray : playerColor)
                            .contentTransition(.numericText(countsDown: true))
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: timeRemaining)
                    }
                    Spacer()
                    ScoreTracker(player1Wins: gameModel.player1RoundWins, player2Wins: gameModel.player2RoundWins, isPlayer1: false, playerColor: player2Color)
                }
                .padding(.horizontal)
                .padding(.top)
                
                if gameModel.gameState == .player2Turn {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Question Card
                            VStack(spacing: 15) {
                                Text(gameModel.currentQuestion.text)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity)
                                    .id("question-\(gameModel.currentRound)")
                            }
                            .padding()
                            .padding(.horizontal, sizeClass == .compact ? 20 : 150)
                            .padding(.top, 20)
                            
                            // Player Section
                            PlayerSection(
                                player: "",
                                answer: $playerAnswer,
                                isActive: true,
                                onSubmit: {
                                    stopTimer()
                                    let time = 30 - timeRemaining
                                    gameModel.submitPlayer2Answer(playerAnswer, time: time)
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        showingResults = true
                                    }
                                },
                                options: gameModel.currentQuestion.options,
                                has50_50Available: gameModel.player2RoundWins > 0,
                                question: gameModel.currentQuestion,
                                onHintShown: {
                                    pauseTimer()
                                },
                                onHintDismissed: {
                                    resumeTimer()
                                }
                            )
                            .padding(.horizontal, sizeClass == .compact ? 20 : 150)
                        }
                        .padding(.vertical)
                    }
                } else {
                    Spacer()
                    WaitingView(message: "Waiting for Player 1...")
                    Spacer()
                }
            }
            
            // Modal results view
            if showingResults {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack {
                    Spacer()
                    
                    Player2ResultsView(
                        gameModel: gameModel,
                        gameStarted: $gameStarted,
                        showingResults: $showingResults,
                        onGameComplete: onGameComplete
                    )
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(.ultraThinMaterial)
                            .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                    )
                    .padding(20)
                    .transition(.move(edge: .bottom))
                }
                .zIndex(1)
            }
        }
        // MARK: - View Lifecycle
        .onAppear {
            // If we're waiting for Player 2, transition to Player 2's turn
            if gameModel.gameState == .waitingForPlayer2 {
                gameModel.gameState = .player2Turn
                startTimer()
            } else if gameModel.gameState == .player2Turn {
                startTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: gameModel.currentRound) { oldValue, newValue in
            // Reset timer when round changes and it's player 2's turn
            if gameModel.gameState == .player2Turn {
                startTimer()
            }
        }
        .onChange(of: gameModel.gameState) { oldValue, newValue in
            if newValue == .player2Turn {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    
    // MARK: - Timer Methods
    
    /// Starts the 30-second answer timer
    private func startTimer() {
        stopTimer()
        timeRemaining = 30
        timerPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            if !timerPaused && timeRemaining > 0 {
                timeRemaining -= 1
                
                if timeRemaining <= 0 {
                    stopTimer()
                    gameModel.submitPlayer2Answer("", time: 30)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showingResults = true
                    }
                }
            }
        }
    }
    
    /// Stops the timer and invalidates it
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Pauses the timer (used when hint is shown)
    private func pauseTimer() {
        print("Timer paused - Player 2")
        timerPaused = true
    }
    
    /// Resumes the timer (used when hint is dismissed)
    private func resumeTimer() {
        print("Timer resumed - Player 2")
        timerPaused = false
    }
}

// MARK: - Player 1 Results View
/// Displays the results modal for Player 1 after answering a question
struct Player1ResultsView: View {
    // MARK: - Properties
    @ObservedObject var gameModel: GameModel
    @Binding var gameStarted: Bool
    @Binding var showingResults: Bool
    var onGameComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Player 1 Results")
                .font(.title)
                .fontWeight(.medium)
                .fontWidth(.expanded)
                .foregroundStyle(.white)
            
            if let lastRound = gameModel.roundHistory.last {
                VStack(alignment: .leading, spacing: 15) {
                    ResultRow(title: "Question", value: lastRound.question.text)
                    ResultRow(title: "Your Answer", value: lastRound.player1Answer)
                    ResultRow(title: "Your Time", value: String(format: "%.2f", lastRound.player1Time) + "s")
                    
                    if lastRound.player1Answer == lastRound.question.correctAnswer {
                        Text("Correct!")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundColor(.green)
                        
                    } else {
                        Text("Incorrect")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundColor(.red)
                    }
                }
            }
            
            if gameModel.gameState == .gameComplete {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showingResults = false
                        onGameComplete()
                    }
                } label: {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 34))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.white)
                        .frame(width: 88, height: 88)
                        .background(
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(Material.ultraThinMaterial).stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                }
                
            } else {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showingResults = false
                    }
                } label:  {
                    Image(systemName: "play.fill")
                        .font(.system(size: 34))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.white)
                        .frame(width: 88, height: 88)
                        .background(
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(Material.ultraThinMaterial).stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                }
            }
        }
        .frame(width: 270) // Fixed width for consistent modal size
    }
}

// MARK: - Player 2 Results View
/// Displays the results modal for Player 2 after answering a question with round outcome
struct Player2ResultsView: View {
    // MARK: - Properties
    @ObservedObject var gameModel: GameModel
    @Binding var gameStarted: Bool
    @Binding var showingResults: Bool
    var onGameComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Round Results")
                .font(.title)
                .fontWeight(.medium)
                .fontWidth(.expanded)
                .foregroundStyle(.white)
            
            if let lastRound = gameModel.roundHistory.last {
                VStack(alignment: .leading, spacing: 15) {
                    ResultRow(title: "Question", value: lastRound.question.text)
                    ResultRow(title: "Player 1 Answer", value: lastRound.player1Answer)
                    ResultRow(title: "Your Answer", value: lastRound.player2Answer)
                    ResultRow(title: "Player 1 Time", value: String(format: "%.2f", lastRound.player1Time) + "s")
                    ResultRow(title: "Your Time", value: String(format: "%.2f", lastRound.player2Time) + "s")
                    
                    if let winner = lastRound.winner {
                        Text("Winner: Player \(winner)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundColor(.blue)
                            .padding(.top)
                    } else {
                        Text("Tie!")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundColor(.blue)
                            .padding(.top)
                    }
                }
            }
            
            if gameModel.gameState == .gameComplete {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showingResults = false
                        onGameComplete()
                    }
                } label: {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 34))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.white)
                        .frame(width: 88, height: 88)
                        .background(
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(Material.ultraThinMaterial).stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                }
                
            } else {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showingResults = false
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 34))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.white)
                        .frame(width: 88, height: 88)
                        .background(
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(Material.ultraThinMaterial).stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                }
            }
        }
        .frame(width: 270) // Fixed width for consistent modal size
    }
}

// MARK: - Score Tracker
/// Displays player win circles for tracking round wins
struct ScoreTracker: View {
    let player1Wins: Int
    let player2Wins: Int
    let isPlayer1: Bool
    let playerColor: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "brain.head.profile.fill")
                .foregroundStyle(playerColor)
                .font(.system(size: 24))
            
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Image(systemName: index < (isPlayer1 ? player1Wins : player2Wins) ?
                          "checkmark.circle.fill" : "circle")
                        .foregroundStyle(index < (isPlayer1 ? player1Wins : player2Wins) ?
                          Color.green : Color.gray.opacity(0.3))
                        .font(.system(size: 15))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Material.thinMaterial)
        .cornerRadius(20)
    }
}

// MARK: - Player Section
/// Interactive section showing answer options and helper buttons for players
struct PlayerSection: View {
    // MARK: - Properties
    let player: String
    @Binding var answer: String
    let isActive: Bool
    let onSubmit: () -> Void
    let options: [String]
    let has50_50Available: Bool
    let question: GameModel.Question
    var onHintShown: (() -> Void)?
    var onHintDismissed: (() -> Void)?
    
    // Array of letter symbols to use for options
    private let letterSymbols = ["a", "b", "c", "d"]
    
    @State private var filteredOptions: [String]? = nil
    @State private var showingHint = false
    
    // MARK: - Hint Generation
    /// Generates an appropriate hint based on the question content
    private func generateHint() -> String {
        let questionText = question.text.lowercased()
        
        // Specific question hints based on text pattern matching
        if questionText.contains("2x + 5 = 13") {
            return "Subtract 5 from both sides, then divide by 2 to isolate x."
        } else if questionText.contains("area of a circle with radius 3") {
            return "Use the formula for the area of a circle: A = πr². With radius 3, compute π × 3²."
        } else if questionText.contains("f(x) = 3x² - 2x + 1") && questionText.contains("f(2)") {
            return "Substitute x = 2 into the function: 3(2)² - 2(2) + 1 = 3(4) - 4 + 1."
        } else if questionText.contains("slope") && questionText.contains("(2,4)") && questionText.contains("(4,8)") {
            return "Calculate slope using (y₂-y₁)/(x₂-x₁) = (8-4)/(4-2)."
        } else if questionText.contains("log₂(x) = 3") {
            return "When log₂(x) = 3, it means 2³ = x, so x = 8."
        } else if questionText.contains("derivative of x³") {
            return "Use the power rule: d/dx(xⁿ) = n·xⁿ⁻¹. For x³, the derivative is 3x²."
        } else if questionText.contains("sum of the first 10 positive integers") {
            return "Use the formula n(n+1)/2 with n=10, or add: 1+2+3+4+5+6+7+8+9+10."
        } else if questionText.contains("sin(θ) = 0.5") {
            return "For sin(θ) = 0.5, θ is 30° or π/6 radians in the first quadrant."
        } else if questionText.contains("probability of rolling a 6") {
            return "On a fair die with 6 sides, the probability of any single number is 1/6."
        } else if questionText.contains("value of π") && questionText.contains("2 decimal places") {
            return "π is approximately 3.14 when rounded to 2 decimal places."
        }
        
        // General category hints as fallbacks
        else if questionText.contains("value of x") || questionText.contains("what is x") {
            return "Try substituting the values and solving the equation."
        } else if questionText.contains("area") {
            return "Remember the formula for the area - for circles it's πr²."
        } else if questionText.contains("f(x)") || questionText.contains("function") {
            return "Substitute the given value into the function and calculate step by step."
        } else if questionText.contains("slope") {
            return "Use the formula: slope = (y₂-y₁)/(x₂-x₁)."
        } else if questionText.contains("derivative") {
            return "Remember, the derivative of xⁿ is n·xⁿ⁻¹."
        } else if questionText.contains("log") {
            return "If log₂(x) = y, then 2ʸ = x."
        } else if questionText.contains("sum") {
            return "Consider using the formula: sum of first n integers = n(n+1)/2."
        } else if questionText.contains("sin") || questionText.contains("cos") || questionText.contains("tan") {
            return "Recall the values of common angles in the unit circle."
        } else if questionText.contains("probability") {
            return "Probability = favorable outcomes / total possible outcomes."
        } else if questionText.contains("pi") || questionText.contains("π") {
            return "Pi is approximately 3.14159..."
        }
        
        // Default hint if no specific pattern is matched
        return "Look for keywords in the question and try to apply the relevant formula or rule."
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Answer options grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(Array((filteredOptions ?? options).enumerated()), id: \.element) { index, option in
                    Button(action: {
                        answer = option
                        onSubmit()
                    }) {
                        HStack(spacing: 25) {
                            // Letter icon
                            Image(systemName: "\(letterSymbols[min(index, 3)]).circle.fill")
                                .font(.title3)
                                .foregroundStyle(answer == option ? .white : .secondary)
                                .padding(.leading, 10)
                            // Answer text
                            Text(option)
                                .font(.title)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(answer == option ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 80)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(answer == option ? .blue : .clear)
                                .opacity(answer == option ? 1 : 0)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(answer == option ? .blue : .gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .disabled(!isActive)
                }
            }
            
            // Helper buttons
            HStack(spacing: 20) {
                // 50/50 Button
                VStack {
                    Button(action: {
                        useFiftyFifty()
                    }) {
                        Image(systemName: "50.circle.fill")
                            .font(.system(size: 34))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 88, height: 88)
                            .background(
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(.thickMaterial)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .disabled(filteredOptions != nil || !isActive || !has50_50Available)
                    
                    Text("50/50")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(has50_50Available ? .accentColor : .gray)
                        .fontDesign(.rounded)
                }
                
                // Hint Button
                VStack {
                    Button {
                        // Call the hint shown callback before showing hint
                        if let onHintShown = onHintShown {
                            onHintShown()
                            print("Hint shown - timer should pause")
                        }
                        showingHint = true
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 34))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 88, height: 88)
                            .background(
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(.thickMaterial)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .disabled(!isActive)
                    .alert("Hint", isPresented: $showingHint) {
                        Button("OK") {
                            // Call the hint dismissed callback when dismissing hint
                            if let onHintDismissed = onHintDismissed {
                                onHintDismissed()
                                print("Hint dismissed - timer should resume")
                            }
                        }
                    } message: {
                        Text(generateHint())
                    }
                    
                    Text("Hint")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                        .fontDesign(.rounded)
                }
            }
            .padding(.top, 20)
        }
        .padding()
        .background(Material.thinMaterial)
        .cornerRadius(50)
        .overlay(
            RoundedRectangle(cornerRadius: 50)
                .stroke(.white.opacity(0.5), lineWidth: 0.5)
        )
    }
    
    // MARK: - 50/50 Lifeline
    /// Implements the 50/50 lifeline to eliminate two wrong answers
    private func useFiftyFifty() {
        // Keep the correct answer and one random wrong answer
        let correctAnswerIndex = options.firstIndex(of: question.correctAnswer) ?? (options.count - 1)
        var remainingOptions = [options[correctAnswerIndex]]
        
        // Add one random wrong answer
        let wrongOptions = options.indices.filter { $0 != correctAnswerIndex }
        if let randomWrongIndex = wrongOptions.randomElement(),
           randomWrongIndex < options.count {
            remainingOptions.append(options[randomWrongIndex])
        }
        
        // Shuffle the remaining options
        filteredOptions = remainingOptions.shuffled()
    }
}

// MARK: - Waiting View
/// Displays while waiting for the other player to take their turn
struct WaitingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 15) {
            Text(message)
                .font(.headline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
            
            Image(systemName: "brain.fill")
                .font(.system(size: 40))
                .symbolEffect(.pulse)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Result Row
/// Displays a title-value pair for showing results information
struct ResultRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(.body)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Score Card
/// Displays a player's score during the game
struct ScoreCard: View {
    let score: Int
    let player: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(player)
                .font(.body)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
            
            Text("\(score)")
                .font(.title)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundColor(color)
        }
        .frame(maxWidth: 120)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(18)
    }
}

// MARK: - Animated Mesh Gradient
/// Creates a dynamic, animated gradient background for the game's main screens
struct AnimatedMeshGradient: View {
    @State private var positions: [SIMD2<Float>] = [
        SIMD2<Float>(0.0, 0.0),
        SIMD2<Float>(0.5, 0.0),
        SIMD2<Float>(1.0, 0.0),
        SIMD2<Float>(0.0, 0.5),
        SIMD2<Float>(0.45, 0.55),
        SIMD2<Float>(1.0, 0.5),
        SIMD2<Float>(0.0, 1.0),
        SIMD2<Float>(0.5, 1.0),
        SIMD2<Float>(1.0, 1.0)
    ]
    
    let colors: [Color] = [
        Color(red: 0.000, green: 0.980, blue: 0.864),
        Color(red: 1.000, green: 0.000, blue: 0.733),
        Color(red: 0.576, green: 0.000, blue: 1.000),
        Color(red: 0.000, green: 1.000, blue: 0.603),
        Color(red: 0.000, green: 0.749, blue: 1.000),
        Color(red: 1.000, green: 0.000, blue: 0.465),
        Color(red: 0.924, green: 0.915, blue: 0.000),
        Color(red: 1.000, green: 0.535, blue: 0.000),
        Color(red: 0.922, green: 0.000, blue: 0.000)
    ]
    
    var body: some View {
        TimelineView(.animation) { phase in
            MeshGradient(
                width: 3,
                height: 3,
                locations: .points(animatedPositions(for: phase.date)),
                colors: .colors(colors),
                background: Color(red: 0.000, green: 0.000, blue: 0.000),
                smoothsColors: true
            )
        }
        .ignoresSafeArea()
    }
    
    /// Calculates the animated control point positions for the mesh gradient
    func animatedPositions(for date: Date) -> [SIMD2<Float>] {
        let phase = CGFloat(date.timeIntervalSince1970)
        var animatedPositions = positions
        
        // Animate some of the middle control points to create flowing effect
        animatedPositions[1].x = 0.5 + 0.1 * Float(sin(phase))
        animatedPositions[3].y = 0.5 + 0.1 * Float(cos(phase * 0.8))
        animatedPositions[4].x = 0.45 + 0.15 * Float(sin(phase * 0.7))
        animatedPositions[4].y = 0.55 + 0.1 * Float(cos(phase * 0.9))
        animatedPositions[5].y = 0.5 + 0.1 * Float(sin(phase * 1.2))
        animatedPositions[7].x = 0.5 + 0.1 * Float(cos(phase * 0.6))
        
        return animatedPositions
    }
}

// MARK: - Color Selection Button
/// Custom button that allows players to select their color from a popover menu
struct ColorSelectionButton: View {
    @Binding var selectedColor: Color
    let availableColors: [Color]
    @State private var showingPopover = false
    
    var body: some View {
        Button {
            showingPopover = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(selectedColor)
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .popover(isPresented: $showingPopover) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(availableColors, id: \.self) { color in
                        Button {
                            selectedColor = color
                            showingPopover = false
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Circle()
                                        .stroke(color == selectedColor ? .blue : .clear, lineWidth: 8)
                                        .stroke(color == selectedColor ? .white : .clear, lineWidth: 2)
                                )
                        }
                    }
                }
                .padding()
            }
            .frame(height: 50)
            .presentationCompactAdaptation(.popover)
        }
    }
}

// MARK: - Blur Modifier
/// Custom ViewModifier for applying blur effects in transitions
struct BlurModifier: ViewModifier {
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .blur(radius: radius)
    }
}

#Preview {
    ContentView()
}
