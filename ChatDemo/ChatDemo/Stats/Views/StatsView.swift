import Combine
import Foundation
internal import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel
    
    let chatViewModel: ChatViewModel
    let onShare: (Stats) -> Void

    init(viewModel: StatsViewModel, chatViewModel: ChatViewModel, onShare: @escaping (Stats) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.chatViewModel = chatViewModel
        self.onShare = onShare
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
                            profileImageName: User.me.imageName ?? "",
                            emotionDatas: myEmotions
                        )
                    }

                    if let friendEmotions = stats.friendEmotionDatas, !friendEmotions.isEmpty {
                        EmotionChartView(
                            title: "Friend's emotional changes",
                            profileImageName: viewModel.partner?.imageName ?? "",
                            emotionDatas: friendEmotions
                        )
                    }

                    if let topicDatas = stats.topicDatas, !topicDatas.isEmpty {
                        ConversationTopicView(topicDatas: topicDatas)
                    }

                    if let tip = stats.conversationTipData {
                        ConversationTipView(conversationTipData: tip)
                    }
                    
                    Button(action: {
                        guard let stats = viewModel.stats else { return }
                        onShare(stats)
                    }) {
                        Text("Share to friend")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
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
        .onChange(of: viewModel.isLoading) { isLoading in
            if isLoading == false {
//                guard let stats = viewModel.stats else { return }
//                chatViewModel.sendReport(stats)
            }
        }
        .onAppear {
            if viewModel.stats == nil {
                viewModel.makeReportPerDay()
            }
        }
    }
}
