import SwiftUI

struct ContentView: View {
    @State private var todos: [TodoItem] = [
        TodoItem(title: "Buy milk", isDone: false, priority: .medium),
        TodoItem(title: "Finish lab", isDone: true, priority: .high),
        TodoItem(title: "Workout", isDone: false, priority: .low)
    ]
    @State private var isShowingAddSheet = false
    @State private var filter: TodoFilter = .all

    private var completedCount: Int {
        todos.filter { $0.isDone }.count
    }

    private var activeCount: Int {
        todos.filter { !$0.isDone }.count
    }

    private var progress: Double {
        guard !todos.isEmpty else { return 0 }
        return Double(completedCount) / Double(todos.count)
    }

    private var visibleIndices: [Int] {
        todos.indices.filter { shouldShow(todos[$0]) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Header card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.tint.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "checklist")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.tint)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("My Tasks")
                                .font(.title.bold())
                            Text("Active: \(activeCount) • Done: \(completedCount)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(Int(progress * 100))%")
                                .font(.subheadline.weight(.semibold))
                            Text("\(completedCount)/\(todos.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ProgressView(value: progress)
                        .tint(.accentColor)
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 4)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal)

                // Filter
                Picker("Filter", selection: $filter) {
                    ForEach(TodoFilter.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Content
                if filteredTodos.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(.tertiary)
                        Text("No tasks to show")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Add a new task with the + button")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)

                        Button {
                            isShowingAddSheet = true
                        } label: {
                            Label("Add Task", systemImage: "plus")
                                .font(.subheadline.weight(.semibold))
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                        .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    List {
                        ForEach(visibleIndices, id: \.self) { index in
                            let item = todos[index]

                            TaskRowView(todo: item) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    todos[index].isDone.toggle()
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        deleteTask(at: index)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        todos[index].isDone.toggle()
                                    }
                                } label: {
                                    Label(item.isDone ? "Undo" : "Complete",
                                          systemImage: item.isDone ? "arrow.uturn.backward" : "checkmark")
                                }
                                .tint(item.isDone ? .gray : .green)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("To-do List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            withAnimation {
                                todos.append(TodoItem(
                                    title: "Task \(todos.count + 1)",
                                    isDone: false,
                                    priority: .medium
                                ))
                            }
                        } label: {
                            Label("Add sample", systemImage: "sparkles")
                        }

                        Button {
                            withAnimation {
                                todos.removeAll(where: { $0.isDone })
                            }
                        } label: {
                            Label("Clear completed", systemImage: "trash.slash")
                        }

                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                for i in todos.indices {
                                    todos[i].isDone = true
                                }
                            }
                        } label: {
                            Label("Mark all done", systemImage: "checkmark.circle")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        isShowingAddSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddTodoSheetView { title, priority in
                    withAnimation {
                        todos.append(TodoItem(
                            title: title,
                            isDone: false,
                            priority: priority
                        ))
                    }
                }
            }
        }
    }

    private var filteredTodos: [TodoItem] {
        todos.filter { shouldShow($0) }
    }

    private func deleteTask(at index: Int) {
        guard index < todos.count else { return }
        todos.remove(at: index)
    }

    private func shouldShow(_ item: TodoItem) -> Bool {
        switch filter {
        case .all:
            return true
        case .active:
            return !item.isDone
        case .completed:
            return item.isDone
        }
    }
}

private struct TaskRowView: View {
    let todo: TodoItem
    let onToggleDone: () -> Void

    private var statusIcon: some View {
        ZStack {
            Circle()
                .strokeBorder(.secondary.opacity(todo.isDone ? 0 : 0.35), lineWidth: 2)

            if todo.isDone {
                Circle()
                    .fill(.green.opacity(0.18))

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.green)
            }
        }
        .frame(width: 28, height: 28)
    }

    private var priorityUI: (icon: String, text: String, color: Color) {
        switch todo.priority {
        case .low:
            return ("arrow.down", "Low", .blue)
        case .medium:
            return ("equal", "Medium", .orange)
        case .high:
            return ("exclamationmark.triangle.fill", "High", .red)
        default:
            return ("circle", String(describing: todo.priority), .secondary)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            statusIcon

            VStack(alignment: .leading, spacing: 6) {
                Text(todo.title)
                    .font(.callout.weight(.semibold))
                    .strikethrough(todo.isDone, color: .secondary)
                    .foregroundStyle(todo.isDone ? .secondary : .primary)

                HStack(spacing: 6) {
                    Image(systemName: priorityUI.icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(priorityUI.color)
                    Text(priorityUI.text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.body.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onToggleDone()
        }
    }
}

#Preview {
    ContentView()
}
