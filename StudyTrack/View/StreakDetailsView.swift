//
//  StreakDetailsView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 19/10/25.
//

import SwiftUI

struct StreakDetailsView: View {
    @EnvironmentObject var streakManager: StreakManager
    @Environment(\.dismiss) var dismiss
    @State private var showBuyFreezeSheet = false
    @State private var showToggleFeedback = false
    @State private var showUseFreezeConfirmation = false
    @State private var showFreezeAnimation = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    streakHero
                    freezeProtectionToggle
                    freezesCard
                    activityCalendar
                    milestonesSection
                    statsSection
                }
                .padding()
                .padding(.bottom, 40)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Seu Streak")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showBuyFreezeSheet) {
            BuyFreezeSheet()
                .environmentObject(streakManager)
        }
        .alert("Usar Congelamento?", isPresented: $showUseFreezeConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Congelar Streak", role: .destructive) {
                useFreezeWithAnimation()
            }
        } message: {
            Text("Tem certeza que deseja usar um congelamento agora? Isso protegerá seu streak por hoje.")
        }
        .overlay {
            if showFreezeAnimation {
                freezeAnimationOverlay
            }
        }
    }
    
    private var freezeAnimationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.cyan.opacity(0.6),
                                    Color.blue.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    Text("❄️")
                        .font(.system(size: 120))
                        .scaleEffect(showFreezeAnimation ? 1.2 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showFreezeAnimation)
                }
                
                VStack(spacing: 8) {
                    Text("Streak Congelado!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Seu streak está protegido por hoje")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .transition(.opacity)
    }
    
    private func useFreezeWithAnimation() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showFreezeAnimation = true
        }
        
        streakManager.useFreeze()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showFreezeAnimation = false
            }
        }
    }
    
    private var streakHero: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.3),
                                Color.red.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 20)
                
                Text("🔥")
                    .font(.system(size: 100))
            }
            
            VStack(spacing: 8) {
                Text("\(streakManager.currentStreak)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(streakManager.currentStreak == 1 ? "dia de estudo" : "dias consecutivos")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Text(getMotivationalMessage())
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 20, y: 10)
        )
    }
    
    private var freezeProtectionToggle: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: streakManager.freezeProtectionEnabled ? "shield.checkered" : "shield.slash")
                    .font(.title2)
                    .foregroundStyle(streakManager.freezeProtectionEnabled ? .green : .gray)
                
                Text("Proteção Automática")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Toggle("", isOn: $streakManager.freezeProtectionEnabled)
                    .onChange(of: streakManager.freezeProtectionEnabled) { _ in
                        streakManager.toggleProtection()
                        showToggleFeedback = true
                        
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }
            }
            
            if streakManager.freezeProtectionEnabled {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Seus congelamentos serão usados automaticamente se você perder um dia")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Atenção: Seu streak não está protegido. Ative para usar congelamentos automaticamente.")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                )
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Como funciona?", systemImage: "info.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text("Se você não estudar por um dia, um congelamento é usado automaticamente")
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text("Seu streak continua como se você tivesse estudado")
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text("Você pode desativar a proteção a qualquer momento")
                    }
                }
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    private var freezesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "snowflake")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text("Congelamentos de Streak")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
            }
            
            Text("Proteja seu streak quando não puder estudar. Você tem **\(streakManager.streakFreezes)** congelamentos disponíveis.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(index < streakManager.streakFreezes ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                            .frame(height: 60)
                        
                        if index < streakManager.streakFreezes {
                            Text("❄️")
                                .font(.system(size: 30))
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.title3)
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            
            Button {
                showBuyFreezeSheet = true
            } label: {
                HStack {
                    Image(systemName: streakManager.streakFreezes < 3 ? "cart.fill" : "plus.circle.fill")
                    Text(streakManager.streakFreezes < 3 ? "Comprar mais congelamentos" : "Comprar congelamentos extras")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            if streakManager.streakFreezes > 0 {
                Button {
                    showUseFreezeConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "snowflake")
                        Text("Usar Congelamento Agora")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text("Use XP para comprar congelamentos")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    private var activityCalendar: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Últimos 7 dias")
                .font(.system(size: 18, weight: .semibold))
            
            HStack(spacing: 8) {
                ForEach(getLast7Days(), id: \.self) { day in
                    VStack(spacing: 8) {
                        Text(day.dayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        ZStack {
                            Circle()
                                .fill(day.isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                                .frame(width: 44, height: 44)
                            
                            if day.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.green)
                            } else if day.isToday {
                                Text(day.dayNumber)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.primary)
                            } else {
                                Text(day.dayNumber)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .overlay(
                            Circle()
                                .strokeBorder(day.isToday ? Color.orange : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Marcos de Streak 🏆")
                .font(.system(size: 18, weight: .semibold))
            
            VStack(spacing: 12) {
                ForEach(streakManager.streakMilestones.prefix(5), id: \.self) { milestone in
                    MilestoneRow(
                        milestone: milestone,
                        isAchieved: streakManager.currentStreak >= milestone,
                        isCurrent: streakManager.currentStreak < milestone && milestone == getNextMilestone()
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estatísticas")
                .font(.system(size: 18, weight: .semibold))
            
            HStack(spacing: 16) {
                StatBox(
                    icon: "flame.fill",
                    value: "\(streakManager.currentStreak)",
                    label: "Atual",
                    color: .orange
                )
                
                StatBox(
                    icon: "trophy.fill",
                    value: "\(streakManager.longestStreak)",
                    label: "Recorde",
                    color: .yellow
                )
                
                StatBox(
                    icon: "calendar.badge.clock",
                    value: "\(getDaysStudying())",
                    label: "Total",
                    color: .blue
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
    
    func getMotivationalMessage() -> String {
        switch streakManager.currentStreak {
        case 0:
            return "Comece hoje! Todo grande streak começa com o primeiro dia."
        case 1...2:
            return "Ótimo começo! Continue assim para construir um hábito."
        case 3...6:
            return "Você está no caminho certo! Mantenha o foco."
        case 7...13:
            return "Uma semana completa! Você está arrasando! 🎉"
        case 14...29:
            return "Incrível! Você está formando um hábito sólido."
        case 30...99:
            return "Você é imparável! Continue nessa jornada."
        default:
            return "Lenda! Você é uma inspiração! 🌟"
        }
    }
    
    func getNextMilestone() -> Int? {
        streakManager.streakMilestones.first(where: { $0 > streakManager.currentStreak })
    }
    
    func getLast7Days() -> [DayInfo] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let dayNumber = calendar.component(.day, from: date)
            let dayName = date.formatted(.dateTime.weekday(.abbreviated))
            
            return DayInfo(
                dayName: String(dayName.prefix(3)),
                dayNumber: "\(dayNumber)",
                isCompleted: daysAgo <= streakManager.currentStreak && streakManager.currentStreak > 0,
                isToday: daysAgo == 0
            )
        }
    }
    
    func getDaysStudying() -> Int {
        return streakManager.longestStreak + 10
    }
}

struct MilestoneRow: View {
    let milestone: Int
    let isAchieved: Bool
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isAchieved ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                if isAchieved {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(milestone) dias")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isAchieved ? .primary : .secondary)
                
                Text(getMilestoneReward(milestone))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isCurrent {
                Text("Próximo")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.15))
                    )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrent ? Color.orange.opacity(0.05) : Color.clear)
        )
    }
    
    func getMilestoneReward(_ days: Int) -> String {
        switch days {
        case 3: return "Badge de Iniciante"
        case 7: return "Badge de Dedicação"
        case 14: return "Badge de Consistência"
        case 30: return "Badge de Mestre + 100 XP"
        case 50: return "Badge de Lenda + Tema especial"
        case 100: return "Badge de Imortal + 500 XP"
        case 365: return "Badge de Ano Completo + Surpresa!"
        default: return "Recompensa especial"
        }
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

struct DayInfo: Hashable {
    let dayName: String
    let dayNumber: String
    let isCompleted: Bool
    let isToday: Bool
}

#Preview {
    StreakDetailsView()
        .environmentObject(StreakManager())
}
