//
//  CelebrationView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 18/10/25.
//

import SwiftUI

struct CelebrationView: View {
    let achievement: String
    @State private var isAnimating = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            ConfettiView()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack(spacing: 30) {
                TrophyAnimationView(isAnimating: isAnimating)
                
                Text("🎉 Parabéns! 🎉")
                    .font(.system(size: 32, weight: .bold))
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                Text(achievement)
                    .font(.system(size: 20, weight: .medium))
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                Button {
                    dismiss()
                } label: {
                    Text("Continuar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.0)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
            )
            .padding(.horizontal, 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

// MARK: - Trophy Animation
struct TrophyAnimationView: View {
    let isAnimating: Bool
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.yellow.opacity(0.6),
                            Color.orange.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .blur(radius: 20)
                .scaleEffect(scale)
            
            // Trophy icon
            Image(systemName: "trophy.fill")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .yellow.opacity(0.8), radius: 20)
                .rotationEffect(Angle(degrees: rotation))
                .scaleEffect(scale)
        }
        .frame(width: 150, height: 150)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
            ) {
                rotation = 10
            }
            withAnimation(
                .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.1
            }
        }
    }
}

// MARK: - Native Confetti usando GeometryEffect
struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<60, id: \.self) { index in
                ConfettiPiece()
                    .opacity(animate ? 0 : 1)
                    .modifier(
                        ParticleModifier(
                            time: animate ? 1 : 0,
                            duration: Double.random(in: 1.0...2.0),
                            offsetRange: 300
                        )
                    )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3.0)) {
                animate = true
            }
        }
    }
}

struct ConfettiPiece: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    
    enum ShapeType: CaseIterable {
        case rectangle, circle, roundedRectangle
    }
    
    let randomColor: Color
    let randomShape: ShapeType
    let randomRotation: Double
    
    init() {
        self.randomColor = colors.randomElement() ?? .blue
        self.randomShape = ShapeType.allCases.randomElement() ?? .circle
        self.randomRotation = Double.random(in: 0...360)
    }
    
    var body: some View {
        Group {
            switch randomShape {
            case .rectangle:
                Rectangle()
                    .fill(randomColor)
            case .circle:
                Circle()
                    .fill(randomColor)
            case .roundedRectangle:
                RoundedRectangle(cornerRadius: 4)
                    .fill(randomColor)
            }
        }
        .frame(width: 10, height: 10)
        .rotationEffect(Angle(degrees: randomRotation))
    }
}

struct ParticleModifier: GeometryEffect {
    var time: Double
    var duration: Double
    var offsetRange: CGFloat
    
    private var animatableTime: Double
    private let angle: Double = Double.random(in: -Double.pi...Double.pi)
    private let speed: CGFloat = CGFloat.random(in: 20...200)
    
    init(time: Double, duration: Double, offsetRange: CGFloat) {
        self.time = time
        self.duration = duration
        self.offsetRange = offsetRange
        self.animatableTime = time
    }
    
    var animatableData: Double {
        get { animatableTime }
        set { animatableTime = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(angle) * animatableTime
        let yTranslation = speed * sin(angle) * animatableTime + 0.5 * 200 * pow(animatableTime, 2)
        
        let affineTransform = CGAffineTransform(
            translationX: xTranslation,
            y: yTranslation
        )
        
        return ProjectionTransform(affineTransform)
    }
}

