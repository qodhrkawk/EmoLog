import Combine
import Foundation
internal import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel

    init(viewModel: StatsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            if let stats = viewModel.stats {
                VStack(spacing: 20) {
                    HeaderView(headerData: stats.headerData)
                    MostUsedDataView(mostUsedData: stats.mostUsedData)

                    if let myEmotions = stats.myEmotionDatas, !myEmotions.isEmpty {
                        EmotionChartView(
                            title: "My emotional changes",
                            emotionDatas: myEmotions
                        )
                    }

                    if let friendEmotions = stats.friendEmotionDatas, !friendEmotions.isEmpty {
                        EmotionChartView(
                            title: "Friend's emotional changes",
                            emotionDatas: friendEmotions
                        )
                    }

                    if let topicDatas = stats.topicDatas, !topicDatas.isEmpty {
                        ConversationTopicView(topicDatas: topicDatas)
                    }

                    if let tip = stats.conversationTipData {
                        ConversationTipView(conversationTipData: tip)
                    }
                }
                .padding()
            } else {
                VStack(spacing: 16) {
                    ProgressView("데이터를 분석 중입니다...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Button("다시 시도하기") {
                        viewModel.makeReportPerDay()
                    }
                }
                .padding(.top, 80)
            }
        }
        .onAppear {
            if viewModel.stats == nil {
                viewModel.makeReportPerDay()
            }
        }
    }
}
