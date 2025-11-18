//
//  AchievementCard.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI

struct AchievementCard: View {
    var title: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.title)
                .foregroundColor(.yellow)
                .padding(12)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 8)
        }
        .frame(width: 120, height: 120)
        .background(
            LinearGradient(
                colors: [Color.cyan.opacity(0.6), Color.blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
    }
}
