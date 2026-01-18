import SwiftUI

struct TaskCardView: View {
    let todo: TodoItem
    let onToggleDone: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onToggleDone) {
            HStack(spacing: 12) {
               
                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(todo.isDone ? .green : .gray)
                    .scaleEffect(todo.isDone ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: todo.isDone)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(todo.title)
                        .font(.headline)
                        .strikethrough(todo.isDone)
                        .foregroundStyle(todo.isDone ? .secondary : .primary)
                    
                    
                    HStack(spacing: 6) {
                        Image(systemName: todo.priority.iconName)
                            .font(.caption)
                            .foregroundStyle(priorityColor)
                        Text(todo.priority.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
               
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(todo.isDone ? Color.green.opacity(0.05) : .ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(radius: todo.isDone ? 2 : 4, y: 2)
            .scaleEffect(todo.isDone ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: todo.isDone)
        }
        .buttonStyle(.plain)
        
        .contextMenu {
            
            Button {
                onToggleDone()
            } label: {
                Label(
                    todo.isDone ? "Mark as Incomplete" : "Mark as Complete", 
                    systemImage: todo.isDone ? "circle" : "checkmark.circle"
                )
            }
            
            
            Divider()
            
           
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        
        .help("Press and hold for more options")
    }
    
    
    private var priorityColor: Color {
        switch todo.priority {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}
