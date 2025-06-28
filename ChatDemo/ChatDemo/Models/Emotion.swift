import FoundationModels

@Generable
struct UserEmotion {
    @Guide(description: "The name of user")
    let name: String
    @Guide(description: "The emotion of user")
    let emotion: Emotion
}

@Generable
enum Emotion: String {
    case joy
    case happy
    case sad
    case frustrated
    case angry
    case anticipation
    case surprise
    case trust
    case fear
}
