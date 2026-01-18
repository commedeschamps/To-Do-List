import SwiftUI

struct TaskCardView: View {
    let title: String
    let isDone: Bool
    let priority: TaskPriority
    let onToggleDone: () -> Void
    
    var body: some View {
        Button(action: onToggleDone) {
            HStack(spacing: 12) {
                // Анимированный индикатор завершения
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isDone ? .green : .gray)
                    .scaleEffect(isDone ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDone)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .strikethrough(isDone)
                        .foregroundStyle(isDone ? .secondary : .primary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: priority.iconName)
                            .font(.caption)
                            .foregroundStyle(priorityColor)
                        Text(priority.rawValue)
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
            .background(isDone ? Color.green.opacity(0.05) : .ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(radius: isDone ? 2 : 4, y: 2)
            .scaleEffect(isDone ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isDone)
        }
        .buttonStyle(.plain)
    }
    
    private var priorityColor: Color {
        switch priority {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}
