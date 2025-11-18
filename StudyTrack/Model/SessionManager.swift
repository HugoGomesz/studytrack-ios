//
//  SessionManager.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 19/10/25.
//

// SessionManager.swift
import SwiftUI
import Combine

class SessionManager: ObservableObject {
    @Published var totalStudyTimeToday: TimeInterval = 0
    @Published var dailyGoalHours: Double = 5.0
    @Published var sessions: [StudySession] = []
    
    var dailyGoalSeconds: TimeInterval {
        dailyGoalHours * 3600
    }
    
    var progressPercentage: Double {
        guard dailyGoalSeconds > 0 else { return 0 }
        return min(totalStudyTimeToday / dailyGoalSeconds, 1.0)
    }
    
    var hoursStudiedToday: Double {
        totalStudyTimeToday / 3600
    }
    
    init() {
        loadTodaysSessions()
    }
    
    func addStudyTime(minutes: Int) {
        totalStudyTimeToday += TimeInterval(minutes * 60)
        saveSessions()
    }
    
    func addSession(duration: Int, type: String) {
        let session = StudySession(
            id: UUID(),
            duration: TimeInterval(duration * 60),
            type: type,
            date: Date()
        )
        
        sessions.append(session)
        totalStudyTimeToday += TimeInterval(duration * 60)
        
        saveSessions()
        
        print("✅ Sessão adicionada: \(duration) min de \(type)")
    }
    
    func resetDaily() {
        totalStudyTimeToday = 0
        sessions = []
        saveSessions()
    }
    
    private func saveSessions() {
        UserDefaults.standard.set(totalStudyTimeToday, forKey: "total_study_time_today")
        UserDefaults.standard.set(dailyGoalHours, forKey: "daily_goal_hours")
        UserDefaults.standard.set(Date(), forKey: "last_session_date")
        
        // Salva as sessões 
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "study_sessions")
        }
    }
    
    private func loadTodaysSessions() {
        totalStudyTimeToday = UserDefaults.standard.double(forKey: "total_study_time_today")
        dailyGoalHours = UserDefaults.standard.double(forKey: "daily_goal_hours")
        
        if dailyGoalHours == 0 {
            dailyGoalHours = 5.0
        }
        
        // Carrega sessões salvas
        if let data = UserDefaults.standard.data(forKey: "study_sessions"),
           let decoded = try? JSONDecoder().decode([StudySession].self, from: data) {
            sessions = decoded
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        if let lastDate = UserDefaults.standard.object(forKey: "last_session_date") as? Date,
           !Calendar.current.isDate(lastDate, inSameDayAs: today) {
            totalStudyTimeToday = 0
            sessions = []
        }
    }
}

struct StudySession: Identifiable, Codable {
    let id: UUID
    let duration: TimeInterval
    let type: String
    let date: Date
}

