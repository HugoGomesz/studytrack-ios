//
//  RootView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

// RootView.swift - VERSÃO COMPLETA E INTEGRADA
import SwiftUI

struct RootView: View {
    @StateObject private var streakManager = StreakManager()
    @StateObject private var levelSystem = LevelSystem()
    @StateObject private var challengeManager = ChallengeManager()
    @StateObject private var taskStore = TaskStore()
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var timerManager = TimerManager()
    @StateObject private var profileManager = ProfileManager() 
    
    @State private var selectedTab: Tab = .home
    @State private var showProfile = false
    @Namespace private var animation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.background.ignoresSafeArea()
            
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .timer:
                    TimerView()
                case .tasks:
                    TasksView()
                case .dashboard:
                    DashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environmentObject(timerManager)
            .environmentObject(streakManager)
            .environmentObject(levelSystem)
            .environmentObject(challengeManager)
            .environmentObject(taskStore)
            .environmentObject(sessionManager)
            .environmentObject(profileManager)
            
            CustomTabBar(selectedTab: $selectedTab, animation: animation)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(profileManager)
                .environmentObject(streakManager)
                .environmentObject(levelSystem)
                .environmentObject(sessionManager)
        }
        .onAppear {
            streakManager.checkStreakStatus()
            setupNotifications()
        }
        .overlay {
            if streakManager.showFreezeUsedAlert {
                FreezeUsedAlert()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            withAnimation {
                                streakManager.showFreezeUsedAlert = false
                            }
                        }
                    }
            }
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SwitchToTimer"),
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = .timer
            }
        }
        
        // Quick Session
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("StartQuickSession"),
            object: nil,
            queue: .main
        ) { notification in
            if let sessionType = notification.userInfo?["sessionType"] as? TimerManager.SessionType {
                NotificationCenter.default.post(
                    name: NSNotification.Name("SetTimerSession"),
                    object: nil,
                    userInfo: ["sessionType": sessionType]
                )
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = .timer
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowProfile"),
            object: nil,
            queue: .main
        ) { _ in
            showProfile = true
        }
    }
}

// MARK: - Tab Enum
enum Tab: String, CaseIterable {
    case home = "house.fill"
    case timer = "timer"
    case tasks = "checkmark.circle.fill"
    case dashboard = "chart.bar.fill"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .timer: return "Foco"
        case .tasks: return "Tarefas"
        case .dashboard: return "Stats"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return AppColors.primary
        case .timer: return AppColors.accent
        case .tasks: return AppColors.secondary
        case .dashboard: return .purple
        }
    }
}

// MARK: - Custom TabBar with Glassmorphism
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    let animation: Namespace.ID
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    selectedTab: $selectedTab,
                    animation: animation
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 30, y: -5)
                
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
}

struct TabButton: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    let animation: Namespace.ID
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [tab.color.opacity(0.8), tab.color],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "TAB", in: animation)
                            .frame(height: 36)
                            .shadow(color: tab.color.opacity(0.4), radius: 12, y: 4)
                    }
                    
                    Image(systemName: tab.rawValue)
                        .font(.system(size: isSelected ? 20 : 18, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .frame(height: 36)
                }
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? tab.color : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Freeze Used Alert
struct FreezeUsedAlert: View {
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text("❄️")
                        .font(.system(size: 28))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Congelamento Usado")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text("Seu streak foi protegido automaticamente!")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            )
            .padding(.horizontal)
            .padding(.top, 60)
            
            Spacer()
        }
    }
}

#Preview {
    RootView()
}

