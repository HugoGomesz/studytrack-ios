//
//  ProfileView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 05/11/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var levelSystem: LevelSystem
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var editedName: String = ""
    @State private var isEditingName = false
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            dynamicBackground
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroHeaderSection
                        .offset(y: -scrollOffset * 0.5)
                    
                    VStack(spacing: 28) {
                        levelProgressCard
                        statsGrid
                        achievementsCarousel
                        settingsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).minY
                    )
                })
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: Binding(
                get: { profileManager.profileImage },
                set: { profileManager.updateProfileImage($0) }
            ))
        }
        .confirmationDialog("Foto de Perfil", isPresented: $showActionSheet) {
            Button("Escolher da Galeria") {
                showImagePicker = true
            }
            
            if profileManager.profileImage != nil {
                Button("Remover Foto", role: .destructive) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        profileManager.updateProfileImage(nil)
                    }
                }
            }
            
            Button("Cancelar", role: .cancel) {}
        }
        .onAppear {
            editedName = profileManager.userName
        }
    }
    
    private var dynamicBackground: some View {
        ZStack {
            (colorScheme == .dark ? AppColors.darkBackground : Color(hex: "F8F9FA"))
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.primary.opacity(colorScheme == .dark ? 0.25 : 0.15),
                                    AppColors.primary.opacity(colorScheme == .dark ? 0.08 : 0.05),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: -100 + scrollOffset * 0.1, y: -200 + scrollOffset * 0.2)
                        .blur(radius: 40)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.secondary.opacity(colorScheme == .dark ? 0.2 : 0.12),
                                    AppColors.secondary.opacity(colorScheme == .dark ? 0.06 : 0.04),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 350, height: 350)
                        .offset(x: geometry.size.width - 150, y: 100 - scrollOffset * 0.15)
                        .blur(radius: 50)
                }
            }
        }
    }
    
    private var heroHeaderSection: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 80)
            
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.primary.opacity(0.15 - Double(index) * 0.05),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: CGFloat(20 + index * 10))
                        .offset(y: CGFloat(index * 4))
                }
                
                ZStack(alignment: .bottomTrailing) {
                    if let image = profileManager.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [.white.opacity(0.8), .white.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 4
                                    )
                            )
                    } else {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppColors.primary,
                                            AppColors.primaryDark
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [.white.opacity(0.8), .white.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 4
                                        )
                                )
                            
                            Text(profileManager.initials)
                                .font(.system(size: 56, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Button {
                        showActionSheet = true
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppColors.secondary, AppColors.secondary.opacity(0.9)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    Circle()
                                        .fill(.white.opacity(0.2))
                                }
                            )
                            .shadow(color: AppColors.secondary.opacity(0.4), radius: 16, y: 8)
                    }
                    .offset(x: 8, y: 8)
                }
            }
            .scaleEffect(1 - min(max(scrollOffset, 0) / 500, 0.3))
            
            VStack(spacing: 12) {
                if isEditingName {
                    HStack(spacing: 12) {
                        TextField("Nome", text: $editedName)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colorScheme == .dark ? Color(white: 0.15) : .white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(AppColors.primary.opacity(0.3), lineWidth: 2)
                                    )
                            )
                        
                        Button {
                            saveEditedName()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(AppColors.success)
                                        .shadow(color: AppColors.success.opacity(0.3), radius: 8, y: 4)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isEditingName = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(profileManager.userName)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(AppColors.primary.opacity(0.6))
                        }
                    }
                }
                
                Text("@\(profileManager.userName.lowercased().replacingOccurrences(of: " ", with: ""))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Nível \(levelSystem.currentLevel) · \(levelSystem.title)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 12, y: 6)
                )
            }
        }
        .frame(height: 400)
    }
    
    private var levelProgressCard: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.success)
                        
                        Text("Próximo Nível")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("\(levelSystem.xpNeededForNextLevel() - levelSystem.currentXP) XP restantes")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(AppColors.primary.opacity(colorScheme == .dark ? 0.3 : 0.2), lineWidth: 8)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(levelSystem.currentXP) / CGFloat(levelSystem.xpNeededForNextLevel()))
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.0, dampingFraction: 0.8), value: levelSystem.currentXP)
                    
                    Text("\(Int((Double(levelSystem.currentXP) / Double(levelSystem.xpNeededForNextLevel())) * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.primary.opacity(colorScheme == .dark ? 0.2 : 0.1))
                        .frame(height: 10)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * CGFloat(levelSystem.currentXP) / CGFloat(levelSystem.xpNeededForNextLevel()),
                            height: 10
                        )
                        .animation(.spring(response: 1.0, dampingFraction: 0.8), value: levelSystem.currentXP)
                }
            }
            .frame(height: 10)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(colorScheme == .dark ? Color(white: 0.12) : .white)
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.08), radius: 20, y: 12)
        )
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            UltraStatCard(
                icon: "flame.fill",
                value: "\(streakManager.currentStreak)",
                label: "Dias",
                subtitle: "Streak",
                primaryColor: AppColors.primary,
                secondaryColor: AppColors.primaryLight,
                colorScheme: colorScheme
            )
            
            UltraStatCard(
                icon: "clock.fill",
                value: String(format: "%.1f", sessionManager.totalStudyTimeToday / 3600),
                label: "Horas",
                subtitle: "Hoje",
                primaryColor: AppColors.secondary,
                secondaryColor: AppColors.secondaryLight,
                colorScheme: colorScheme
            )
            
            UltraStatCard(
                icon: "trophy.fill",
                value: "\(levelSystem.currentLevel)",
                label: "Nível",
                subtitle: levelSystem.title,
                primaryColor: AppColors.secondary,
                secondaryColor: AppColors.secondaryLight,
                colorScheme: colorScheme
            )
            
            UltraStatCard(
                icon: "star.fill",
                value: "\(levelSystem.currentXP)",
                label: "XP",
                subtitle: "Total",
                primaryColor: AppColors.primary,
                secondaryColor: AppColors.primaryLight,
                colorScheme: colorScheme
            )
        }
    }
    
    private var achievementsCarousel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Conquistas")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {} label: {
                    Text("Ver todas")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<5) { index in
                        AchievementCard3D(
                            icon: ["flame.fill", "target", "star.fill", "trophy.fill", "crown.fill"][index],
                            title: ["Iniciante", "Focado", "Mestre", "Campeão", "Lenda"][index],
                            isUnlocked: index < 3,
                            color: [AppColors.primary, AppColors.secondary, AppColors.primary, AppColors.secondary, AppColors.primary][index],
                            colorScheme: colorScheme
                        )
                    }
                }
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: 12) {
            GlassSettingRow(icon: "bell.badge.fill", title: "Notificações", color: AppColors.secondary, colorScheme: colorScheme)
            GlassSettingRow(icon: "paintbrush.pointed.fill", title: "Aparência", color: AppColors.primary, colorScheme: colorScheme)
            GlassSettingRow(icon: "lock.shield.fill", title: "Privacidade", color: AppColors.secondary, colorScheme: colorScheme)
            GlassSettingRow(icon: "questionmark.circle.fill", title: "Ajuda", color: AppColors.primary, colorScheme: colorScheme)
            
            Button {
                profileManager.resetProfile()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Resetar Perfil")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(colorScheme == .dark ? 0.2 : 0.1))
                )
            }
        }
    }
    
    private func saveEditedName() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            profileManager.updateName(editedName)
            isEditingName = false
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct UltraStatCard: View {
    let icon: String
    let value: String
    let label: String
    let subtitle: String
    let primaryColor: Color
    let secondaryColor: Color
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    primaryColor.opacity(colorScheme == .dark ? 0.3 : 0.2),
                                    primaryColor.opacity(colorScheme == .dark ? 0.1 : 0.05),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(primaryColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color(white: 0.12) : .white)
                .shadow(color: primaryColor.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 20, y: 10)
        )
    }
}

