import Combine
import Foundation
internal import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel

    init() {
        let manager = StatsManager()
        _viewModel = StateObject(wrappedValue: StatsViewModel(manager: manager))
    }

    var body: some View {
        let stats = viewModel.stats
        ScrollView {
            VStack(spacing: 20) {
                HeaderView(headerData: stats.headerData)
                MostUsedDataView(mostUsedData: stats.mostUsedData)
                EmotionChartView(
                    title: "My emotional changes",
                    emotionDatas: stats.emotionDatas
                )
                EmotionChartView(
                    title: "Friend's emotional changes",
                    emotionDatas: stats.emotionDatas
                )
                ConversationTopicView(topicDatas: stats.topicDatas)
                ConversationTipView(conversationTipData: stats.conversationTipData)
            }
            .padding()
        }
    }
}
