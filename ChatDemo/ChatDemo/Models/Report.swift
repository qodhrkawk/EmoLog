import FoundationModels

@Generable(description: "A report for conversation")
struct Report {
    @Guide(description: "You should include all participants of conversation")
    let userEmotions: [UserEmotion]
    @Guide(description: "Overall category for conversation")
    let category: ConversationCategory
}
