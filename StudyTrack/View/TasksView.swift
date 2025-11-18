//
//  TasksView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI

struct TasksView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var showAddTask = false
    @State private var taskToEdit: Task?
    @State private var searchText = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var showDeleteAlert = false
    @State private var taskToDelete: Task?
    
    var filteredTasks: [Task] {
        let filtered = taskStore.tasks.filter { task in
            if searchText.isEmpty {
                return true
            }
            return task.title.lowercased().contains(searchText.lowercased()) ||
                   task.subject.lowercased().contains(searchText.lowercased())
        }
        
        switch selectedFilter {
        case .all: return filtered
        case .pending: return filtered.filter { !$0.isCompleted }
        case .completed: return filtered.filter { $0.isCompleted }
        }
    }
    
    var completionRate: Double {
        guard !taskStore.tasks.isEmpty else { return 0 }
        let completed = taskStore.tasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(taskStore.tasks.count)
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    taskHeader
                    searchBar
                    filterTabs
                    
                    if filteredTasks.isEmpty {
                        emptyState
                    } else {
                        tasksList
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet()
                .environmentObject(taskStore)
        }
        .sheet(item: $taskToEdit) { task in
            EditTaskSheet(task: task)
                .environmentObject(taskStore)
        }
        .alert("Deletar Tarefa", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Deletar", role: .destructive) {
                if let task = taskToDelete {
                    withAnimation(.easeOut(duration: 0.2)) {
                        taskStore.deleteTask(task)
                    }
                }
            }
        } message: {
            Text("Tem certeza que deseja deletar esta tarefa?")
        }
    }
    
    private var taskHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tarefas")
                        .font(AppTypography.largeTitle)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(taskStore.pendingTasksCount) pendentes")
                            .font(AppTypography.footnote)
                            .foregroundStyle(.secondary)
                        
                        Text("\(taskStore.completedTasksCount) concluídas")
                            .font(AppTypography.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button {
                    showAddTask = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.primaryLight, AppColors.primary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: AppColors.primary.opacity(0.4), radius: 15, y: 8)
                        )
                }
                .buttonStyle(.plain)
            }
            
            ProgressBarView(progress: completionRate)
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Buscar tarefas...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColors.cardBackground)
        )
    }
    
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        count: filter.count(from: taskStore.tasks)
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }
    
    private var tasksList: some View {
        VStack(spacing: 12) {
            ForEach(filteredTasks) { task in
                TaskCardWithSwipe(
                    task: task,
                    onToggle: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            taskStore.toggleTask(task)
                        }
                    },
                    onEdit: {
                        taskToEdit = task
                    },
                    onDelete: {
                        taskToDelete = task
                        showDeleteAlert = true
                    }
                )
                .id(task.id)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary.opacity(0.5))
                .padding(.top, 60)
            
            Text("Nenhuma tarefa")
                .font(AppTypography.title2)
            
            Text("Toque no + para adicionar")
                .font(AppTypography.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct ProgressBarView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Progresso Geral")
                    .font(AppTypography.callout)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primary)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.primaryGradient)
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(x: progress, y: 1, anchor: .leading)
                    .animation(.easeOut(duration: 0.3), value: progress)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
}

struct FilterButton: View {
    let filter: TaskFilter
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var filterColor: Color {
        switch filter {
        case .all:
            return AppColors.primary
        case .pending:
            return .orange
        case .completed:
            return .blue
        }
    }
    
