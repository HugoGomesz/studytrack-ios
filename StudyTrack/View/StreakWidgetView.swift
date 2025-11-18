//
//  StreakWidgetView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 19/10/25.
//

import SwiftUI

struct StreakWidget: View {
    @EnvironmentObject var streakManager: StreakManager
    @State private var showDetails = false
    
    var body: some View {
        let isFrozen = streakManager.isFrozenToday
        let hasProtection = streakManager.freezeProtectionEnabled
        let freezeCount = streakManager.streakFreezes
        
        Button {
            showDetails = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    isFrozen ? Color.cyan.opacity(0.3) : Color.orange.opacity(0.3),
                                    isFrozen ? Color.blue.opacity(0.2) : Color.red.opacity(0.2)
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 40
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Text(isFrozen ? "❄️" : "🔥")
                        .font(.system(size: 40))
                        .scaleEffect(streakManager.currentStreak > 0 ? 1.0 : 0.8)
                    
                    if hasProtection && freezeCount > 0 {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Circle().fill(Color.green))
                            .offset(x: 22, y: -22)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("\(streakManager.currentStreak)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: isFrozen ? [.cyan, .blue] : [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(streakManager.currentStreak == 1 ? "dia" : "dias")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 6) {
                        if isFrozen {
                            HStack(spacing: 4) {
                                Image(systemName: "snowflake")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.cyan)
                                
                                Text("Congelado hoje")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.cyan)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.cyan.opacity(0.15))
                            )
                        } else if hasProtection {
                            HStack(spacing: 4) {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.green)
                                
                                Text("Protegido")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.green)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.15))
                            )
                        }
                        
                        if freezeCount > 0 {
                            HStack(spacing: 4) {
                                Text("❄️")
                                    .font(.system(size: 10))
                                
                                Text("\(freezeCount)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.blue)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.15))
                            )
                        }
                    }
                    
                    if !isFrozen, let nextMilestone = getNextMilestone() {
                        HStack(spacing: 6) {
                            ProgressView(value: Double(streakManager.currentStreak), total: Double(nextMilestone))
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                .frame(height: 4)
                            
                            Text("\(nextMilestone - streakManager.currentStreak) para 🏆")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppColors.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 15, y: 8)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetails) {
            StreakDetailsView()
                .environmentObject(streakManager)
        }
    }
    
    func getNextMilestone() -> Int? {
        streakManager.streakMilestones.first(where: { $0 > streakManager.currentStreak })
    }
}

#Preview {
    StreakWidget()
        .environmentObject(StreakManager())
        .padding()
        .background(AppColors.background)
}
