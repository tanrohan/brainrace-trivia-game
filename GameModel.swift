import Foundation

// MARK: - Game Model
/// Main game engine that manages the game state, questions, scoring, and player turns
class GameModel: ObservableObject {
    @Published var currentQuestion: Question
    @Published var player1Score = 0
    @Published var player2Score = 0
    @Published var currentRound = 1
    @Published var gameState: GameState = .player1Turn
    @Published var roundHistory: [RoundResult] = []
    @Published var player1Time: TimeInterval = 0
    @Published var player2Time: TimeInterval = 0
    @Published var player1RoundWins = 0
    @Published var player2RoundWins = 0
    
    // MARK: - Question Bank
    /// Collection of math questions used in the game
    private let questions = [
        Question(
            text: "If 2x + 5 = 13, what is the value of x?",
            correctAnswer: "4",
            options: ["3", "4", "5", "6"]
        ),
        Question(
            text: "What is the area of a circle with radius 3?",
            correctAnswer: "9π",
            options: ["6π", "9π", "12π", "15π"]
        ),
        Question(
            text: "If f(x) = 3x² - 2x + 1, what is f(2)?",
            correctAnswer: "9",
            options: ["7", "8", "9", "10"]
        ),
        Question(
            text: "What is the slope of the line passing through points (2,4) and (4,8)?",
            correctAnswer: "2",
            options: ["1", "2", "3", "4"]
        ),
        Question(
            text: "If log₂(x) = 3, what is x?",
            correctAnswer: "8",
            options: ["6", "7", "8", "9"]
        ),
        Question(
            text: "What is the derivative of x³?",
            correctAnswer: "3x²",
            options: ["2x²", "3x²", "4x²", "5x²"]
        ),
        Question(
            text: "What is the sum of the first 10 positive integers?",
            correctAnswer: "55",
            options: ["45", "50", "55", "60"]
        ),
        Question(
            text: "If sin(θ) = 0.5, what is θ in degrees?",
            correctAnswer: "30",
            options: ["15", "30", "45", "60"]
        ),
        Question(
            text: "What is the probability of rolling a 6 on a fair die?",
            correctAnswer: "1/6",
            options: ["1/4", "1/5", "1/6", "1/7"]
        ),
        Question(
            text: "What is the value of π (pi) to 2 decimal places?",
            correctAnswer: "3.14",
            options: ["3.12", "3.14", "3.16", "3.18"]
        )
    ]
    
    // MARK: - Game State
    /// Represents the possible states of the game
    enum GameState {
        case player1Turn        // Player 1 is answering
        case waitingForPlayer2  // Player 1 has answered, waiting for Player 2's turn
        case player2Turn        // Player 2 is answering
        case roundComplete      // Both players have answered
        case gameComplete       // A player has won 3 rounds
    }
    
    // MARK: - Question Structure
    /// Represents a single question with text, correct answer and options
    struct Question {
        let text: String
        let correctAnswer: String
        let options: [String]
    }
    
    // MARK: - Round Result Structure
    /// Stores the results of a single round
    struct RoundResult {
        let roundNumber: Int
        let question: Question
        let player1Answer: String
        let player2Answer: String
        let player1Time: TimeInterval
        let player2Time: TimeInterval
        let winner: Int? // 1 for player1, 2 for player2, nil for tie
    }
    
    // MARK: - Initialization
    /// Initialize the game with the first question
    init() {
        self.currentQuestion = questions[0]
    }
    
    // MARK: - Player 1 Answer Submission
    /// Process Player 1's answer and update game state
    func submitPlayer1Answer(_ answer: String, time: TimeInterval) {
        player1Time = time
        roundHistory.append(RoundResult(
            roundNumber: currentRound,
            question: currentQuestion,
            player1Answer: answer,
            player2Answer: "",
            player1Time: time,
            player2Time: 0,
            winner: nil
        ))
        gameState = .waitingForPlayer2
    }
    
    // MARK: - Player 2 Answer Submission
    /// Process Player 2's answer, determine round winner, and update game state
    func submitPlayer2Answer(_ answer: String, time: TimeInterval) {
        player2Time = time
        let player1Result = roundHistory.last!
        
        // Determine round winner based on new rules
        var winner: Int?
        let player1Correct = player1Result.player1Answer == currentQuestion.correctAnswer
        let player2Correct = answer == currentQuestion.correctAnswer
        
        if player1Correct && player2Correct {
            // Both correct - faster player wins
            winner = player1Result.player1Time < time ? 1 : 2
        } else if player1Correct {
            // Only player 1 correct
            winner = 1
        } else if player2Correct {
            // Only player 2 correct
            winner = 2
        }
        // If both incorrect, winner remains nil (tie)
        
        // Update round history
        roundHistory[roundHistory.count - 1] = RoundResult(
            roundNumber: currentRound,
            question: currentQuestion,
            player1Answer: player1Result.player1Answer,
            player2Answer: answer,
            player1Time: player1Result.player1Time,
            player2Time: time,
            winner: winner
        )
        
        // Update scores and round wins
        if let winner = winner {
            if winner == 1 {
                player1Score += 1
                player1RoundWins += 1
            } else {
                player2Score += 1
                player2RoundWins += 1
            }
        }
        
        // Check if either player has won 3 rounds
        if player1RoundWins >= 3 || player2RoundWins >= 3 {
            gameState = .gameComplete
        } else {
            // Move to next round
            currentRound += 1
            // Use modulo to wrap around to the beginning of questions array
            let questionIndex = (currentRound - 1) % questions.count
            currentQuestion = questions[questionIndex]
            gameState = .player1Turn
        }
    }
    
    // MARK: - Game Reset
    /// Reset all game values to their initial state
    func resetGame() {
        currentRound = 1
        player1Score = 0
        player2Score = 0
        player1Time = 0
        player2Time = 0
        player1RoundWins = 0
        player2RoundWins = 0
        currentQuestion = questions[0]
        gameState = .player1Turn
        roundHistory = []
    }
}
