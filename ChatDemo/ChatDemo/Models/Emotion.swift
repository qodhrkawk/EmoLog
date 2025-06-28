import FoundationModels

@Generable(description: "User name and emotion")
struct UserEmotion {
    @Guide(description: "The name of user")
    let name: String
    @Guide(description: "The emotion of user")
    let emotion: Emotion
    @Guide(description: "The strength of emotion", .range(0...100))
    let confidence: Int
}

@Generable(description: "An user's emotion from the conversation")
enum Emotion: String {
    case happy
    case sad
    case angry
    case fear
    case surprise
    case love
}
