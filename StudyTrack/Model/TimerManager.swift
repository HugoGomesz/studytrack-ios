//
//  TimerManager.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 19/10/25.
//

import SwiftUI
import Combine
import AVFoundation

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var selectedSession: SessionType = .pomodoro
    @Published var customMinutes: Int = 30
    @Published var customBreakMinutes: Int = 5
    @Published var sessionsCompleted: Int = 0
    @Published var isBreakTime = false
    @Published var cycleCount = 0
    @Published var autoStartBreaks = true
    @Published var autoStartPomodoros = false
    
    private var timer: Timer?
    private var originalTime: TimeInterval = 25 * 60
    private var backgroundDate: Date?
    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?
    
    var progress: Double {
        guard originalTime > 0 else { return 0 }
        return 1.0 - (timeRemaining / originalTime)
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var canReset: Bool {
        isRunning || isPaused || timeRemaining < originalTime
    }
    
    var actualMinutesStudied: Int {
        return Int(originalTime / 60)
    }
    
    var breakMinutes: Int {
        if selectedSession == .custom {
            return customBreakMinutes
        }
        if selectedSession == .pomodoro && cycleCount % 4 == 0 {
            return 15
        }
        return selectedSession.breakDuration
    }

    init() {
        setupNotificationListener()
        setupBackgroundHandlers()
        loadSettings()
    }
    
    private func loadSettings() {
        if UserDefaults.standard.object(forKey: "autoStartBreaks") != nil {
            autoStartBreaks = UserDefaults.standard.bool(forKey: "autoStartBreaks")
        }
        if UserDefaults.standard.object(forKey: "autoStartPomodoros") != nil {
            autoStartPomodoros = UserDefaults.standard.bool(forKey: "autoStartPomodoros")
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(autoStartBreaks, forKey: "autoStartBreaks")
        UserDefaults.standard.set(autoStartPomodoros, forKey: "autoStartPomodoros")
    }
    
    private func saveStudySession(minutes: Int) {
        let session = StudySession(
            id: UUID(),
            duration: TimeInterval(minutes * 60),
            type: selectedSession.rawValue,
            date: Date()
        )
        
        var history: [StudySession] = []
        
        // Carrega histórico existente
        if let data = UserDefaults.standard.data(forKey: "study_sessions"),
           let decoded = try? JSONDecoder().decode([StudySession].self, from: data) {
            history = decoded
        }
        
        // Adiciona nova sessão
        history.append(session)
        
        // Salva de volta
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "study_sessions")
        }
        
        // Notifica o dashboard para atualizar
        NotificationCenter.default.post(name: NSNotification.Name("ReloadDashboard"), object: nil)
        
        print("✅ Sessão salva: \(minutes) min de \(selectedSession.rawValue)")
    }
    
    enum SessionType: String, CaseIterable {
        case pomodoro = "Pomodoro"
        case deepWork = "Deep Work"
        case shortFocus = "Foco Rápido"
        case custom = "Personalizado"
        
        var duration: Int {
            switch self {
            case .pomodoro: return 25
            case .deepWork: return 90
            case .shortFocus: return 15
            case .custom: return 30
            }
        }
        
        var breakDuration: Int {
            switch self {
            case .pomodoro: return 5
            case .deepWork: return 20
            case .shortFocus: return 5
            case .custom: return 5
            }
        }
        
        var icon: String {
            switch self {
            case .pomodoro: return "timer"
            case .deepWork: return "brain.head.profile"
            case .shortFocus: return "bolt.fill"
            case .custom: return "slider.horizontal.3"
            }
        }
    }
    
    private func setupBackgroundHandlers() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleEnterBackground()
        }
        
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleEnterForeground()
        }
    }
    
    private func handleEnterBackground() {
        if isRunning {
            backgroundDate = Date()
            print("📱 Entrou em background às: \(backgroundDate!)")
        }
    }
    
    private func handleEnterForeground() {
        guard let backgroundDate = backgroundDate, isRunning else { return }
        
        let timeInBackground = Date().timeIntervalSince(backgroundDate)
        print("⏱️ Tempo em background: \(timeInBackground) segundos")
        
        timeRemaining -= timeInBackground
        
        if timeRemaining <= 0 {
            timeRemaining = 0
            completeTimer()
        }
        
        self.backgroundDate = nil
        objectWillChange.send()
    }
    
    private func setupNotificationListener() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SetTimerSession"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let sessionType = notification.userInfo?["sessionType"] as? SessionType {
                self?.setSession(sessionType)
            }
        }
    }
    
    func setSession(_ type: SessionType) {
        selectedSession = type
        isBreakTime = false
        cycleCount = 0
        
        switch type {
        case .pomodoro:
            timeRemaining = 25 * 60
        case .deepWork:
            timeRemaining = 90 * 60
        case .shortFocus:
            timeRemaining = 15 * 60
        case .custom:
            let savedFocus = UserDefaults.standard.integer(forKey: "customFocusTime")
            let savedBreak = UserDefaults.standard.integer(forKey: "customBreakTime")
            
            customMinutes = savedFocus == 0 ? 30 : savedFocus
            customBreakMinutes = savedBreak == 0 ? 5 : savedBreak
            
            timeRemaining = TimeInterval(customMinutes * 60)
        }
        
        originalTime = timeRemaining
        isRunning = false
        isPaused = false
        backgroundDate = nil
    }
    
    func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        isPaused = false
                
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.completeTimer()
            }
        }
    }
    
    func pauseTimer() {
        isPaused = true
        isRunning = false
        timer?.invalidate()
        timer = nil
        backgroundDate = nil
    }
    
    func resumeTimer() {
        guard isPaused else { return }
        startTimer()
    }
    
    func stopTimer() {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        timeRemaining = originalTime
        backgroundDate = nil
    }
    
    func resetTimer() {
        stopTimer()
        isBreakTime = false
        cycleCount = 0
        setSession(selectedSession)
    }
    
    func addTime(minutes: Int) {
        timeRemaining += TimeInterval(minutes * 60)
        originalTime += TimeInterval(minutes * 60)
    }
    
    private func completeTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        backgroundDate = nil
        
        AudioServicesPlaySystemSound(1108)
        
        if !isBreakTime {
            sessionsCompleted += 1
            cycleCount += 1
            
            let minutesStudied = actualMinutesStudied
            
            // SALVA A SESSÃO NO HISTÓRICO
            saveStudySession(minutes: minutesStudied)
            
            NotificationCenter.default.post(
                name: NSNotification.Name("TimerCompleted"),
                object: nil,
                userInfo: ["minutes": minutesStudied, "type": selectedSession.rawValue]
            )
            
            NotificationCenter.default.post(
                name: .timerCompleted,
                object: nil,
                userInfo: ["wasBreakTime": false]
            )
            
            prepareBreak()
            
            if autoStartBreaks {
                print("🚀 Auto-iniciando pausa...")
                startTimer()
            }
            
        } else {
            NotificationCenter.default.post(
                name: NSNotification.Name("BreakCompleted"),
                object: nil,
                userInfo: nil
            )
            
            NotificationCenter.default.post(
                name: .timerCompleted,
                object: nil,
                userInfo: ["wasBreakTime": true]
            )
            
            isBreakTime = false
            setSession(selectedSession)
            
            if autoStartPomodoros {
                print("🚀 Auto-iniciando próximo pomodoro...")
                startTimer()
            }
        }
    }
    
    private func prepareBreak() {
        isBreakTime = true
        
        let breakDuration = breakMinutes
        timeRemaining = TimeInterval(breakDuration * 60)
        originalTime = TimeInterval(breakDuration * 60)
        
        print("☕ Pausa preparada: \(breakDuration) minutos")
    }
    
    func startBreak() {
        guard isBreakTime else { return }
        startTimer()
    }
    
    func skipBreak() {
        if isBreakTime {
            isBreakTime = false
            setSession(selectedSession)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let observer = backgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

extension Notification.Name {
    static let timerCompleted = Notification.Name("timerCompleted")
}
