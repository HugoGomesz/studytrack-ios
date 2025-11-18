//
//  LevelProgressView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 18/10/25.
//

import SwiftUI

struct LevelProgressView: View {
    @ObservedObject var levelSystem: LevelSystem
    
    var progress: Double {
        Double(levelSystem.currentXP) / Double(levelSystem.xpNeededForNextLevel())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Level badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                    
                    Text("\(levelSystem.currentLevel)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nível \(levelSystem.currentLevel)")
                        .font(.system(size: 18, weight: .bold))
                    
                    Text(levelSystem.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // XP count
                Text("\(levelSystem.currentXP)/\(levelSystem.xpNeededForNextLevel()) XP")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.purple)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.15))
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 12)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)
                    
                    // Glow effect
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.6), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 12)
                        .blur(radius: 8)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}
