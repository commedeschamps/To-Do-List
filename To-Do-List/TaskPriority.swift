import Foundation

enum TaskPriority: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "equal"
        case .high: return "exclamationmark.triangle.fill"
        }
    }
}
