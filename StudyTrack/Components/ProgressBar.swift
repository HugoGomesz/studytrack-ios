//
//  ProgressBar.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI

struct ProgressBar: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.gradient)
                    .frame(width: geo.size.width * progress)
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: 14)
    }
}
