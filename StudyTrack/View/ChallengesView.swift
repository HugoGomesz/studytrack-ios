//
//  ChallengeView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 18/10/25.
//

import SwiftUI
// ChallengesView.swift
struct ChallengesView: View {
    @StateObject private var challengeManager = ChallengeManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        
                        Text("Desafios Diários")
                            .font(AppTypography.title2)
                        
                        Spacer()
                        
                        Text("Renovam em \(timeUntilMidnight())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    ForEach(challengeManager.dailyChallenges) { challenge in
                        ChallengeCard(challenge: challenge)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundStyle(.purple)
                        
                        Text("Desafios Semanais")
                            .font(AppTypography.title2)
                        
                        Spacer()
                        
                        Text("Renovam em \(daysUntilSunday()) dias")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    ForEach(challengeManager.weeklyChallenges) { challenge in
                        ChallengeCard(challenge: challenge)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Desafios")
    }
    
    func timeUntilMidnight() -> String {
        let now = Date()
        let midnight = Calendar.current.startOfDay(for: now.addingTimeInterval(86400))
        let diff = Calendar.current.dateComponents([.hour, .minute], from: now, to: midnight)
        return "\(diff.hour ?? 0)h \(diff.minute ?? 0)m"
    }
    
    func daysUntilSunday() -> Int {
        let now = Date()
        let weekday = Calendar.current.component(.weekday, from: now)
        return weekday == 1 ? 7 : 8 - weekday
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    
    var progress: Double {
        Double(challenge.progress) / Double(challenge.goal)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(challenge.difficulty.color)
                    .frame(width: 8, height: 8)
                
                Text(challenge.title)
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }
            
            Text(challenge.description)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(challenge.difficulty.color.opacity(0.15))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [challenge.difficulty.color.opacity(0.8), challenge.difficulty.color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(challenge.progress)/\(challenge.goal)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                rewardView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(challenge.isCompleted ? challenge.difficulty.color.opacity(0.1) : AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            challenge.isCompleted ? challenge.difficulty.color.opacity(0.5) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
    }
    
    @ViewBuilder
    var rewardView: some View {
        HStack(spacing: 4) {
            switch challenge.reward {
            case .xp(let amount):
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.yellow)
                Text("+\(amount) XP")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.purple)
            case .streakFreeze:
                Image(systemName: "snowflake")
                    .font(.system(size: 10))
                    .foregroundStyle(.blue)
                Text("Congelar Streak")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.blue)
            case .badge(let name):
                Image(systemName: "rosette")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.orange)
            case .theme(let name):
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.pink)
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.pink)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.yellow.opacity(0.1))
        )
    }
}

