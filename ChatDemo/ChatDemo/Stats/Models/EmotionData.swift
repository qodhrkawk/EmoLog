import SwiftUI

struct EmotionData {
    let id = UUID()
    let dateString: String
    let percentage: Int
    let emotion: Emotion
}

enum Emotion: String {
    case joy, sadness, anger, fear, surprise, love

    func color() -> Color {
        switch self {
        case .joy:
            return .yellow
        case .sadness:
            return .blue
        case .anger:
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
