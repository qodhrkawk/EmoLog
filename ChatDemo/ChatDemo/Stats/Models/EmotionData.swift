internal import SwiftUI

struct EmotionData: Identifiable, Equatable {
    let id = UUID()
    let dateString: String
    let percentage: Int
    let emotion: Emotion
}

extension Emotion {
    func color() -> Color {
        switch self {
        case .happy:
            return .yellow
        case .sad:
            return .blue
        case .angry:
            return .red
        case .fear:
            return .purple
        case .surprise:
            return .orange
        case .love:
            return .pink
        }
    }
}
