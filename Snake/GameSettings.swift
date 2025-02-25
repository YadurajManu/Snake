import Foundation

// Game Difficulty Settings
enum Difficulty: String, CaseIterable, Codable {
    case easy
    case medium
    case hard
    
    var speed: TimeInterval {
        switch self {
        case .easy: return 0.3
        case .medium: return 0.2
        case .hard: return 0.1
        }
    }
    
    var boardSize: Int {
        switch self {
        case .easy: return 12
        case .medium: return 15
        case .hard: return 20
        }
    }
    
    var scoreMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        }
    }
}

// Game Modes
enum GameMode: String, CaseIterable, Codable {
    case classic
    case timeTrialMode
    case mazeMode
    case portalMode
}

// Power-up Types
enum PowerUpType: String, CaseIterable, Codable {
    case speedBoost
    case scoreMultiplier
    case shield
    case ghostMode
    
    var duration: TimeInterval {
        switch self {
        case .speedBoost: return 5
        case .scoreMultiplier: return 10
        case .shield: return 8
        case .ghostMode: return 6
        }
    }
    
    var color: String {
        switch self {
        case .speedBoost: return "yellow"
        case .scoreMultiplier: return "purple"
        case .shield: return "blue"
        case .ghostMode: return "white"
        }
    }
}

// Game State and Settings
class GameSettings: ObservableObject {
    @Published var difficulty: Difficulty = .medium
    @Published var gameMode: GameMode = .classic
    @Published var currentScore: Int = 0
    @Published var highScores: [GameMode: [Difficulty: Int]] = [:]
    
    // Power-up state
    @Published var activePowerUp: PowerUpType?
    @Published var powerUpTimeRemaining: TimeInterval = 0
    @Published var powerUpPosition: Point?
    
    // Time trial mode
    @Published var timeRemaining: TimeInterval = 180 // 3 minutes
    
    // Maze mode
    @Published var obstacles: [Point] = []
    
    // Portal mode
    @Published var portals: [(entrance: Point, exit: Point)] = []
    
    init() {
        loadHighScores()
        setupGameMode()
    }
    
    func setupGameMode() {
        switch gameMode {
        case .classic:
            setupClassicMode()
        case .timeTrialMode:
            setupTimeTrialMode()
        case .mazeMode:
            setupMazeMode()
        case .portalMode:
            setupPortalMode()
        }
    }
    
    private func setupClassicMode() {
        obstacles = []
        portals = []
        powerUpPosition = nil
        activePowerUp = nil
    }
    
    private func setupTimeTrialMode() {
        setupClassicMode()
        timeRemaining = 180
    }
    
    private func setupMazeMode() {
        setupClassicMode()
        generateObstacles()
    }
    
    private func setupPortalMode() {
        setupClassicMode()
        generatePortals()
    }
    
    private func generateObstacles() {
        let boardSize = difficulty.boardSize
        let obstacleCount = boardSize / 2
        
        for _ in 0..<obstacleCount {
            let x = Int.random(in: 2..<boardSize-2)
            let y = Int.random(in: 2..<boardSize-2)
            obstacles.append(Point(x: x, y: y))
        }
    }
    
    private func generatePortals() {
        let boardSize = difficulty.boardSize
        
        // Generate 2 pairs of portals
        for _ in 0..<2 {
            let entrance = Point(
                x: Int.random(in: 1..<boardSize-1),
                y: Int.random(in: 1..<boardSize-1)
            )
            let exit = Point(
                x: Int.random(in: 1..<boardSize-1),
                y: Int.random(in: 1..<boardSize-1)
            )
            portals.append((entrance, exit))
        }
    }
    
    func spawnPowerUp(avoiding: [Point]) {
        guard activePowerUp == nil, let powerUp = PowerUpType.allCases.randomElement() else { return }
        let boardSize = difficulty.boardSize
        
        var newPosition: Point
        repeat {
            newPosition = Point(
                x: Int.random(in: 0..<boardSize),
                y: Int.random(in: 0..<boardSize)
            )
        } while avoiding.contains(newPosition) || obstacles.contains(newPosition)
        
        powerUpPosition = newPosition
    }
    
    func activatePowerUp(_ type: PowerUpType) {
        activePowerUp = type
        powerUpTimeRemaining = type.duration
        powerUpPosition = nil
    }
    
    func updatePowerUpTimer() {
        guard powerUpTimeRemaining > 0 else {
            activePowerUp = nil
            return
        }
        powerUpTimeRemaining -= 1
    }
    
    // High Score Management
    func updateHighScore(score: Int) {
        if highScores[gameMode] == nil {
            highScores[gameMode] = [:]
        }
        
        let currentHigh = highScores[gameMode]?[difficulty] ?? 0
        if score > currentHigh {
            highScores[gameMode]?[difficulty] = score
            saveHighScores()
        }
    }
    
    private func saveHighScores() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: "SnakeHighScores")
        }
    }
    
    private func loadHighScores() {
        if let data = UserDefaults.standard.data(forKey: "SnakeHighScores"),
           let decoded = try? JSONDecoder().decode([GameMode: [Difficulty: Int]].self, from: data) {
            highScores = decoded
        }
    }
} 