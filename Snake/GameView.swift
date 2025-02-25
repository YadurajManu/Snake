import SwiftUI

struct GameView: View {
    @StateObject private var gameModel: GameModel
    @ObservedObject var settings: GameSettings
    @Environment(\.dismiss) var dismiss
    @State private var showPauseMenu = false
    
    init(settings: GameSettings) {
        self.settings = settings
        self._gameModel = StateObject(wrappedValue: GameModel(settings: settings))
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: settings.difficulty == .easy ? Theme.classic.background :
                        settings.difficulty == .medium ? Theme.ocean.background :
                        Theme.neon.background,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { showPauseMenu = true }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Mode indicator
                    Text(settings.gameMode.rawValue.replacingOccurrences(of: "Mode", with: ""))
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    
                    Spacer()
                    
                    // Difficulty indicator
                    Text(settings.difficulty.rawValue.capitalized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                
                // Score and Power-up
                HStack {
                    ScoreView(score: gameModel.score)
                    
                    Spacer()
                    
                    if let powerUp = settings.activePowerUp {
                        PowerUpView(type: powerUp, timeRemaining: settings.powerUpTimeRemaining)
                    }
                }
                .padding(.horizontal)
                
                // Game Board
                GameBoardView(gameModel: gameModel, theme: Theme.classic)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                
                // Controls
                if settings.gameMode == .timeTrialMode {
                    TimerView(timeRemaining: settings.timeRemaining)
                }
                
                // Game controls
                HStack(spacing: 30) {
                    ForEach(Direction.allCases, id: \.self) { direction in
                        DirectionButton(direction: direction) {
                            gameModel.changeDirection(direction)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            gameModel.startGame()
        }
        .sheet(isPresented: $showPauseMenu) {
            PauseMenuView(
                settings: settings,
                onResume: { showPauseMenu = false },
                onRestart: {
                    showPauseMenu = false
                    gameModel.resetGame()
                    gameModel.startGame()
                },
                onExit: { dismiss() }
            )
        }
    }
}

// Score View
struct ScoreView: View {
    let score: Int
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Text("Score: \(score)")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.7), .mint.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .green.opacity(0.3), radius: 5)
            )
            .scaleEffect(scale)
            .onChange(of: score) { _ in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    scale = 1.2
                }
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5).delay(0.1)) {
                    scale = 1
                }
            }
    }
}

struct PowerUpView: View {
    let type: PowerUpType
    let timeRemaining: TimeInterval
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: iconName)
                .foregroundColor(Color(type.color))
            
            Text(String(format: "%.1f", timeRemaining))
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
    
    private var iconName: String {
        switch type {
        case .speedBoost: return "bolt.fill"
        case .scoreMultiplier: return "star.fill"
        case .shield: return "shield.fill"
        case .ghostMode: return "ghost.fill"
        }
    }
}

struct TimerView: View {
    let timeRemaining: TimeInterval
    
    var body: some View {
        Text(String(format: "Time: %.1f", timeRemaining))
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
    }
}

struct DirectionButton: View {
    let direction: Direction
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
        }
    }
    
    private var iconName: String {
        switch direction {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }
}

struct PauseMenuView: View {
    let settings: GameSettings
    let onResume: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Paused")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    MenuButton(title: "Resume", action: onResume)
                    MenuButton(title: "Restart", action: onRestart)
                    MenuButton(title: "Exit", action: onExit)
                }
            }
            .padding()
        }
    }
}

struct MenuButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .padding(.horizontal, 40)
    }
}

extension Direction: CaseIterable {
    static var allCases: [Direction] = [.up, .left, .down, .right]
} 