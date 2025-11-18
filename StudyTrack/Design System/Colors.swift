//
//  DesignSystem.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 18/10/25.
//

import SwiftUI

struct AppColors {
    // MARK: - Primary Colors
    static let primary = Color(hex: "2D5F3F")
    static let primaryLight = Color(hex: "4A9B5E")
    static let primaryDark = Color(hex: "1A3D28")
    
    // MARK: - Secondary Colors
    static let secondary = Color(hex: "4A90E2")
    static let secondaryLight = Color(hex: "6BA8F0")
    static let secondaryDark = Color(hex: "3A7BC8")
    
    // MARK: - Accent Colors
    static let accent = Color(hex: "FF8C42")
    static let accentLight = Color(hex: "FFA666")
    static let accentDark = Color(hex: "E67A3A")
    
    // MARK: - Timer/Focus Colors
    static let timerInactiveDark = Color(hex: "#4A5568")
    static let timerInactiveMedium = Color(hex: "#2D3748")
    static let timerInactiveLight = Color(hex: "#1A202C")
    static let focusPurple = Color(hex: "667eea")
    static let focusPurpleDark = Color(hex: "764ba2")
    static let focusPink = Color(hex: "f093fb")
    static let focusRed = Color(hex: "f5576c")
    static let focusYellow = Color(hex: "ffd76d")
    
    // MARK: - Gamification Colors
    static let levelPurple = Color(hex: "8B5CF6")
    static let levelPink = Color(hex: "EC4899")
    static let xpGold = Color(hex: "F59E0B")
    
    // MARK: - Streak Colors
    static let streakOrange = Color(hex: "FF6B35")
    static let streakRed = Color(hex: "EF4444")
    static let streakYellow = Color(hex: "FBBF24")
    
    // MARK: - Status Colors
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9500")
    static let error = Color(hex: "FF3B30")
    static let info = Color(hex: "007AFF")
    
    // MARK: - Background Colors
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let darkBackground = Color(hex: "0A0E27")
    
    // MARK: - Neutral Colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let border = Color.gray.opacity(0.2)
}

// MARK: - Gradients
extension AppColors {
    static let primaryGradient = LinearGradient(
        colors: [primaryLight, primary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [secondaryLight, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let timerGradient = LinearGradient(
        colors: [focusPurple, focusPurpleDark, focusPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let timerActiveGradient = LinearGradient(
        colors: [focusPink, focusRed, focusYellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let timerInactiveGradient = LinearGradient(
        colors: [
            Color(hex: "#4A5568"),
            Color(hex: "#2D3748"),
            Color(hex: "#1A202C")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let levelGradient = LinearGradient(
        colors: [levelPurple, levelPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let xpGradient = LinearGradient(
        colors: [xpGold, accent],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let streakGradient = LinearGradient(
        colors: [streakOrange, streakRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [success, Color(hex: "10B981")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.3),
            Color.white.opacity(0.1),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
