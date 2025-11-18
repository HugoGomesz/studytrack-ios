//
//  ProgressCard.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI

import SwiftUI

struct ProgressCard: View {
    var title: String
    var value: Double
    var color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(value))" : String(format: "%.1f", value))
                .font(.title2.bold())
                .foregroundColor(color)
            ProgressView(value: value / 10)
                .tint(color)
        }
        .frame(width: 100, height: 100)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}
