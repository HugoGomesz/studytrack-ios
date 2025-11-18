//
//  EmptyStateView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 18/10/25.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(AppColors.primary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(AppTypography.title2)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(AppColors.primaryGradient)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(40)
    }
}
