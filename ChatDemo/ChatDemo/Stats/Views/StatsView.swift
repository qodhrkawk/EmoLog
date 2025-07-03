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
        if let stats = viewModel.stats, viewModel.isLoading == false {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView(headerData: stats.headerData)
                    MostUsedDataView(mostUsedData: stats.mostUsedData)

                    if let myEmotions = stats.myEmotionDatas, !myEmotions.isEmpty {
                        EmotionChartView(
                            name: User.myName,
                            profileImageName: User.me.imageName ?? "",
                            emotionDatas: myEmotions
                        )
                    }

                    if let friendEmotions = stats.friendEmotionDatas, !friendEmotions.isEmpty {
                        EmotionChartView(
                            name: viewModel.partner?.name ?? "Friend",
                            profileImageName: viewModel.partner?.imageName ?? "",
                            emotionDatas: friendEmotions
                        )
                    }

                    if let topicDatas = stats.topicDatas, !topicDatas.isEmpty {
                        ConversationTopicView(topicDatas: topicDatas)
                    }

                    if let advice = stats.conversationAdviceData {
                        ConversationAdviceView(adviceData: advice)
                    }

                    Button(action: {
                        onShare(stats)
                    }) {
                        HStack(spacing: 0) {
                            Image("shareButton")
                                .resizable()
                                .frame(width: 23, height: 21)
                            Text("Share with Friends")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 112/255, green: 102/255, blue: 240/255))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding()
            }
        } else {
            VStack {
                Spacer()
                LoadingView()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                if viewModel.stats == nil {
                    viewModel.makeReportPerDay()
                }
            }
        }

    }
}
