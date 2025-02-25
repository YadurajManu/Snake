import SwiftUI

struct Theme {
    let name: String
    let primary: Color
    let secondary: Color
    let background: [Color]
    let food: [Color]
    let snake: [Color]
    
    static let themes: [Theme] = [
        .classic,
        .ocean,
        .sunset,
        .neon,
        .forest
    ]
    
    static let classic = Theme(
        name: "Classic",
        primary: .green,
        secondary: .mint,
        background: [.black.opacity(0.8), .mint.opacity(0.2)],
        food: [.red, .orange],
        snake: [.green, .mint]
    )
    
    static let ocean = Theme(
        name: "Ocean",
        primary: .blue,
        secondary: .cyan,
        background: [.blue.opacity(0.8), .cyan.opacity(0.2)],
        food: [.yellow, .orange],
        snake: [.blue, .cyan]
    )
    
    static let sunset = Theme(
        name: "Sunset",
        primary: .orange,
        secondary: .pink,
        background: [.purple.opacity(0.8), .pink.opacity(0.2)],
        food: [.yellow, .white],
        snake: [.orange, .pink]
    )
    
    static let neon = Theme(
        name: "Neon",
        primary: .purple,
        secondary: .pink,
        background: [.black.opacity(0.9), .purple.opacity(0.2)],
        food: [.yellow, .green],
        snake: [.purple, .pink]
    )
    
    static let forest = Theme(
        name: "Forest",
        primary: .green,
        secondary: .brown,
        background: [.brown.opacity(0.8), .green.opacity(0.2)],
        food: [.red, .orange],
        snake: [.green, .brown]
    )
}

// Particle System
struct ParticleSystem: View {
    let theme: Theme
    @State private var particles: [Particle] = []
    let position: CGPoint
    let onComplete: () -> Void
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var scale: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.position.x - 5,
                        y: particle.position.y - 5,
                        width: 10,
                        height: 10
                    )
                    
                    context.opacity = particle.opacity
                    context.fill(
                        Circle().path(in: rect),
                        with: .linearGradient(
                            Gradient(colors: [theme.primary, theme.secondary]),
                            startPoint: CGPoint(x: rect.midX, y: rect.minY),
                            endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                        )
                    )
                }
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        for _ in 0..<20 {
            let angle = Double.random(in: 0...2 * .pi)
            let speed = Double.random(in: 50...200)
            let particle = Particle(
                position: position,
                velocity: CGPoint(
                    x: cos(angle) * speed,
                    y: sin(angle) * speed
                ),
                scale: CGFloat.random(in: 0.2...1),
                opacity: 1
            )
            particles.append(particle)
        }
        
        withAnimation(.easeOut(duration: 1)) {
            for i in particles.indices {
                particles[i].position.x += particles[i].velocity.x
                particles[i].position.y += particles[i].velocity.y
                particles[i].opacity = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            particles = []
            onComplete()
        }
    }
} 