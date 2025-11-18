//
//  TaskStore.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI
import Foundation

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var pendingTasksCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    init() {
        loadTasks()
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        } else {
            tasks = [
                Task(title: "Revisar assunto", subject: "Matemática", color: .blue, priority: .high),
                Task(title: "Fazer resumo", subject: "Computabilidade", color: .purple, priority: .medium)
            ]
        }
    }
}

// MARK: - Task Model
struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var subject: String
    var isCompleted: Bool
    var dueDate: Date?
    var priority: TaskPriority
    var createdAt: Date
    var colorHex: String
    
    init(
        id: UUID = UUID(),
        title: String,
        subject: String,
        isCompleted: Bool = false,
        color: Color = .blue,
        dueDate: Date? = nil, 
        priority: TaskPriority = .medium
    ) {
        self.id = id
        self.title = title
        self.subject = subject
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.createdAt = Date()
        self.colorHex = color.toHex() ?? "#007AFF"
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
}

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Baixa"
    case medium = "Média"
    case high = "Alta"
}

// MARK: - Color Extensions
extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}
