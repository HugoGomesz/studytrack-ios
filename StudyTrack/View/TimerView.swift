//
//  TimerView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var levelSystem: LevelSystem

    @State private var showSettings = false
    @State private var showCustomTimer = false
    @State private var pulseAnimation = false
    @State private var waveAnimation = false
    @State private var autoStartBreak: Bool = UserDefaults.standard.bool(forKey: "autoStartBreak")
    @Environment(\.colorScheme) var colorScheme

    var statusText: String {
        if timerManager.isBreakTime {
            return timerManager.isRunning ? "Pausa" : "Pausa Pausada"
        }
        if timerManager.isRunning { return "Em Foco" }
        if timerManager.isPaused { return "Pausado" }
        return "Aguardando"
    }
    
    var body: some View {
        ZStack {
            gradientBackground
            
            VStack(spacing: 0) {
                headerSection
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.top, AppSpacing.lg)
                
                Spacer()
                
                timerWithWaves
                
                Spacer()
                
                sessionSelector
                    .padding(.horizontal, AppSpacing.lg)
                
                Spacer().frame(height: 30)
                
                controlsSection
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showSettings) {
            TimerSettingsSheet(timerManager: timerManager)
        }
        .sheet(isPresented: $showCustomTimer) {
            CustomTimerSheet(timerManager: timerManager)
        }
        .onAppear {
            startAnimations()
            setupNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: .timerCompleted)) { notification in
            handleTimerCompletion(notification)
        }
    }
    
    // MARK: -  Notificações
    
    private func setupNotifications() {
        // Pede permissão
        NotificationManager.instance.requestAuthorization()
        
        // Agenda notificações diárias motivacionais
        let currentStreak = streakManager.currentStreak
        NotificationManager.instance.scheduleAllDailyNotifications(currentStreak: currentStreak)
        
        // Limpa badge vermelho do ícone
        NotificationManager.instance.clearBadge()
        
        // Debug: lista notificações pendentes
        #if DEBUG
        NotificationManager.instance.listPendingNotifications()
        #endif
    }
    
    private func handleTimerCompletion(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let wasBreakTime = userInfo["wasBreakTime"] as? Bool else { return }
        
        if wasBreakTime {
            // Pausa terminou
            handleBreakCompletion()
        } else {
            // Foco terminou
            handleFocusCompletion()
        }
    }
    
    /// Chamado quando o tempo de FOCO termina
    private func handleFocusCompletion() {
        print("🎯 Foco completado!")
        
        // Cancela notificação de foco
        NotificationManager.instance.cancelTimerNotifications()
        
        let minutesStudied = timerManager.actualMinutesStudied
        
        // Celebração com tempo REAL
        NotificationManager.instance.sendCelebrationNotification(
            message: "Você completou \(minutesStudied) minutos de foco! 🎉"
        )
        
        // Atualiza streak
        streakManager.incrementStreak()
        NotificationManager.instance.updateStreakProtectionNumber(newStreak: streakManager.currentStreak)
        
        // Registra sessão com tempo REAL
        sessionManager.addSession(
            duration: minutesStudied,
            type: timerManager.selectedSession.rawValue
        )
        
        // XP baseado no tempo REAL
        levelSystem.addExperience(points: minutesStudied * 2)
        
        // Auto-start pausa
        autoStartBreak = UserDefaults.standard.bool(forKey: "autoStartBreak")
        if autoStartBreak {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                startBreakTimer()
            }
        }
    }
    
    /// Chamado quando o tempo de PAUSA termina
    private func handleBreakCompletion() {
        print("☕ Pausa completada!")
        
        // Cancela notificação de pausa
        NotificationManager.instance.cancelTimerNotifications()
        
        // Notifica que pode voltar ao foco
        NotificationManager.instance.sendCelebrationNotification(
            message: "Pausa finalizada! Pronto para mais uma sessão? 💪"
        )
    }
    
    /// Inicia o timer de pausa automaticamente
    private func startBreakTimer() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            timerManager.startBreak()
            
            // Agenda notificação para quando a pausa terminar
            let breakDuration = timerManager.breakMinutes * 60
            NotificationManager.instance.scheduleBreakCompletion(duration: TimeInterval(breakDuration))
        }
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    // MARK: - UI Components
    
    private var gradientBackground: some View {
        ZStack {
            LinearGradient(
                colors: timerManager.isRunning ? [
                    AppColors.focusPurple,
                    AppColors.focusPurpleDark,
                    AppColors.focusPink
                ] : [
                    AppColors.timerInactiveDark,
                    AppColors.timerInactiveMedium,
                    AppColors.timerInactiveLight
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5), value: timerManager.isRunning)
            
            if timerManager.isRunning {
                MeshGradientView()
                    .ignoresSafeArea()
                    .opacity(0.3)
            }
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(timerManager.isRunning ? "Foco Total" : "Pronto?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14))
                    Text(timerManager.selectedSession.rawValue)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
    }
    
    private var timerWithWaves: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 280 + CGFloat(index * 40))
                    .scaleEffect(waveAnimation ? 1.0 : 0.8)
                    .opacity(waveAnimation ? 0 : 0.6)
                    .animation(
                        .easeOut(duration: 3)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.4),
                        value: waveAnimation
                    )
            }
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.15),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 280, height: 280)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                
                Circle()
                    .trim(from: 0, to: timerManager.progress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.focusPink,
                                AppColors.focusRed,
                                AppColors.focusYellow
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                    .shadow(
                        color: AppColors.focusRed.opacity(0.6),
                        radius: timerManager.isRunning ? 25 : 0,
                        y: 0
                    )
                    .animation(
                        timerManager.isRunning ? .linear(duration: 0.5) : .none,
                        value: timerManager.progress
                    )
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, AppColors.focusYellow],
                            center: .center,
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .frame(width: 24, height: 24)
                    .shadow(color: .white.opacity(0.8), radius: 10)
                    .offset(y: -140)
                    .rotationEffect(.degrees(timerManager.progress * 360.0 - 90.0))
                    .animation(.linear(duration: 1), value: timerManager.progress)
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .white.opacity(0.1),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .opacity(pulseAnimation ? 0.5 : 1.0)
                            .animation(
                                .easeInOut(duration: 2)
                                .repeatForever(autoreverses: true),
                                value: pulseAnimation
                            )
                        
                        Image(systemName: timerManager.isRunning ? "flame.fill" : "sparkles")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, AppColors.focusYellow],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .rotationEffect(.degrees(timerManager.isRunning ? 360 : 0))
                            .animation(
                                .linear(duration: 20)
                                .repeatForever(autoreverses: false),
                                value: timerManager.isRunning
                            )
                    }
                    
                    Text(timerManager.formattedTime)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .shadow(color: .black.opacity(0.3), radius: 10)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(timerManager.isBreakTime ? AppColors.focusYellow :
                                  timerManager.isRunning ? AppColors.success : Color.gray)
                            .frame(width: 8, height: 8)
                         
                        Text(statusText)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    private var sessionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimerManager.SessionType.allCases, id: \.self) { type in
                    SessionPill(
                        type: type,
                        isSelected: timerManager.selectedSession == type
                    ) {
                        if !timerManager.isRunning && !timerManager.isPaused {
                            if type == .custom {
                                showCustomTimer = true
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    timerManager.setSession(type)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
    
    private var controlsSection: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    timerManager.resetTimer()
                    NotificationManager.instance.cancelTimerNotifications()
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    )
            }
            .disabled(!timerManager.canReset)
            .opacity(timerManager.canReset ? 1.0 : 0.5)
            .frame(width: 80)
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    if timerManager.isRunning {
                        // PAUSOU - cancela notificações agendadas
                        timerManager.pauseTimer()
                        NotificationManager.instance.cancelTimerNotifications()
                    } else {
                        // INICIOU - agenda notificação para quando terminar
                        timerManager.startTimer()
                        
                        // Agenda notificação baseado no tipo de timer
                        let remainingSeconds = timerManager.timeRemaining
                        if timerManager.isBreakTime {
                            NotificationManager.instance.scheduleBreakCompletion(duration: remainingSeconds)
                        } else {
                            NotificationManager.instance.scheduleFocusCompletion(duration: remainingSeconds)
                        }
                    }
                }
                
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(0.4),
                                    .white.opacity(0.2),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(timerManager.isRunning ? 1.3 : 1.0)
                        .opacity(timerManager.isRunning ? 0.8 : 0)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                            value: timerManager.isRunning
                        )
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                    
                    Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: timerManager.isBreakTime ?
                                    [AppColors.focusYellow, AppColors.focusRed] :
                                    [AppColors.focusPurple, AppColors.focusPurpleDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .offset(x: timerManager.isRunning ? 0 : 5)
                }
            }
            
            Spacer()
            
            Button {
                if timerManager.isBreakTime {
                    withAnimation {
                        timerManager.skipBreak()
                        NotificationManager.instance.cancelTimerNotifications()
                    }
                } else {
                    timerManager.addTime(minutes: 5)
                    // Reagenda notificação com tempo adicional
                    if timerManager.isRunning {
                        NotificationManager.instance.cancelTimerNotifications()
                        let remainingSeconds = timerManager.timeRemaining
                        NotificationManager.instance.scheduleFocusCompletion(duration: remainingSeconds)
                    }
                }
            } label: {
                Image(systemName: timerManager.isBreakTime ? "forward.fill" : "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    )
            }
            .frame(width: 80)
        }
    }

    func startAnimations() {
        withAnimation {
            pulseAnimation = true
            waveAnimation = true
        }
    }
}

