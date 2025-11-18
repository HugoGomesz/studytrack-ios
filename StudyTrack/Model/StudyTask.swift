//
//  StudyTask.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import Foundation

struct StudyTask: Identifiable {
    let id = UUID()
    var title: String
    var subject: String
    var progress: Double
    var isCompleted: Bool
}
