//
//  StreakManager.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 18/10/25.
//

import SwiftUI
import Combine

class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastStudyDate: Date?
    @Published var streakFreezes: Int = 3
    @Published var freezeProtectionEnabled: Bool = false
    @Published var lastFreezeDate: Date?
    @Published var showFreezeUsedAlert: Bool = false
    
    let streakMilestones = [3, 7, 14, 30, 50, 100, 365]
    
    private let defaults = UserDefaults.standard
    
    var isFrozenToday: Bool {
        guard let lastFreezeDate = lastFreezeDate else { return false }
        return Calendar.current.isDateInToday(lastFreezeDate)
    }
    
    init() {
        loadStreak()
    }
    
    // MARK: - Load & Save
    
    private func loadStreak() {
        currentStreak = defaults.integer(forKey: "current_streak")
        longestStreak = defaults.integer(forKey: "longest_streak")
        streakFreezes = defaults.integer(forKey: "streak_freezes")
        freezeProtectionEnabled = defaults.bool(forKey: "freeze_protection")
        lastStudyDate = defaults.object(forKey: "last_study_date") as? Date
        lastFreezeDate = defaults.object(forKey: "last_freeze_date") as? Date
        
        if streakFreezes == 0 && currentStreak == 0 {
            streakFreezes = 3
        }
    }
    
    func saveStreak() {
        defaults.set(currentStreak, forKey: "current_streak")
        defaults.set(longestStreak, forKey: "longest_streak")
        defaults.set(streakFreezes, forKey: "streak_freezes")
        defaults.set(freezeProtectionEnabled, forKey: "freeze_protection")
        
        if let lastStudyDate = lastStudyDate {
            defaults.set(lastStudyDate, forKey: "last_study_date")
        }
        
        if let lastFreezeDate = lastFreezeDate {
            defaults.set(lastFreezeDate, forKey: "last_freeze_date")
        }
    }
    
    // MARK: - Streak Logic
    
    func incrementStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastDate = lastStudyDate else {
            currentStreak = 1
            lastStudyDate = today
            
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
            
            saveStreak()
            return
        }
        
        let lastStudyDay = calendar.startOfDay(for: lastDate)
        
        if calendar.isDate(lastStudyDay, inSameDayAs: today) {
            return
        }
        
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(lastStudyDay, inSameDayAs: yesterday) {
            currentStreak += 1
            lastStudyDate = today
            
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            if freezeProtectionEnabled && streakFreezes > 0 {
                useFreeze()
                lastStudyDate = today
                showFreezeUsedAlert = true 
            } else {
                currentStreak = 1
                lastStudyDate = today
            }
        }
        
        saveStreak()
    }
    
    func checkStreakStatus() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastDate = lastStudyDate else { return }
        
        let lastStudyDay = calendar.startOfDay(for: lastDate)
        let daysSinceLastStudy = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
        
        if daysSinceLastStudy > 1 {
            if freezeProtectionEnabled && streakFreezes > 0 {
                useFreeze()
                lastStudyDate = calendar.date(byAdding: .day, value: -1, to: today)
                showFreezeUsedAlert = true
            } else {
                currentStreak = 0
            }
            saveStreak()
        }
    }
    
    // MARK: - Force/Seed Streak (Demo)
    
    func setStreak(to days: Int) {
        let clamped = max(0, days)
        currentStreak = clamped
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
 
        lastStudyDate = Calendar.current.startOfDay(for: Date())
        saveStreak()
        print("🔧 Streak definido manualmente para \(currentStreak) dia(s).")
    }
    
    // MARK: - Freeze Management
    
    func useFreeze() {
        guard streakFreezes > 0 else { return }
        streakFreezes -= 1
        lastFreezeDate = Date()
        saveStreak()
        print("❄️ Freeze usado! Restantes: \(streakFreezes)")
    }
    
    func addFreeze(count: Int = 1) {
        streakFreezes += count
        saveStreak()
        print("❄️ \(count) freeze(s) adicionado(s)! Total: \(streakFreezes)")
    }
    
    func toggleProtection() {
        freezeProtectionEnabled.toggle()
        saveStreak()
        print("🛡️ Proteção automática: \(freezeProtectionEnabled ? "ATIVADA" : "DESATIVADA")")
    }
    
    // MARK: - Reset
    
    func resetStreak() {
        currentStreak = 0
        lastStudyDate = nil
        saveStreak()
    }
    
    func resetAll() {
        currentStreak = 0
        longestStreak = 0
        lastStudyDate = nil
        streakFreezes = 3
        freezeProtectionEnabled = false
        lastFreezeDate = nil
        saveStreak()
    }
    
    func buyFreeze(quantity: Int) {
        streakFreezes += quantity
        saveStreak()
        print("❄️ Comprou \(quantity) freeze(s)! Total: \(streakFreezes)")
    }
}

