//
//  TaskCard.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI

struct TaskCard: View {
    var task: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
            Spacer()
            HStack {
                Image(systemName: "circle")
                    .foregroundColor(.blue)
                Text("Pendente")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 180, height: 100)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}
