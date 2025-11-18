//
//  Spacing.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 19/10/25.
//

import SwiftUI

struct AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

struct AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xlarge: CGFloat = 32
}

struct AppShadow {
    static let small: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
        Color.black.opacity(0.05),
        5,
        0,
        2
    )
    
    static let medium: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
        Color.black.opacity(0.1),
        10,
        0,
        5
    )
    
    static let large: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
        Color.black.opacity(0.15),
        20,
        0,
        10
    )
}
