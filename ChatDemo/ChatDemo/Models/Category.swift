import FoundationModels

@Generable(description: "Conversation's main category")
struct ConversationCategory {
    @Guide(description: "The identified category")
    let category: Category
    @Guide(
        description: """
        The percentage of confidence score from 10 to 100.
        Use the full range as needed: low scores (10~40) indicate weak signals, mid scores (41~70) are moderate, and high scores (71~100) are strong.
        """,
        .range(10...100)
    )
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

extension Category {
    var imageName: String {
        "category_\(rawValue)"
    }
}
