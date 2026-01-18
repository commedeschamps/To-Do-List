import SwiftUI

struct TaskCardView: View {
    let todo: TodoItem
    let onToggleDone: () -> Void
    let onDelete: () -> Void

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

    private var priorityColor: Color {
        switch todo.priority {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        default:
            return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            statusIcon

            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.callout.weight(.semibold))
                    .strikethrough(todo.isDone, color: .secondary)
                    .foregroundStyle(todo.isDone ? .secondary : .primary)

                Text(todo.priority.rawValue.capitalized)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(priorityColor)
                    .textCase(.uppercase)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.body.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggleDone()
        }
    }
}

