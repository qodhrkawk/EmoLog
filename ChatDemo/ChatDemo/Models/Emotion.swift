import FoundationModels
internal import SwiftUI

@Generable(description: "User name and emotion")
struct UserEmotion {
    @Guide(description: "The name of user")
    let name: String
    
    @Guide(description: "EmotionWithConfidence value", .count(3))
    let emotionWithScoreList: [EmotionWithScore]
}

@Generable(description: "Emotion with scores. The sum of all values should be 100.")
struct EmotionWithScore {
    @Guide(description: "The emtion for user")
    let emotion: Emotion
    @Guide(description: "The score for emotion", .range(10...100))
    let score: Int
}
//
//@Generable(description: "Emotion with scores. The sum of all values should be 100.")
//struct EmotionWithScore {
//    @Guide(description: "The score for happy", .range(0...100))
//    let happy: Int
//    @Guide(description: "The score for sad", .range(0...100))
//    let sad: Int
//    @Guide(description: "The score for angry", .range(0...100))
//    let angry: Int
//    @Guide(description: "The score for fear", .range(0...100))
//    let fear: Int
//    @Guide(description: "The score for surprise", .range(0...100))
//    let surprise: Int
//    @Guide(description: "The score for love", .range(0...100))
//    let love: Int
//}

@Generable(description: "An user's emotion from the conversation")
enum Emotion: String {
    case happy
    case sad
    case angry
    case fear
    case surprise
    case love
}

extension Emotion {
    var color: Color {
        switch self {
        case .happy:
            return Color(hex: "B0EDC4")!
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
