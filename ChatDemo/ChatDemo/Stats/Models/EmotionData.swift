internal import SwiftUI

struct EmotionData: Identifiable, Equatable {
    let id = UUID()
    let dateString: String
    let percentage: Int
    let emotion: Emotion
}