// MARK: - Notification Name Extension
//extension Notification.Name {
//    static let timerCompleted = Notification.Name("timerCompleted")
//}

// MARK: - Session Pill
struct SessionPill: View {
    let type: TimerManager.SessionType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 16, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                    Text("\(type.duration) min")
                        .font(.system(size: 11, weight: .medium))
                        .opacity(0.8)
                }
            }
            .foregroundStyle(isSelected ? AppColors.focusPurple : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? .white : .white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.clear : .white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(
                        color: isSelected ? .white.opacity(0.3) : .clear,
                        radius: 10,
                        y: 5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Control Button
struct ControlButton: View {
    let icon: String
    let size: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(foregroundColor)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(backgroundColor)
                        .overlay(
                            Circle()
                                .stroke(foregroundColor.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Mesh Gradient View
struct MeshGradientView: View {
    @State private var move = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.focusPink.opacity(0.4),
                                AppColors.focusRed.opacity(0.2),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(
                        x: move ? CGFloat.random(in: -150...150) : CGFloat.random(in: -100...100),
                        y: move ? CGFloat.random(in: -200...200) : CGFloat.random(in: -150...150)
                    )
                    .blur(radius: 50)
                    .animation(
                        .easeInOut(duration: Double.random(in: 4...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: move
                    )
            }
        }
        .onAppear {
            move = true
        }
    }
}

// MARK: - Timer Settings Sheet
struct TimerSettingsSheet: View {
    @ObservedObject var timerManager: TimerManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Preferências") {
                    Toggle("Sons de alerta", isOn: .constant(true))
                    Toggle("Vibração", isOn: .constant(true))
                }
                
                Section("Sobre") {
                    HStack {
                        Text("Versão")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Custom Timer Sheet
struct CustomTimerSheet: View {
    @ObservedObject var timerManager: TimerManager
    @Environment(\.dismiss) var dismiss
    
    @State private var focusTime: Int = {
        let saved = UserDefaults.standard.integer(forKey: "customFocusTime")
        return saved == 0 ? 30 : saved
    }()
    
    @State private var breakTime: Int = {
        let saved = UserDefaults.standard.integer(forKey: "customBreakTime")
        return saved == 0 ? 5 : saved
    }()
    
    @State private var autoStartBreak: Bool = UserDefaults.standard.bool(forKey: "autoStartBreak")
    
    var body: some View {
        ZStack {
            AppColors.timerGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(.white.opacity(0.2))
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 32) {
                        VStack(spacing: 12) {
                            Text("⚙️")
                                .font(.system(size: 60))
                            
                            Text("Configurar Sessão")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Personalize seu tempo de foco e pausa")
                                .font(.system(size: 15))
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 10)
                        
                        VStack(spacing: 20) {
                            TimePickerCard(
                                title: "Tempo de Foco",
                                subtitle: "Quanto tempo você quer focar?",
                                icon: "brain.head.profile",
                                time: $focusTime,
                                range: 5...180,
                                color: AppColors.focusPink
                            )
                            
                            TimePickerCard(
                                title: "Tempo de Pausa",
                                subtitle: "Quanto tempo de descanso?",
                                icon: "cup.and.saucer.fill",
                                time: $breakTime,
                                range: 1...60,
                                color: AppColors.focusYellow
                            )
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Label("Iniciar pausa automaticamente", systemImage: "play.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                    
                                    Text("Começar pausa assim que o foco terminar")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $autoStartBreak)
                                    .labelsHidden()
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(AppColors.success)
                                
                                Text("Resumo da Sessão")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                SummaryRow(
                                    icon: "timer",
                                    label: "Foco",
                                    value: "\(focusTime) min"
                                )
                                
                                Divider()
                                    .background(.white.opacity(0.3))
                                
                                SummaryRow(
                                    icon: "cup.and.saucer.fill",
                                    label: "Pausa",
                                    value: "\(breakTime) min"
                                )
                                
                                Divider()
                                    .background(.white.opacity(0.3))
                                
                                SummaryRow(
                                    icon: "arrow.clockwise",
                                    label: "Ciclo completo",
                                    value: "\(focusTime + breakTime) min"
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                        
                        Button {
                            saveAndStart()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18, weight: .bold))
                                
                                Text("Começar Sessão")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundStyle(AppColors.focusPurple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
    
    func saveAndStart() {
        UserDefaults.standard.set(focusTime, forKey: "customFocusTime")
        UserDefaults.standard.set(breakTime, forKey: "customBreakTime")
        UserDefaults.standard.set(autoStartBreak, forKey: "autoStartBreak")
        
        timerManager.customMinutes = focusTime
        timerManager.customBreakMinutes = breakTime
        timerManager.setSession(.custom)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
    
    // MARK: - Time Picker Card
    struct TimePickerCard: View {
        let title: String
        let subtitle: String
        let icon: String
        @Binding var time: Int
        let range: ClosedRange<Int>
        let color: Color
        
        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(color)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(color.opacity(0.2))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
                
                Text("\(time)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.1))
                    )
                
                HStack(spacing: 16) {
                    Button {
                        if time > range.lowerBound {
                            time -= 1
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .disabled(time <= range.lowerBound)
                    .opacity(time <= range.lowerBound ? 0.5 : 1.0)
                    
                    Slider(value: Binding(
                        get: { Double(time) },
                        set: { time = Int($0) }
                    ), in: Double(range.lowerBound)...Double(range.upperBound), step: 1)
                    .tint(color)
                    
                    Button {
                        if time < range.upperBound {
                            time += 1
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .disabled(time >= range.upperBound)
                    .opacity(time >= range.upperBound ? 0.5 : 1.0)
                }
                
                HStack(spacing: 8) {
                    ForEach(getPresets(), id: \.self) { preset in
                        Button {
                            time = preset
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        } label: {
                            Text("\(preset)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(time == preset ? color : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(time == preset ? .white : .white.opacity(0.2))
                                )
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        
        func getPresets() -> [Int] {
            if range.upperBound <= 60 {
                return [5, 10, 15, 20]
            } else {
                return [15, 25, 45, 60, 90]
            }
        }
    }
    
    // MARK: - Summary Row
    struct SummaryRow: View {
        let icon: String
        let label: String
        let value: String
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 30)
                
                Text(label)
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.9))
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
    
    #Preview {
        TimerView()
            .environmentObject(TimerManager())
            .environmentObject(SessionManager())
            .environmentObject(StreakManager())
            .environmentObject(LevelSystem())
    }
}
