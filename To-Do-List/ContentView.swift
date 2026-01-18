import SwiftUI

struct ContentView: View {
    @State private var todos: [TodoItem] = [
        TodoItem(title: "Buy milk", isDone: false, priority: .medium),
        TodoItem(title: "Finish lab", isDone: true, priority: .high),
        TodoItem(title: "Workout", isDone: false, priority: .low)
    ]
    @State private var isShowingAddSheet = false
    @State private var filter: TodoFilter = .all
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Tasks")
                        .font(.largeTitle.bold())
                    Text("Active: \(activeCount) of \(todos.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
                
               
                Picker("Filter", selection: $filter) {
                    ForEach(TodoFilter.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                
                List {
                    ForEach(todos.indices, id: \.self) { i in
                        if shouldShow(todos[i]) {
                            TaskCardView(
                                todo: todos[i],
                                onToggleDone: {
                                    
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        todos[i].isDone.toggle()
                                    }
                                },
                                onDelete: {
                                    
                                    withAnimation {
                                        deleteTask(at: i)
                                    }
                                }
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                            
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        deleteTask(at: i)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        todos[i].isDone.toggle()
                                    }
                                } label: {
                                    Label(todos[i].isDone ? "Undo" : "Complete", 
                                          systemImage: todos[i].isDone ? "arrow.uturn.backward" : "checkmark")
                                }
                                .tint(todos[i].isDone ? .gray : .green)
                            }
                        }
                    }
                    
                    .onDelete { indexSet in
                        withAnimation {
                            todos.remove(atOffsets: indexSet)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("To-do List")
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Add sample") {
                        withAnimation {
                            todos.append(TodoItem(
                                title: "Task \(todos.count + 1)", 
                                isDone: false, 
                                priority: .medium
                            ))
                        }
                    }
                }
               
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        isShowingAddSheet = true
                    }
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
    
    
    private func deleteTask(at index: Int) {
        guard index < todos.count else { return }
        todos.remove(at: index)
    }
    
    
    private var activeCount: Int {
        todos.filter { !$0.isDone }.count
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

#Preview {
    ContentView()
}
