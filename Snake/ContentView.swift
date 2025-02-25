//
//  ContentView.swift
//  Snake
//
//  Created by Yaduraj Singh on 25/02/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameModel = GameModel()
    @State private var gameTimer: Timer?
    @State private var isPaused = true
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.black.opacity(0.8), .mint.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text("SNAKE")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Score with animation
                ScoreView(score: gameModel.score)
                
                // Game Board
                GameBoardView(gameModel: gameModel)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                
                // Controls
                HStack(spacing: 30) {
                    // Play/Pause Button
                    Button(action: {
                        if isPaused {
                            startGame()
                        } else {
                            pauseGame()
                        }
                    }) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .mint],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .green.opacity(0.5), radius: 5)
                            )
                    }
                    
                    // Restart Button
                    Button(action: {
                        gameModel.restart()
                        startGame()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .mint],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .blue.opacity(0.5), radius: 5)
                            )
                    }
                }
            }
            .padding()
        }
        .alert("Game Over!", isPresented: .constant(gameModel.isGameOver)) {
            Button("Restart", action: {
                gameModel.restart()
                startGame()
            })
        } message: {
            Text("Final Score: \(gameModel.score)")
        }
    }
    
    private func startGame() {
        isPaused = false
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            gameModel.move()
        }
    }
    
    private func pauseGame() {
        isPaused = true
        gameTimer?.invalidate()
        gameTimer = nil
    }
}

// Animated Score View
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

#Preview {
    ContentView()
}
