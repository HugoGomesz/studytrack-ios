//
//  SwiftUIView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var profileManager: ProfileManager
    
    @State private var showAchievements = false
    @State private var showEditGoalSheet = false
    
    var taskCompletionRate: Double {
        guard !taskStore.tasks.isEmpty else { return 0 }
        let completed = taskStore.tasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(taskStore.tasks.count)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.lg) {
                headerSection
                
                StreakWidget()
                    .environmentObject(streakManager)
                    .padding(.horizontal)
                
                dailyProgressCard
                
                quickActionsSection
                
                tasksProgressSection
                
                achievementsSection
            }
            .padding(.vertical, AppSpacing.md)
            .padding(.bottom, 120)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
    
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Olá, \(profileManager.userName)!")
                    .font(AppTypography.title1)
                    .foregroundStyle(.primary)
                
                Text(greetingMessage)
                    .font(AppTypography.callout)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                NotificationCenter.default.post(name: NSNotification.Name("ShowProfile"), object: nil)
            } label: {
                if let image = profileManager.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: AppColors.primary.opacity(0.2), radius: 8, y: 4)
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Text(profileManager.initials)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: AppColors.primary.opacity(0.2), radius: 8, y: 4)
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
    }
    
    private var dailyProgressCard: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progresso Diário")
                        .font(AppTypography.title3)
                        .foregroundStyle(.primary)
                    
                    Text("Meta: \(String(format: "%.1fh", sessionManager.dailyGoalHours))")
                        .font(AppTypography.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    showEditGoalSheet = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.primary)
                }
            }
            
            ZStack {
                Circle()
                    .stroke(AppColors.secondary.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: sessionManager.progressPercentage)
                    .stroke(
                        AppColors.primaryGradient,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: sessionManager.progressPercentage)
                
                VStack(spacing: 4) {
                    Text(String(format: "%.1fh", sessionManager.hoursStudiedToday))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("de \(String(format: "%.1fh", sessionManager.dailyGoalHours))")
                        .font(AppTypography.callout)
                        .foregroundStyle(.secondary)
                    
                    Text("\(Int(sessionManager.progressPercentage * 100))%")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(AppColors.primary.opacity(0.1))
                        )
                        .padding(.top, 4)
                }
            }
            
            Button {
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToTimer"), object: nil)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Iniciar Estudo")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: AppColors.primary.opacity(0.3), radius: 15, y: 8)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 20, y: 10)
        )
        .padding(.horizontal, AppSpacing.md)
        .sheet(isPresented: $showEditGoalSheet) {
            EditGoalSheet()
                .environmentObject(sessionManager)
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Sessões Rápidas")
                .font(AppTypography.title3)
                .padding(.horizontal, AppSpacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickSessionCard(
                        title: "Pomodoro",
                        duration: "25 min",
                        icon: "timer",
                        color: AppColors.accent,
                        gradient: LinearGradient(
                            colors: [AppColors.accentLight, AppColors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        action: {
                            startQuickSession(type: .pomodoro)
                        }
                    )
                    
                    QuickSessionCard(
                        title: "Deep Work",
                        duration: "90 min",
                        icon: "brain.head.profile",
                        color: AppColors.secondary,
                        gradient: LinearGradient(
                            colors: [AppColors.secondaryLight, AppColors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        action: {
                            startQuickSession(type: .deepWork)
                        }
                    )
                    
                    QuickSessionCard(
                        title: "Short Focus",
                        duration: "15 min",
                        icon: "bolt.fill",
                        color: AppColors.primary,
                        gradient: AppColors.primaryGradient,
                        action: {
                            startQuickSession(type: .shortFocus)
                        }
                    )
                    
                    QuickSessionCard(
                        title: "Custom",
                        duration: "Personalizar",
                        icon: "slider.horizontal.3",
                        color: AppColors.focusPurple,
                        gradient: LinearGradient(
                            colors: [AppColors.focusPurple.opacity(0.8), AppColors.focusPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        action: {
                            startQuickSession(type: .custom)
                        }
                    )
                }
                .padding(.horizontal, AppSpacing.md)
            }
        }
    }
    
    private var tasksProgressSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Progresso de Tarefas")
                    .font(AppTypography.title3)
                
                Spacer()
                
                Text("\(Int(taskCompletionRate * 100))% concluído")
                    .font(AppTypography.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, AppSpacing.md)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.secondary.opacity(0.15))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.secondaryLight, AppColors.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * taskCompletionRate, height: 12)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: taskCompletionRate)
                }
            }
            .frame(height: 12)
            .padding(.horizontal, AppSpacing.md)
            
            VStack(spacing: 12) {
                ForEach(taskStore.tasks.prefix(2)) { task in
                    ModernTaskRow(
                        task: task,
                        onToggle: {
                            taskStore.toggleTask(task)
                        }
                    )
                }
                
                if taskStore.tasks.isEmpty {
                    Text("Nenhuma tarefa pendente 🎉")
                        .font(AppTypography.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Conquistas")
                    .font(AppTypography.title3)
                
                Spacer()
                
                Button {
                    showAchievements = true
                } label: {
                    Text("Ver todas")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondary)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ModernAchievementCard(
                        icon: "flame.fill",
                        title: "\(streakManager.currentStreak) dias seguidos",
                        isUnlocked: streakManager.currentStreak >= 3,
                        color: .orange
                    )
                    
                    ModernAchievementCard(
                        icon: "target",
                        title: "Meta semanal alcançada",
                        isUnlocked: sessionManager.progressPercentage >= 1.0,
                        color: .green
                    )
                    
                    ModernAchievementCard(
                        icon: "checkmark.circle.fill",
                        title: "Todas tarefas concluídas",
                        isUnlocked: taskCompletionRate >= 1.0 && !taskStore.tasks.isEmpty,
                        color: .blue
                    )
                    
                    ModernAchievementCard(
                        icon: "star.fill",
                        title: "10 horas estudadas",
                        isUnlocked: sessionManager.hoursStudiedToday >= 10,
                        color: .yellow
                    )
                }
                .padding(.horizontal, AppSpacing.md)
            }
        }
    }
    
    private func startQuickSession(type: TimerManager.SessionType) {
        NotificationCenter.default.post(
            name: NSNotification.Name("StartQuickSession"),
            object: nil,
            userInfo: ["sessionType": type]
        )
        NotificationCenter.default.post(name: NSNotification.Name("SwitchToTimer"), object: nil)
    }
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Vamos estudar hoje?"
        case 12..<18: return "Pronto para focar?"
        case 18..<22: return "Hora de revisar!"
        default: return "Ainda acordado? 🌙"
        }
    }
}