struct AchievementCard3D: View {
    let icon: String
    let title: String
    let isUnlocked: Bool
    let color: Color
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                        ? RadialGradient(
                            colors: [color.opacity(colorScheme == .dark ? 0.4 : 0.3), color.opacity(colorScheme == .dark ? 0.15 : 0.1), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                        : RadialGradient(
                            colors: [Color.gray.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: isUnlocked ? icon : "lock.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(isUnlocked ? color : .secondary.opacity(0.5))
            }
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isUnlocked ? .primary : .secondary)
        }
        .frame(width: 120)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(white: 0.12) : .white)
                .shadow(color: isUnlocked ? color.opacity(colorScheme == .dark ? 0.4 : 0.2) : .black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 16, y: 8)
        )
        .opacity(isUnlocked ? 1.0 : 0.5)
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
    }
}

struct GlassSettingRow: View {
    let icon: String
    let title: String
    let color: Color
    let colorScheme: ColorScheme
    
    var body: some View {
        Button {} label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(color.opacity(colorScheme == .dark ? 0.25 : 0.15))
                    )
                
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(colorScheme == .dark ? Color(white: 0.12) : .white)
            )
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ProfileView()
        .environmentObject(ProfileManager())
        .environmentObject(StreakManager())
        .environmentObject(LevelSystem())
        .environmentObject(SessionManager())
}
