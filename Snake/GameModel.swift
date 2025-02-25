import Foundation

struct Point: Equatable, Codable {
    var x: Int
    var y: Int
}

enum Direction {
    case up, down, left, right
}

class GameModel: ObservableObject {
    @Published var snake: [Point] = []
    @Published var food: Point
    @Published var direction: Direction = .right
    @Published var isGameOver = false
    @Published var score = 0
    
    let settings: GameSettings
    private var powerUpTimer: Timer?
    private var gameTimer: Timer?
    
    init(settings: GameSettings) {
        self.settings = settings
        self.food = Point(x: 0, y: 0)
        resetGame()
    }
    
    func resetGame() {
        // Reset game state
        let center = settings.difficulty.boardSize / 2
        snake = [
            Point(x: center, y: center),
            Point(x: center - 1, y: center),
            Point(x: center - 2, y: center)
        ]
        direction = .right
        isGameOver = false
        score = 0
        
        // Generate initial food position
        generateNewFood()
        
        // Setup game mode
        settings.setupGameMode()
        
        // Start power-up spawning timer
        powerUpTimer?.invalidate()
        powerUpTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.trySpawnPowerUp()
        }
    }
    
    func move() {
        guard !isGameOver else { return }
        
        var newHead = snake[0]
        
        // Handle portal teleportation
        if settings.gameMode == .portalMode {
            if let portalIndex = settings.portals.firstIndex(where: { $0.entrance.x == newHead.x && $0.entrance.y == newHead.y }) {
                let exit = settings.portals[portalIndex].exit
                newHead = exit
            }
        }
        
        // Normal movement
        switch direction {
        case .up:
            newHead.y -= 1
        case .down:
            newHead.y += 1
        case .left:
            newHead.x -= 1
        case .right:
            newHead.x += 1
        }
        
        // Check for collisions
        if hasCollision(at: newHead) {
            if settings.activePowerUp == .ghostMode {
                // Wrap around in ghost mode
                newHead = wrapPosition(newHead)
            } else if settings.activePowerUp == .shield {
                // Ignore collision with shield
            } else {
                isGameOver = true
                settings.updateHighScore(score: score)
                return
            }
        }
        
        snake.insert(newHead, at: 0)
        
        // Check if snake ate food
        if newHead.x == food.x && newHead.y == food.y {
            let basePoints = 10
            let multiplier = settings.difficulty.scoreMultiplier
            let powerUpMultiplier = settings.activePowerUp == .scoreMultiplier ? 2.0 : 1.0
            score += Int(Double(basePoints) * multiplier * powerUpMultiplier)
            generateNewFood()
            
            // Randomly spawn power-up after eating
            if Int.random(in: 0...4) == 0 {
                trySpawnPowerUp()
            }
        } else {
            snake.removeLast()
        }
        
        // Check for power-up collection
        if let powerUpPos = settings.powerUpPosition,
           newHead.x == powerUpPos.x && newHead.y == powerUpPos.y,
           let powerUp = PowerUpType.allCases.randomElement() {
            settings.activatePowerUp(powerUp)
            
            // Apply power-up effects
            switch powerUp {
            case .speedBoost:
                gameTimer?.invalidate()
                let boostedSpeed = settings.difficulty.speed * 0.5
                gameTimer = Timer.scheduledTimer(withTimeInterval: boostedSpeed, repeats: true) { [weak self] _ in
                    self?.move()
                }
            case .scoreMultiplier:
                // Handled in score calculation
                break
            case .shield, .ghostMode:
                // Handled in collision detection
                break
            }
        }
    }
    
    private func hasCollision(at point: Point) -> Bool {
        let boardSize = settings.difficulty.boardSize
        
        // Check wall collision (except in ghost mode)
        if point.x < 0 || point.x >= boardSize || point.y < 0 || point.y >= boardSize {
            return true
        }
        
        // Check obstacle collision (in maze mode)
        if settings.gameMode == .mazeMode && settings.obstacles.contains(point) {
            return true
        }
        
        // Check self collision
        return snake.contains(point)
    }
    
    private func wrapPosition(_ point: Point) -> Point {
        let boardSize = settings.difficulty.boardSize
        var wrapped = point
        
        if wrapped.x < 0 {
            wrapped.x = boardSize - 1
        } else if wrapped.x >= boardSize {
            wrapped.x = 0
        }
        
        if wrapped.y < 0 {
            wrapped.y = boardSize - 1
        } else if wrapped.y >= boardSize {
            wrapped.y = 0
        }
        
        return wrapped
    }
    
    private func generateNewFood() {
        let boardSize = settings.difficulty.boardSize
        var newFood: Point
        repeat {
            newFood = Point(
                x: Int.random(in: 0..<boardSize),
                y: Int.random(in: 0..<boardSize)
            )
        } while snake.contains(newFood) || settings.obstacles.contains(newFood)
        food = newFood
    }
    
    private func trySpawnPowerUp() {
        settings.spawnPowerUp(avoiding: snake + [food])
    }
    
    func changeDirection(_ newDirection: Direction) {
        // Prevent 180-degree turns
        switch (direction, newDirection) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            return
        default:
            direction = newDirection
        }
    }
    
    func startGame() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: settings.difficulty.speed, repeats: true) { [weak self] _ in
            self?.move()
        }
    }
    
    func pauseGame() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    deinit {
        gameTimer?.invalidate()
        powerUpTimer?.invalidate()
    }
} 