// MARK: - Edit Goal Sheet

struct EditGoalSheet: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedHours: Double = 5.0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Defina sua meta diária")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Quantas horas você quer estudar por dia?")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 24) {
                    Text("\(String(format: "%.1f", selectedHours)) horas")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Slider(value: $selectedHours, in: 1...12, step: 0.5)
                        .tint(AppColors.primary)
                        .padding(.horizontal, 40)
                    
                    HStack {
                        Text("1h")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("12h")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 40)
                }
                
                VStack(spacing: 12) {
                    Text("Sugestões:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        GoalPresetButton(hours: 2, selectedHours: $selectedHours)
                        GoalPresetButton(hours: 4, selectedHours: $selectedHours)
                        GoalPresetButton(hours: 6, selectedHours: $selectedHours)
                        GoalPresetButton(hours: 8, selectedHours: $selectedHours)
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                Button {
                    sessionManager.dailyGoalHours = selectedHours
                    dismiss()
                } label: {
                    Text("Salvar Meta")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: AppColors.primary.opacity(0.3), radius: 15, y: 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            selectedHours = sessionManager.dailyGoalHours
        }
    }
}

struct GoalPresetButton: View {
    let hours: Double
    @Binding var selectedHours: Double
    
    var body: some View {
        Button {
            selectedHours = hours
        } label: {
            Text("\(Int(hours))h")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(selectedHours == hours ? .white : AppColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedHours == hours ? AppColors.primary : AppColors.primary.opacity(0.1))
                )
        }
    }
}
// MARK: - Supporting Views

struct QuickSessionCard: View {
    let title: String
    let duration: String
    let icon: String
    let color: Color
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(gradient)
                            .shadow(color: color.opacity(0.4), radius: 10, y: 5)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text(duration)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 160, height: 140)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppColors.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 15, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ModernTaskRow: View {
    let task: Task
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(task.isCompleted ? AppColors.success : task.color.opacity(0.5))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(AppTypography.body)
                        .foregroundStyle(.primary)
                        .strikethrough(task.isCompleted)
                    
                    Text(task.subject)
                        .font(AppTypography.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(task.subject.prefix(3).uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(task.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(task.color.opacity(0.15))
                    )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ModernAchievementCard: View {
    let icon: String
    let title: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                        ? LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        : LinearGradient(
                            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 70, height: 70)
                
                if isUnlocked {
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundStyle(color)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary.opacity(0.5))
                }
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 110)
        }
        .frame(width: 130, height: 140)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    isUnlocked ? color.opacity(0.3) : Color.gray.opacity(0.2),
                    lineWidth: 2
                )
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
        .environmentObject(TaskStore())
        .environmentObject(SessionManager())
        .environmentObject(StreakManager())
        .environmentObject(ProfileManager())
}
