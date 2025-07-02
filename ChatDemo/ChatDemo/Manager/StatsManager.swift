//import Foundation
//import FoundationModels
//internal import SwiftUI
//
//class StatsManager {
//    let messages: [any Message]
//    
//    init(messages: [any Message]) {
//        self.messages = messages
//    }
//    
//    func makeReportPerDay() {
//        Task {
//            let calendar = Calendar.current
//            
//            // 1. 날짜별 메시지 분리
//            let groupedMessages = Dictionary(grouping: messages) { message in
//                calendar.startOfDay(for: message.date)
//            }
//            
//            var reports: [Date: DailyReport] = [:]
//            
//            for (date, messagesForDay) in groupedMessages.sorted(by: { $0.key < $1.key }) {
//                let transcript = messagesForDay.compactMap { message in
//                    if let text = message as? TextMessage {
//                        return "[\(text.sender.name)]: \(text.text)"
//                    } else if let sticker = message as? StickerMessage {
//                        return "[\(sticker.sender.name)]: Sticker about \(sticker.sticker.description)"
//                    }
//                    return nil
//                }.joined(separator: "\n")
//                
//                guard !transcript.isEmpty else { continue }
//                
//                do {
//                    let instruction = """
//                    Make a daily report by analyzing users' conversation.
//
//                    Each line represents a message and follows this format:
//                    [UserName]: message
//                    """
//                    
//                    print("YJKIM Transcript: \(transcript.count)")
//                    
//                    let session = LanguageModelSession(instructions: instruction)
//                    
//                    let response = try await session.respond(generating: DailyReport.self) {
//                    """
//                    Make report from chat history:
//                    \(transcript)
//                    """
//                    }
//                    
//                    print("YJKIM Report for day: \(date) : \(response.content)")
//                    
////                    await MainActor.run {
////                        reports[date] = response.content
////                    }
//                }
//                catch {
//                    print("YJKIM ⚠️ Failed to create report for \(date): \(error)")
//                }
//            }
//            
//
//            do {
//                let advice = try await session.respond(generating: ConversationAdvice.self) {
//                    """
//                    Give the adivce based on conversation before, for user `Me`.
//                    """
//                }
//                
//                print("YJKIM Advice: \(advice.content)")
//            }
//            
////            await MainActor.run {
////                self.dailyReports = reports
////            }
//        }
//    }
//    
//    private func formattedTranscript() -> String? {
//        messages.compactMap { message in
//            if let textMessage = message as? TextMessage {
//                return "[\(textMessage.sender.name)]: \(textMessage.text)"
//            }
//            else if let stickerMessage = message as? StickerMessage {
//                return "[\(stickerMessage.sender.name)]: Sticker about \(stickerMessage.sticker.description)"
//            }
//            return nil
//        }.joined(separator: "\n")
//    }
//    
//    func emotionDatas(from dailyReport: DailyReport, for user: User, date: Date) -> [EmotionData] {
//        guard let userEmotion = dailyReport.userEmotions.first(where: { $0.name == user.name }) else {
//            return []
//        }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "M/d"
//        let dateString = dateFormatter.string(from: date)
//
//        return userEmotion.emotionWithScoreList
//            .sorted(by: { $0.score > $1.score })
//            .map {
//                EmotionData(
//                    dateString: dateString,
//                    percentage: $0.score,
//                    emotion: $0.emotion
//                )
//            }
//    }
//    
//    func topicData(from dailyReport: DailyReport) -> TopicData {
//        TopicData(
//            category: dailyReport.category.category,
//            percentage: dailyReport.category.confidence,
//            imageName: dailyReport.category.category.imageName
//        )
//    }
//    
//    
//    
//    func fetchStats() -> Stats {
//        let headerData = HeaderData(name: "서지연", formattedDateString: "2023년 6월 24일")
//
//        let mostUsedData = MostUsedData(
//            word: "좋아해",
//            usedCount: 127,
//            stickerImageName: "heart.fill"
//        )
//
//        let emotionDatas = [
//            EmotionData(dateString: "6/18", percentage: 70, emotion: .happy),
//            EmotionData(dateString: "6/18", percentage: 30, emotion: .sad),
//            EmotionData(dateString: "6/19", percentage: 75, emotion: .angry),
//            EmotionData(dateString: "6/20", percentage: 60, emotion: .fear),
//            EmotionData(dateString: "6/20", percentage: 20, emotion: .love),
//            EmotionData(dateString: "6/21", percentage: 85, emotion: .surprise),
//            EmotionData(dateString: "6/21", percentage: 15, emotion: .love),
//            EmotionData(dateString: "6/22", percentage: 90, emotion: .angry),
//            EmotionData(dateString: "6/23", percentage: 75, emotion: .happy),
//            EmotionData(dateString: "6/24", percentage: 80, emotion: .happy)
//        ]
//
//        let topicDatas = [
//            TopicData(category: .employment, percentage: 32, imageName: "imagename"),
//            TopicData(category: .event, percentage: 32, imageName: "imagename"),
//            TopicData(category: .food, percentage: 32, imageName: "imagename"),
//            TopicData(category: .health, percentage: 32, imageName: "imagename"),
//            TopicData(category: .love, percentage: 32, imageName: "imagename"),
//            TopicData(category: .daily, percentage: 32, imageName: "imagename")
//        ]
//
//        let tipData = ConversationTipData(
//            title: "맞춤 대화 팁",
//            description: "서지연님과의 대화에서 긍정적인 피드백이 많이 오갔네요. 이런 대화 패턴을 유지하면서, 더 깊이 있는 대화를 나눠보는 건 어떨까요?",
//            icon: "lightbulb.fill"
//        )
//
//        return Stats(
//            headerData: headerData,
//            mostUsedData: mostUsedData,
//            emotionDatas: emotionDatas,
//            topicDatas: topicDatas,
//            conversationTipData: tipData
//        )
//    }
//    
//    
//    func mostUsedWord(messages: [any Message]) -> (word: String, count: Int)? {
//        let words = messages
//            .compactMap { $0 as? TextMessage }
//            .flatMap { $0.text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted) }
//            .filter { !$0.isEmpty && !stopWords.contains($0) }
//
//        let freq = Dictionary(grouping: words, by: { $0 }).mapValues(\.count)
//
//        if let (key, value) = freq.max(by: { $0.value < $1.value }) {
//            return (word: key, count: value)
//        } else {
//            return nil
//        }
//    }
//
//    func mostUsedSticker(messages: [any Message]) -> (sticker: Sticker, count: Int)? {
//        let stickers = messages
//            .compactMap { $0 as? StickerMessage }
//            .map { $0.sticker }
//
//        let freq = Dictionary(grouping: stickers, by: { $0 }).mapValues(\.count)
//
//        if let (key, value) = freq.max(by: { $0.value < $1.value }) {
//            return (sticker: key, count: value)
//        } else {
//            return nil
//        }
//    }
//}
//
//extension StatsManager {
//    
//    /// 영어 불용어 리스트 (필요에 따라 더 추가 가능)
//    private var stopWords: Set<String> {
//        ["the", "a", "an", "in", "on", "at", "to", "and", "or", "is", "are", "was", "were", "be", "been", "of", "for", "with", "as", "by", "this", "that", "it", "i", "you", "we", "he", "she", "they", "my", "your", "our", "their"]
//    }
//
//    var mostUsedWord: (word: String, count: Int)? {
//        let words = messages
//            .compactMap { $0 as? TextMessage }
//            .flatMap { $0.text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted) }
//            .filter { !$0.isEmpty && !stopWords.contains($0) }
//
//        let freq = Dictionary(grouping: words, by: { $0 }).mapValues(\.count)
//
//        if let (key, value) = freq.max(by: { $0.value < $1.value }) {
//            return (word: key, count: value)
//        } else {
//            return nil
//        }
//    }
//
//    var mostUsedSticker: (sticker: Sticker, count: Int)? {
//        let stickers = messages
//            .compactMap { $0 as? StickerMessage }
//            .map { $0.sticker }
//
//        let freq = Dictionary(grouping: stickers, by: { $0 }).mapValues(\.count)
//
//        if let (key, value) = freq.max(by: { $0.value < $1.value }) {
//            return (sticker: key, count: value)
//        } else {
//            return nil
//        }
//    }
//}
//
