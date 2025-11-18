//
//  Extensions.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 19/10/25.
//

import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .background(AppColors.cardBackground)
            .cornerRadius(AppCornerRadius.large)
            .shadow(
                color: AppShadow.medium.color,
                radius: AppShadow.medium.radius,
                x: AppShadow.medium.x,
                y: AppShadow.medium.y
            )
    }
    
    func glassMorphism() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(AppCornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    func primaryButton() -> some View {
        self
            .font(AppTypography.bodyBold)
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.primaryGradient)
            .cornerRadius(AppCornerRadius.medium)
            .shadow(
                color: AppShadow.medium.color,
                radius: AppShadow.medium.radius,
                x: AppShadow.medium.x,
                y: AppShadow.medium.y
            )
    }
    
    func secondaryButton() -> some View {
        self
            .font(AppTypography.bodyBold)
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.secondaryGradient)
            .cornerRadius(AppCornerRadius.medium)
            .shadow(
                color: AppShadow.medium.color,
                radius: AppShadow.medium.radius,
                x: AppShadow.medium.x,
                y: AppShadow.medium.y
            )
    }
    
    func timerButton() -> some View {
        self
            .font(AppTypography.title3)
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.lg)
            .background(AppColors.timerActiveGradient)
            .cornerRadius(AppCornerRadius.xlarge)
            .shadow(
                color: AppShadow.large.color,
                radius: AppShadow.large.radius,
                x: AppShadow.large.x,
                y: AppShadow.large.y
            )
    }
    
    func badge(color: Color = AppColors.primary) -> some View {
        self
            .font(AppTypography.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(color)
            .cornerRadius(AppCornerRadius.small)
    }
    
    func floatingCard() -> some View {
        self
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
            .cornerRadius(AppCornerRadius.xlarge)
            .shadow(
                color: AppShadow.large.color,
                radius: AppShadow.large.radius,
                x: AppShadow.large.x,
                y: AppShadow.large.y
            )
    }
    
    func sectionTitle() -> some View {
        self
            .font(AppTypography.title2)
            .foregroundStyle(.primary)
    }
    
    func subtitleText() -> some View {
        self
            .font(AppTypography.callout) 
            .foregroundStyle(.secondary)
    }
}
