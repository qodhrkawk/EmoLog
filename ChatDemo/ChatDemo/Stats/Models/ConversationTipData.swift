struct ConversationTipData {
    let mainTip: ConversationTip
    let additionalTips: [ConversationTip]
}

struct ConversationTip {
    let title: String
    let description: String
    let icon: String
}
