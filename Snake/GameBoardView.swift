import SwiftUI

struct GameBoardView: View {
    @ObservedObject var gameModel: GameModel
    @State private var foodScale: CGFloat = 1.0
    
    // Custom colors for snake gradient
    private let snakeHeadGradient = LinearGradient(
        colors: [.green, .mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let snakeBodyGradient = LinearGradient(
        colors: [.mint, .green.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / CGFloat(gameModel.boardSize)
            
            ZStack {
                // Background pattern
                backgroundPattern(cellSize: cellSize)
                
                // Grid lines
                gridLines(cellSize: cellSize, boardSize: gameModel.boardSize)
                
                // Snake
                ForEach(0..<gameModel.snake.count, id: \.self) { index in
                    let point = gameModel.snake[index]
                    Group {
                        if index == 0 {
                            // Snake head
                            snakeHead(at: point, size: cellSize)
                        } else {
                            // Snake body
                            snakeBody(at: point, size: cellSize)
                        }
                    }
                    .position(
                        x: CGFloat(point.x) * cellSize + cellSize / 2,
                        y: CGFloat(point.y) * cellSize + cellSize / 2
                    )
                }
                
                // Animated food
                foodView(at: gameModel.food, size: cellSize)
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { gesture in
                        let dx = gesture.translation.width
                        let dy = gesture.translation.height
                        
                        if abs(dx) > abs(dy) {
                            if dx > 0 {
                                gameModel.changeDirection(.right)
                            } else {
                                gameModel.changeDirection(.left)
                            }
                        } else {
                            if dy > 0 {
                                gameModel.changeDirection(.down)
                            } else {
                                gameModel.changeDirection(.up)
                            }
                        }
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    // Background pattern
    private func backgroundPattern(cellSize: CGFloat) -> some View {
        Path { path in
            for row in 0...gameModel.boardSize {
                for col in 0...gameModel.boardSize {
                    let x = CGFloat(col) * cellSize
                    let y = CGFloat(row) * cellSize
                    path.addRect(CGRect(x: x, y: y, width: cellSize/2, height: cellSize/2))
                }
            }
        }
        .fill(Color.mint.opacity(0.05))
    }
    
    // Grid lines
    private func gridLines(cellSize: CGFloat, boardSize: Int) -> some View {
        Path { path in
            // Vertical lines
            for i in 0...boardSize {
                let x = CGFloat(i) * cellSize
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: CGFloat(boardSize) * cellSize))
            }
            // Horizontal lines
            for i in 0...boardSize {
                let y = CGFloat(i) * cellSize
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: CGFloat(boardSize) * cellSize, y: y))
            }
        }
        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
    }
    
    // Snake head with eyes and custom shape
    private func snakeHead(at point: Point, size: CGFloat) -> some View {
        ZStack {
            // Head shape
            RoundedRectangle(cornerRadius: size * 0.3)
                .fill(snakeHeadGradient)
                .frame(width: size * 0.9, height: size * 0.9)
            
            // Eyes
            HStack(spacing: size * 0.2) {
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.2, height: size * 0.2)
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.2, height: size * 0.2)
            }
            .rotationEffect(rotationAngle(for: gameModel.direction))
        }
    }
    
    // Snake body segments
    private func snakeBody(at point: Point, size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: size * 0.3)
            .fill(snakeBodyGradient)
            .frame(width: size * 0.8, height: size * 0.8)
    }
    
    // Animated food view
    private func foodView(at point: Point, size: CGFloat) -> some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(RadialGradient(
                    colors: [.red.opacity(0.3), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.6
                ))
                .frame(width: size * 1.2, height: size * 1.2)
                .scaleEffect(foodScale)
            
            // Food item
            Circle()
                .fill(LinearGradient(
                    colors: [.red, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: size * 0.7, height: size * 0.7)
                .scaleEffect(foodScale)
        }
        .position(
            x: CGFloat(point.x) * size + size / 2,
            y: CGFloat(point.y) * size + size / 2
        )
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever()) {
                foodScale = 1.2
            }
        }
    }
    
    // Helper function to rotate snake head based on direction
    private func rotationAngle(for direction: Direction) -> Angle {
        switch direction {
        case .up: return .degrees(0)
        case .right: return .degrees(90)
        case .down: return .degrees(180)
        case .left: return .degrees(270)
        }
    }
} 