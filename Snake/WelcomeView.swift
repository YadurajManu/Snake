import SwiftUI

struct WelcomeView: View {
    @StateObject private var settings = GameSettings()
    @State private var showGame = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [.black.opacity(0.8), .green.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Title
                    Text("SNAKE")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Game Mode Selection
                    TabView(selection: $selectedTab) {
                        ForEach(GameMode.allCases, id: \.self) { mode in
                            GameModeCard(mode: mode, isSelected: settings.gameMode == mode)
                                .onTapGesture {
                                    settings.gameMode = mode
                                }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 200)
                    
                    // Difficulty Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Select Difficulty")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                DifficultyButton(
                                    difficulty: difficulty,
                                    isSelected: settings.difficulty == difficulty,
                                    action: { settings.difficulty = difficulty }
                                )
                            }
                        }
                    }
                    .padding()
                    
                    // High Scores
                    if let modeScores = settings.highScores[settings.gameMode] {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("High Scores")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                if let score = modeScores[difficulty] {
                                    HStack {
                                        Text(difficulty.rawValue.capitalized)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(score)")
                                            .foregroundColor(.green)
                                            .bold()
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    }
                    
                    // Play Button
                    Button(action: { showGame = true }) {
                        Text("Play Game")
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
                .padding()
            }
            .fullScreenCover(isPresented: $showGame) {
                GameView(settings: settings)
            }
        }
    }
}

struct GameModeCard: View {
    let mode: GameMode
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Mode Icon
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(isSelected ? .green : .white)
            
            // Mode Name
            Text(mode.rawValue.replacingOccurrences(of: "Mode", with: ""))
                .font(.title2.bold())
                .foregroundColor(.white)
            
            // Mode Description
            Text(modeDescription)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(width: 300, height: 180)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
        )
    }
    
    private var iconName: String {
        switch mode {
        case .classic: return "square.grid.4x3.fill"
        case .timeTrialMode: return "timer"
        case .mazeMode: return "map"
        case .portalMode: return "arrow.triangle.2.circlepath"
        }
    }
    
    private var modeDescription: String {
        switch mode {
        case .classic:
            return "Classic snake game with power-ups"
        case .timeTrialMode:
            return "Race against time to get the highest score"
        case .mazeMode:
            return "Navigate through obstacles to collect food"
        case .portalMode:
            return "Use portals to teleport across the board"
        }
    }
}

struct DifficultyButton: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(difficulty.rawValue.capitalized)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .green)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.green : Color.white)
                )
        }
    }
}

#Preview {
    WelcomeView()
} 