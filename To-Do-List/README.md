import SwiftUI

enum TodoPriority: Int, CaseIterable, Identifiable {
    case low, medium, high

    var id: Int { rawValue }

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var icon: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "arrow.right"
        case .high: return "arrow.up"
        }
    }
}

enum TodoFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    var id: String { rawValue }

    func shouldShow(_ item: TodoItem) -> Bool {
        switch self {
        case .all:
            return true
        case .active:
            return !item.isDone
        case .completed:
            return item.isDone
        }
    }
}

struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool = false
    var priority: TodoPriority = .medium
}

struct ContentView: View {
    @State private var todos: [TodoItem] = [
        TodoItem(title: "Buy groceries", isDone: false, priority: .medium),
        TodoItem(title: "Finish SwiftUI tutorial", isDone: true, priority: .high),
        TodoItem(title: "Call Mom", isDone: false, priority: .low),
    ]

    @State private var filter: TodoFilter = .all
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                headerCard

                Picker("Filter", selection: $filter) {
                    ForEach(TodoFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if filteredTodos.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 64, weight: .light))
                            .foregroundStyle(.secondary)
                        Text("No tasks")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Button {
                            showingAddSheet = true
                        } label: {
                            Label("Add Task", systemImage: "plus.circle.fill")
                                .font(.title3.weight(.semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.accentColor)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTodos) { todo in
                            if let idx = todos.firstIndex(where: { $0.id == todo.id }) {
                                TaskRowView(todo: $todos[idx])
                            }
                        }
                        .onDelete(perform: deleteTodos)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My To‑Dos")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Menu {
                        Button("Add Sample Task") {
                            addSampleTask()
                        }
                        Button("Clear Completed") {
                            clearCompleted()
                        }
                        Button("Mark All Done") {
                            markAllDone()
                        }
                    } label: {
                        Label("More actions", systemImage: "ellipsis.circle")
                    }

                    Spacer()

                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTodoSheetView { title, priority in
                    addTodo(title: title, priority: priority)
                    showingAddSheet = false
                }
            }
        }
    }

    var filteredTodos: [TodoItem] {
        todos.filter { filter.shouldShow($0) }
    }

    var completedCount: Int {
        todos.filter { $0.isDone }.count
    }

    var activeCount: Int {
        todos.count - completedCount
    }

    var progress: Double {
        guard !todos.isEmpty else { return 0 }
        return Double(completedCount) / Double(todos.count)
    }

    var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.accentColor.opacity(0.2))
                )
                .shadow(radius: 3)

            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("To‑Do Progress")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.primary.opacity(0.8))
                        Text("\(completedCount) done • \(activeCount) active")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.accentColor)
                        .monospacedDigit()
                }

                ProgressView(value: progress)
                    .tint(.accentColor)
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .animation(.spring(), value: progress)
            }
            .padding(20)
        }
        .padding(.horizontal)
        .frame(height: 120)
    }

    func addTodo(title: String, priority: TodoPriority) {
        withAnimation(.spring()) {
            let newTodo = TodoItem(title: title, isDone: false, priority: priority)
            todos.append(newTodo)
        }
    }

    func addSampleTask() {
        withAnimation(.spring()) {
            todos.append(TodoItem(title: "Sample Task \(todos.count + 1)", isDone: false, priority: .medium))
        }
    }

    func clearCompleted() {
        withAnimation(.spring()) {
            todos.removeAll(where: { $0.isDone })
        }
    }

    func markAllDone() {
        withAnimation(.spring()) {
            for idx in todos.indices {
                todos[idx].isDone = true
            }
        }
    }

    func deleteTodos(at offsets: IndexSet) {
        withAnimation(.spring()) {
            let toDelete = offsets.map { filteredTodos[$0].id }
            todos.removeAll { toDelete.contains($0.id) }
        }
    }
}

struct TaskRowView: View {
    @Binding var todo: TodoItem

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring()) {
                    todo.isDone.toggle()
                }
            } label: {
                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isDone ? .accentColor : .secondary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading) {
                Text(todo.title)
                    .font(.body.weight(.medium))
                    .strikethrough(todo.isDone, color: .secondary)
                    .foregroundColor(todo.isDone ? .secondary : .primary)
                HStack(spacing: 6) {
                    Image(systemName: todo.priority.icon)
                        .font(.caption)
                        .foregroundColor(todo.priority.color)
                    Text(todo.priority.label)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(todo.priority.color)
                }
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .swipeActions(edge: .leading) {
            Button {
                withAnimation(.spring()) {
                    todo.isDone.toggle()
                }
            } label: {
                Label(todo.isDone ? "Undo" : "Complete", systemImage: todo.isDone ? "arrow.uturn.left.circle" : "checkmark.circle")
            }
            .tint(todo.isDone ? .gray : .green)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                withAnimation(.spring()) {
                    // The delete will be handled in the list onDelete, so we do nothing here
                    // or we can send a notification to parent
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddTodoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var priority: TodoPriority = .medium

    var onAdd: (String, TodoPriority) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.sentences)
                }
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TodoPriority.allCases) { priority in
                            Label(priority.label, systemImage: priority.icon)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Add To‑Do")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(title, priority)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
