import SwiftUI

struct TaskCardView: View {
    let title: String
    let isDone: Bool
    let priority: TaskPriority
    let onToggleDone: () -> Void

    var body: some View {
        Button(action: onToggleDone) {
            HStack(spacing: 12) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .strikethrough(isDone)
                        .foregroundStyle(isDone ? .secondary : .primary)

                    HStack(spacing: 6) {
                        Image(systemName: priority.iconName)
                            .font(.caption)
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
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}
