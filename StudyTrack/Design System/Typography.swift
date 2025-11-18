//
//  Typography.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 19/10/25.
//

import SwiftUI

struct AppTypography {
    // Display
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    // Headings
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    // Body
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyBold = Font.system(size: 17, weight: .semibold)
    // Secondary
    static let callout = Font.system(size: 16, weight: .regular)
    static let footnote = Font.system(size: 13, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
}
