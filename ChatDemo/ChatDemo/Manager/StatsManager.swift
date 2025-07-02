import Foundation
internal import SwiftUI

class StatsManager {
    func fetchStats() -> Stats {
        let headerData = HeaderData(name: "서지연", formattedDateString: "2023년 6월 24일")

        let mostUsedData = MostUsedData(
            word: "좋아해",
            usedCount: 127,
            stickerImageName: "heart.fill"
        )

        let emotionDatas = [
            EmotionData(dateString: "6/18", percentage: 70, emotion: .happy),
            EmotionData(dateString: "6/18", percentage: 30, emotion: .sad),
            EmotionData(dateString: "6/19", percentage: 75, emotion: .angry),
            EmotionData(dateString: "6/20", percentage: 60, emotion: .fear),
            EmotionData(dateString: "6/20", percentage: 20, emotion: .love),
            EmotionData(dateString: "6/21", percentage: 85, emotion: .surprise),
            EmotionData(dateString: "6/21", percentage: 15, emotion: .love),
            EmotionData(dateString: "6/22", percentage: 90, emotion: .angry),
            EmotionData(dateString: "6/23", percentage: 75, emotion: .happy),
            EmotionData(dateString: "6/24", percentage: 80, emotion: .happy)
        ]

        let topicDatas = [
            TopicData(category: .employment, percentage: 32, imageName: "imagename"),
            TopicData(category: .event, percentage: 32, imageName: "imagename"),
            TopicData(category: .food, percentage: 32, imageName: "imagename"),
            TopicData(category: .health, percentage: 32, imageName: "imagename"),
            TopicData(category: .love, percentage: 32, imageName: "imagename"),
            TopicData(category: .daily, percentage: 32, imageName: "imagename")
        ]

        let tipData = ConversationTipData(
            title: "맞춤 대화 팁",
            description: "서지연님과의 대화에서 긍정적인 피드백이 많이 오갔네요. 이런 대화 패턴을 유지하면서, 더 깊이 있는 대화를 나눠보는 건 어떨까요?",
            icon: "lightbulb.fill"
        )

        return Stats(
            headerData: headerData,
            mostUsedData: mostUsedData,
            emotionDatas: emotionDatas,
            topicDatas: topicDatas,
            conversationTipData: tipData
        )
    }
}
