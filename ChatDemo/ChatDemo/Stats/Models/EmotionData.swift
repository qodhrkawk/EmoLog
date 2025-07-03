internal import SwiftUI

struct EmotionData: Identifiable, Equatable {
    let id = UUID()
    let dateString: String
    let percentage: Int
    let emotion: Emotion
}

extension Emotion {
    var color: Color {
        switch self {
        case .happy:
            return Color(hex: "C4ACFF")!
        case .sad:
            return Color(hex: "839AFF")!
        case .angry:
            return Color(hex: "FFB17A")!
        case .fear:
            return Color(hex: "FF7D7D")!
        case .surprise:
            return Color(hex: "FFECAF")!
        case .love:
            return Color(hex: "FFCDD1")!
        }
    }
}
