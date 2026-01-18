import Foundation

struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
    var priority: TaskPriority = .medium
    var createdAt: Date = Date()
}
