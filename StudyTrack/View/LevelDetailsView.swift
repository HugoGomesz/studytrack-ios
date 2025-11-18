//
//  LevelDetailsView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 18/10/25.
//

import SwiftUI

struct LevelDetailsView: View {
    @EnvironmentObject var levelSystem: LevelSystem
    @Environment(\.dismiss) var dismiss
    
    var progressPercentage: Double {
        Double(levelSystem.currentXP) / Double(levelSystem.xpNeededForNextLevel())
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
    
                levelHeader
                
                levelProgress
                
                xpBreakdown
                
                levelRewards
            }
            .padding()
            .padding(.bottom, 100)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Progressão")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Level Header
    private var levelHeader: some View {
        VStack(spacing: 20) {
            // Level badge grande
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(0.3),
                                Color.blue.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 30)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: .purple.opacity(0.5), radius: 25, y: 10)
                
                Text("\(levelSystem.currentLevel)")
                    .font(.system(size: 70, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 8) {
                Text("Nível \(levelSystem.currentLevel)")
                    .font(.system(size: 32, weight: .bold))
                
                Text(levelSystem.title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.purple.opacity(0.1))
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 20, y: 10)
        )
    }
    
    // MARK: - Level Progress
    private var levelProgress: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Progresso para Nível \(levelSystem.currentLevel + 1)")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Text("\(levelSystem.currentXP)/\(levelSystem.xpNeededForNextLevel()) XP")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.purple)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.purple.opacity(0.15))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressPercentage, height: 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .animation(.spring(response: 1.0, dampingFraction: 0.7), value: progressPercentage)
                }
            }
            .frame(height: 20)
            
            Text("Você precisa de \(levelSystem.xpNeededForNextLevel() - levelSystem.currentXP) XP para subir de nível")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    // MARK: - XP Breakdown
    private var xpBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Como Ganhar XP")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 12) {
                XPActivityRow(
                    icon: "timer",
                    activity: "Sessão de estudo",
                    xp: "+2 XP/min",
                    color: AppColors.accent
                )
                
                XPActivityRow(
                    icon: "checkmark.circle.fill",
                    activity: "Completar tarefa",
                    xp: "+50 XP",
                    color: .green
                )
                
                XPActivityRow(
                    icon: "target",
                    activity: "Atingir meta diária",
                    xp: "+100 XP",
                    color: AppColors.secondary
                )
                
                XPActivityRow(
                    icon: "flame.fill",
                    activity: "Manter streak",
                    xp: "+10 XP/dia",
                    color: .orange
                )
                
                XPActivityRow(
                    icon: "star.fill",
                    activity: "Semana perfeita",
                    xp: "+500 XP",
                    color: .yellow
                )
                
                XPActivityRow(
                    icon: "trophy.fill",
                    activity: "Completar desafio",
                    xp: "+200 XP",
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    // MARK: - Level Rewards
    private var levelRewards: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Próximas Recompensas")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 12) {
                RewardCard(
                    level: levelSystem.currentLevel + 1,
                    reward: "Novo tema desbloqueado",
                    icon: "paintbrush.fill",
                    isUnlocked: false
                )
                
                RewardCard(
                    level: levelSystem.currentLevel + 5,
                    reward: "Badge especial",
                    icon: "rosette",
                    isUnlocked: false
                )
                
                RewardCard(
                    level: levelSystem.currentLevel + 10,
                    reward: "Congelamento de streak grátis",
                    icon: "snowflake",
                    isUnlocked: false
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
}

// MARK: - Supporting Views
struct XPActivityRow: View {
    let icon: String
    let activity: String
    let xp: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity)
                    .font(.system(size: 15, weight: .medium))
                
                Text(xp)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.05))
        )
    }
}

struct RewardCard: View {
    let level: Int
    let reward: String
    let icon: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isUnlocked ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Nível \(level)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text(reward)
                    .font(.system(size: 15, weight: .medium))
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.gray)
                    .font(.title3)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isUnlocked ? Color.green.opacity(0.05) : AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(isUnlocked ? Color.green.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