    var filterGradient: LinearGradient {
        LinearGradient(
            colors: [filterColor.opacity(0.8), filterColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(filter.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .lineLimit(1)
                
                Text("\(count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                    )
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? filterGradient : LinearGradient(colors: [AppColors.cardBackground], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: isSelected ? filterColor.opacity(0.3) : .clear, radius: 10, y: 5)
            )
        }
        .buttonStyle(.plain)
        .fixedSize()
    }
}

struct TaskCardWithSwipe: View {
    let task: Task
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = 0
                    }
                    onEdit()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Editar")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 75)
                    .frame(maxHeight: .infinity)
                    .background(Color.blue)
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = 0
                    }
                    onDelete()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Deletar")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 75)
                    .frame(maxHeight: .infinity)
                    .background(Color.red)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            cardContent
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = max(value.translation.width, -150)
                            } else if offset < 0 {
                                offset = min(0, offset + value.translation.width)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if value.translation.width < -75 {
                                    offset = -150
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .onTapGesture {
            if offset != 0 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    offset = 0
                }
            }
        }
    }
    
    private var cardContent: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(task.isCompleted ? Color.clear : task.color.opacity(0.5), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if task.isCompleted {
                        Circle()
                            .fill(AppColors.success)
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold))
                    .strikethrough(task.isCompleted, color: .secondary)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(task.color)
                        .frame(width: 6, height: 6)
                    
                    Text(task.subject)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    if let dueDate = task.dueDate {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(dueDate, style: .date)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if task.priority == .high {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.title3)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
}


enum TaskFilter: CaseIterable {
    case all, pending, completed
    
    var title: String {
        switch self {
        case .all: return "Todas"
        case .pending: return "Pendentes"
        case .completed: return "Concluídas"
        }
    }
    
    func count(from tasks: [Task]) -> Int {
        switch self {
        case .all: return tasks.count
        case .pending: return tasks.filter { !$0.isCompleted }.count
        case .completed: return tasks.filter { $0.isCompleted }.count
        }
    }
}

struct AddTaskSheet: View {
    @EnvironmentObject var taskStore: TaskStore
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var subject = ""
    @State private var selectedColor: Color = .blue
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var priority: TaskPriority = .medium
    
    let colors: [Color] = [.blue, .purple, .green, .orange, .red, .pink]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Detalhes") {
                    TextField("Título da tarefa", text: $title)
                    TextField("Matéria", text: $subject)
                }
                
                Section("Cor") {
                    HStack(spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                
                Section("Prioridade") {
                    Picker("Prioridade", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Toggle("Adicionar data de vencimento", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Data", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Nova Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        addTask()
                    }
                    .disabled(title.isEmpty || subject.isEmpty)
                }
            }
        }
    }
    
    func addTask() {
        let newTask = Task(
            title: title,
            subject: subject,
            isCompleted: false,
            color: selectedColor,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority
        )
        taskStore.addTask(newTask)
        dismiss()
    }
}

struct EditTaskSheet: View {
    @EnvironmentObject var taskStore: TaskStore
    @Environment(\.dismiss) var dismiss
    
    let task: Task
    
    @State private var title = ""
    @State private var subject = ""
    @State private var selectedColor: Color = .blue
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var priority: TaskPriority = .medium
    
    let colors: [Color] = [.blue, .purple, .green, .orange, .red, .pink]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Detalhes") {
                    TextField("Título da tarefa", text: $title)
                    TextField("Matéria", text: $subject)
                }
                
                Section("Cor") {
                    HStack(spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                
                Section("Prioridade") {
                    Picker("Prioridade", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Toggle("Adicionar data de vencimento", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Data", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Editar Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        saveTask()
                    }
                    .disabled(title.isEmpty || subject.isEmpty)
                }
            }
            .onAppear {
                loadTaskData()
            }
        }
    }
    
    func loadTaskData() {
        title = task.title
        subject = task.subject
        selectedColor = task.color
        priority = task.priority
        
        if let taskDueDate = task.dueDate {
            hasDueDate = true
            dueDate = taskDueDate
        } else {
            hasDueDate = false
            dueDate = Date()
        }
    }
    
    func saveTask() {
        let updatedTask = Task(
            id: task.id,
            title: title,
            subject: subject,
            isCompleted: task.isCompleted,
            color: selectedColor,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority
        )
        taskStore.updateTask(updatedTask)
        dismiss()
    }
}

#Preview {
    TasksView()
        .environmentObject(TaskStore())
}
