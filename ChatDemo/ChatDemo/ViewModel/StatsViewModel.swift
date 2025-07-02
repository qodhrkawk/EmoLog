import Combine
internal import SwiftUI

class StatsViewModel: ObservableObject {
    @Published var stats: Stats

    private let manager: StatsManager

    init(manager: StatsManager) {
        self.manager = manager
        self.stats = manager.fetchStats()
    }
}

struct Stats {
    let headerData: HeaderData
    let mostUsedData: MostUsedData
    let emotionDatas: [EmotionData]
    let topicDatas: [TopicData]
    let conversationTipData: ConversationTipData
}
