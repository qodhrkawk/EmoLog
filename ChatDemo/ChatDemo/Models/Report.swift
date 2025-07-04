import FoundationModels


@Generable(description: "A report for conversation")
struct DailyReport {
    @Guide(description: "You should include all participants of conversation")
    let userEmotions: [UserEmotion]
    @Guide(description: "Overall category for conversation")
    let category: ConversationCategory
    @Guide(description: "Advice for Me")
    let advice: ConversationAdvice
}

@Generable(description: "An advice for Me, based on conversation. The advice is about the relationship between the user and the other person")
struct ConversationAdvice {
    @Guide(description: "An adivce for user(Me), which is for better relationship with conversation partner.")
    let advice: String
}

@Generable(description: "The most used word and its count")
struct MostUsedWord {
    @Guide(description: """
        The most frequently used word.
        Only include content words like nouns or verbs.
        Do NOT include common stop words such as: the, a, an, is, are, was, were, and, or, to, in, of, etc.
        """)
    let word: String
    @Guide(description: "The count for the most used word")
    let count: Int
    @Guide(description: "The mostly used sticker.")
    let mostUsedSticker: Sticker
}
