//
//  LevelSystem.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 18/10/25.
//

import SwiftUI

class LevelSystem: ObservableObject {
    @Published var currentLevel: Int = 26
    @Published var currentXP: Int = 2500
    @Published var title: String = "Expert"
    
    private let xpKey = "currentXP"
    private let levelKey = "currentLevel"
    
    init() {
        loadProgress()
    }
    
    func xpNeededForNextLevel() -> Int {
        return currentLevel * 100 + (currentLevel - 1) * 50
    }
    
    func addExperience(points: Int) {
        addXP(amount: points, reason: "Sessão completada")
    }
    
    func addXP(amount: Int, reason: String) {
        currentXP += amount
        
        while currentXP >= xpNeededForNextLevel() {
            levelUp()
        }
        
        saveProgress()
        
        showXPNotification(amount: amount, reason: reason)
        
        print("⭐ +\(amount) XP (\(reason)) - Total: \(currentXP)/\(xpNeededForNextLevel())")
    }
    
    func levelUp() {
        currentXP -= xpNeededForNextLevel()
        currentLevel += 1
        updateTitle()
        
        saveProgress()
        
        triggerLevelUpAnimation()
        
        NotificationManager.instance.sendCelebrationNotification(
            message: "Level Up! Você alcançou o nível \(currentLevel) - \(title)! 🎉"
        )
        
        print("🎉 LEVEL UP! Nível \(currentLevel) - \(title)")
    }
    
    func updateTitle() {
        switch currentLevel {
        case 1...5:
            title = "Iniciante"
        case 6...10:
            title = "Estudante"
        case 11...20:
            title = "Dedicado"
        case 21...30:
            title = "Expert"
        case 31...50:
            title = "Mestre"
        case 51...100:
            title = "Sábio"
        default:
            title = "Lenda"
        }
    }
    
    func calculateXP(for activity: StudyActivity) -> Int {
        switch activity {
        case .completedSession(let minutes):
            return minutes * 2
        case .completedTask:
            return 50
        case .achievedDailyGoal:
            return 100
        case .maintainedStreak(let days):
            return days * 10
        case .perfectWeek:
            return 500
        case .completedChallenge:
            return 200
        }
    }
    
    func showXPNotification(amount: Int, reason: String) {
    }
    
    func triggerLevelUpAnimation() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func saveProgress() {
        UserDefaults.standard.set(currentXP, forKey: xpKey)
        UserDefaults.standard.set(currentLevel, forKey: levelKey)
    }
    
    private func loadProgress() {
        let savedXP = UserDefaults.standard.integer(forKey: xpKey)
        let savedLevel = UserDefaults.standard.integer(forKey: levelKey)
        
        if savedXP > 0 {
            currentXP = savedXP
        }
        if savedLevel > 0 {
            currentLevel = savedLevel
        }
        
        updateTitle()
    }
}

enum StudyActivity {
    case completedSession(minutes: Int)
    case completedTask
    case achievedDailyGoal
    case maintainedStreak(days: Int)
    case perfectWeek
    case completedChallenge
}
