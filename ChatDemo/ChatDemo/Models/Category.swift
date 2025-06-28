import FoundationModels

@Generable(description: "Conversation's main category")
struct ConversationCategory {
    @Guide(description: "The identified category")
    let category: Category
    @Guide(description: "Confidence score from 0 to 100", .range(0...100))
    let confidence: Int
}

@Generable(description: "A category of conversation.")
enum Category: String {
    case work
    case food
    case study
    case hobby
    case health
    case trip
    case event
    case shopping
    case love
    case money
    case employment
    case daily
}

