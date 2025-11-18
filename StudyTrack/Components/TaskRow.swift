//
//  TaskRow.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI

struct TaskRow: View {
    var task: StudyTask
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .fontWeight(.medium)
                Text(task.subject)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView(value: task.progress)
                    .tint(.blue)
            }
            Spacer()
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(task.isCompleted ? .green : .gray)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}
