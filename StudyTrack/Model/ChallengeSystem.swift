//
//  ChallengeSystem.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 18/10/25.
//

import SwiftUI

struct Challenge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let goal: Int
    var progress: Int
    let reward: ChallengeReward
    let difficulty: ChallengeDifficulty
    let expiresAt: Date
    var isCompleted: Bool {
        progress >= goal
    }
}

enum ChallengeReward {
    case xp(Int)
    case streakFreeze
    case badge(String)
    case theme(String)
}

enum ChallengeDifficulty {
    case easy, medium, hard
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

class ChallengeManager: ObservableObject {
    @Published var dailyChallenges: [Challenge] = []
    @Published var weeklyChallenges: [Challenge] = []
    
    init() {
        generateDailyChallenges()
        generateWeeklyChallenges()
    }
    
    func generateDailyChallenges() {
        let endOfDay = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        
        dailyChallenges = [
            Challenge(
                title: "Primeira Sessão do Dia",
                description: "Complete 1 sessão de foco",
                goal: 1,
                progress: 0,
                reward: .xp(50),
                difficulty: .easy,
                expiresAt: endOfDay
            ),
            Challenge(
                title: "Maratonista",
                description: "Estude por 2 horas hoje",
                goal: 120,
                progress: 0,
                reward: .xp(200),
                difficulty: .medium,
                expiresAt: endOfDay
            ),
            Challenge(
                title: "Produtivo",
                description: "Complete 5 tarefas",
                goal: 5,
                progress: 0,
                reward: .xp(150),
                difficulty: .medium,
                expiresAt: endOfDay
            )
        ]
    }
    
    func generateWeeklyChallenges() {
        let endOfWeek = Date().addingTimeInterval(7 * 86400)
        
        weeklyChallenges = [
            Challenge(
                title: "Semana Perfeita",
                description: "Estude todos os 7 dias da semana",
                goal: 7,
                progress: 0,
                reward: .streakFreeze,
                difficulty: .hard,
                expiresAt: endOfWeek
            ),
            Challenge(
                title: "Dedicação Total",
                description: "Acumule 15 horas de estudo",
                goal: 900,
                progress: 0,
                reward: .badge("Dedicação Total"),
                difficulty: .hard,
                expiresAt: endOfWeek
            ),
            Challenge(
                title: "Organizador",
                description: "Complete 20 tarefas",
                goal: 20,
                progress: 0,
                reward: .xp(500),
                difficulty: .medium,
                expiresAt: endOfWeek
            )
        ]
    }
    
    func updateChallengeProgress(type: ChallengeType, amount: Int) {
        switch type {
        case .studyMinutes:
            updateChallenges(matching: "minutos", by: amount)
        case .tasksCompleted:
            updateChallenges(matching: "tarefas", by: amount)
        case .sessionsCompleted:
            updateChallenges(matching: "sessão", by: amount)
        case .daysStudied:
            updateChallenges(matching: "dias", by: amount)
        }
    }
    
    private func updateChallenges(matching keyword: String, by amount: Int) {
        for index in dailyChallenges.indices {
            if dailyChallenges[index].description.lowercased().contains(keyword) {
                dailyChallenges[index].progress += amount
                if dailyChallenges[index].isCompleted {
                    claimReward(dailyChallenges[index].reward)
                }
            }
        }
        
        for index in weeklyChallenges.indices {
            if weeklyChallenges[index].description.lowercased().contains(keyword) {
                weeklyChallenges[index].progress += amount
                if weeklyChallenges[index].isCompleted {
                    claimReward(weeklyChallenges[index].reward)
                }
            }
        }
    }
    
    func claimReward(_ reward: ChallengeReward) {
        showRewardAnimation(reward)
    }
    
    func showRewardAnimation(_ reward: ChallengeReward) {
    }
}

enum ChallengeType {
    case studyMinutes
    case tasksCompleted
    case sessionsCompleted
    case daysStudied
}

