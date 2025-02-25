import Foundation

struct Point: Equatable {
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
    
    let boardSize: Int
    
    init(boardSize: Int = 15) {
        self.boardSize = boardSize
        self.food = Point(x: Int.random(in: 0..<boardSize), y: Int.random(in: 0..<boardSize))
        // Start with a snake of length 3
        let center = boardSize / 2
        snake = [
            Point(x: center, y: center),
            Point(x: center - 1, y: center),
            Point(x: center - 2, y: center)
        ]
    }
    
    func move() {
        guard !isGameOver else { return }
        
        var newHead = snake[0]
        
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
            isGameOver = true
            return
        }
        
        snake.insert(newHead, at: 0)
        
        // Check if snake ate food
        if newHead.x == food.x && newHead.y == food.y {
            score += 1
            generateNewFood()
        } else {
            snake.removeLast()
        }
    }
    
    private func hasCollision(at point: Point) -> Bool {
        // Check wall collision
        if point.x < 0 || point.x >= boardSize || point.y < 0 || point.y >= boardSize {
            return true
        }
        
        // Check self collision
        return snake.contains(point)
    }
    
    private func generateNewFood() {
        var newFood: Point
        repeat {
            newFood = Point(x: Int.random(in: 0..<boardSize), y: Int.random(in: 0..<boardSize))
        } while snake.contains(newFood)
        food = newFood
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
    
    func restart() {
        let center = boardSize / 2
        snake = [
            Point(x: center, y: center),
            Point(x: center - 1, y: center),
            Point(x: center - 2, y: center)
        ]
        direction = .right
        isGameOver = false
        score = 0
        generateNewFood()
    }
} 