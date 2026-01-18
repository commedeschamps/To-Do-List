import SwiftUI

struct ContentView: View {
    @State private var todos: [TodoItem] = [
        TodoItem(title: "Buy milk", isDone: false),
        TodoItem(title: "Finish lab", isDone: true),
        TodoItem(title: "Workout", isDone: false)
    ]
    @State private var isShowingAddSheet = false
    @State private var filter: TodoFilter = .all

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Changing this @State updates the list automatically
                Picker("Filter", selection: $filter) {
                    ForEach(TodoFilter.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // This text updates automatically when todos/filter changes
                Text("Total: \(todos.count) | Showing: \(shownCount)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                List {
                    ForEach(todos.indices, id: \.self) { i in
                        if shouldShow(todos[i]) {
                            HStack {
                                Text(todos[i].title)
                                Spacer()
                                Toggle("", isOn: $todos[i].isDone)
                                    .labelsHidden()
                            }
                        }
                    }
                    .onDelete { indexSet in
                        todos.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("To-Do")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Add sample") {
                        todos.append(TodoItem(title: "Task \(todos.count + 1)", isDone: false))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        isShowingAddSheet = true
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddTodoSheetView { title in
                    todos.append(TodoItem(title: title, isDone: false))
                }
            }
        }
    }

    private var shownCount: Int {
        todos.filter { shouldShow($0) }.count
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


struct AddTodoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""

    let onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onAdd(trimmed)
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
