import Combine
import FoundationModels
internal import SwiftUI

class StatsViewModel: ObservableObject {
    @Published var stats: Stats?
    let chatRoom: ChatRoom

    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
    }
    
    func fetchMessages() -> [any Message] {
        // TODO: 일주일 필터링
        return chatRoom.messages
    }
    
    func makeReportPerDay() {
        Task {
            let calendar = Calendar.current
            let messages = fetchMessages()
            
            // 1. 날짜별 메시지 분리
            let groupedMessages = Dictionary(grouping: messages) { message in
                calendar.startOfDay(for: message.date)
            }

            let mostUsedWord = mostUsedWord(messages: messages)
            let mostUsedSticker = mostUsedSticker(messages: messages)
            
            self.stats = Stats(
                headerData: HeaderData(
                    name: "aa",
                    formattedDateString: formattedDate(Date())
                ),
                mostUsedData: MostUsedData(
                    word: mostUsedWord?.word ?? "",
                    wordEmotion: .happy,
                    usedWordCount: mostUsedWord?.count ?? 0,
                    stickerEmotion: .happy,
                    stickerImageName: mostUsedSticker?.sticker.imageName ?? Sticker.joy.imageName
                )
            )
            var dailyReports: [DailyReport] = []
            for (date, messagesForDay) in groupedMessages.sorted(by: { $0.key < $1.key }) {
                let transcript = messagesForDay.compactMap { message in
                    if let text = message as? TextMessage {
                        return "[\(text.sender.name)]: \(text.text)"
                    } else if let sticker = message as? StickerMessage {
                        return "[\(sticker.sender.name)]: Sticker about \(sticker.sticker.description)"
                    }
                    return nil
                }.joined(separator: "\n")
                
                guard !transcript.isEmpty else { continue }
                
                do {
                    let instruction = """
                    Make a daily report by analyzing users' conversation.
                    
                    Each line represents a message and follows this format:
                    [UserName]: message
                    """
                                    
                    let session = LanguageModelSession(instructions: instruction)
                    
                    let dailyReport = try await session.respond(generating: DailyReport.self) {
                    """
                    Make report from chat history:
                    \(transcript)
                    """
                    }.content
                    
                    print("YJKIM Daily Report For \(date)\n\(dailyReport)")
                    
                    dailyReports.append(dailyReport)
                    
                    let myEmotions = emotionDatas(from: dailyReport, for: .me, date: date)
                    
                    self.stats = self.stats?.addingMyEmotionData(emotionDatas: myEmotions)
                    
                    if let partner = chatRoom.participants.first(where: { $0.name != User.me.name }) {
                        let friendEmotions = emotionDatas(from: dailyReport, for: partner, date: date)
                        self.stats = self.stats?.addingFriendEmotionData(emotionDatas: friendEmotions)
                    }
                    
                    self.stats = self.stats?.addingTopicData(topicData: topicData(from: dailyReport))
                }
                catch {
                    print("YJKIM ⚠️ Failed to create report for \(date): \(error)")
                }
            }
            do {
                let adviceSession = LanguageModelSession(
                    instructions:
                    """
                    You already gave the user some advices. Wrap up the advices that you gave before.
                    """
                )
                let advices = dailyReports.map { $0.advice.advice }.joined(separator: "/n")
                
                let overallAdvice = try await adviceSession.respond(generating: ConversationAdvice.self) {
                    """
                    Wrap up the adivce based on the advices you gave before. 
                    Each advices are separated with new line.
                    \(advices)
                    """
                }.content.advice
                
                self.stats = self.stats?.addingAdviceData(
                    conversationTipData:
                        ConversationTipData(
                            title: "Tips",
                            description: overallAdvice,
                            icon: ""
                        )
                )
            }
        }
    }
    
    private func formattedTranscript(messages: [any Message]) -> String? {
        messages.compactMap { message in
            if let textMessage = message as? TextMessage {
                return "[\(textMessage.sender.name)]: \(textMessage.text)"
            }
            else if let stickerMessage = message as? StickerMessage {
                return "[\(stickerMessage.sender.name)]: Sticker about \(stickerMessage.sticker.description)"
            }
            return nil
        }.joined(separator: "\n")
    }
    
    func emotionDatas(from dailyReport: DailyReport, for user: User, date: Date) -> [EmotionData] {
        guard let userEmotion = dailyReport.userEmotions.first(where: { $0.name == user.name }) else {
            return []
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        let dateString = dateFormatter.string(from: date)

        let sortedScores = userEmotion.emotionWithScoreList.sorted(by: { $0.score > $1.score })

        // 총합 구하기
        let total = sortedScores.map { $0.score }.reduce(0, +)
        guard total > 0 else { return [] }

        // 정규화하여 EmotionData 생성
        return sortedScores.map { item in
            let normalizedPercentage = Int(round(Double(item.score) / Double(total) * 100))
            return EmotionData(
                dateString: dateString,
                percentage: normalizedPercentage,
                emotion: item.emotion
            )
        }
    }
    
    func topicData(from dailyReport: DailyReport) -> TopicData {
        TopicData(
            category: dailyReport.category.category,
            percentage: dailyReport.category.confidence,
            imageName: dailyReport.category.category.imageName
        )
    }
    
    func mostUsedWord(messages: [any Message]) -> (word: String, count: Int)? {
        let words = messages
            .compactMap { $0 as? TextMessage }
            .flatMap { $0.text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted) }
            .filter { !$0.isEmpty && !stopWords.contains($0) }

        let freq = Dictionary(grouping: words, by: { $0 }).mapValues(\.count)

        if let (key, value) = freq.max(by: { $0.value < $1.value }) {
            return (word: key, count: value)
        } else {
            return nil
        }
    }

    func mostUsedSticker(messages: [any Message]) -> (sticker: Sticker, count: Int)? {
        let stickers = messages
            .compactMap { $0 as? StickerMessage }
            .map { $0.sticker }

        let freq = Dictionary(grouping: stickers, by: { $0 }).mapValues(\.count)

        if let (key, value) = freq.max(by: { $0.value < $1.value }) {
            return (sticker: key, count: value)
        } else {
            return nil
        }
    }
}

extension StatsViewModel {
    
    /// 영어 불용어 리스트 (필요에 따라 더 추가 가능)
    private var stopWords: Set<String> {
        ["the", "a", "an", "in", "on", "at", "to", "and", "or", "is", "are", "was", "were", "be", "been", "of", "for", "with", "as", "by", "this", "that", "it", "i", "you", "we", "he", "she", "they", "my", "your", "our", "their", "s"]
    }
}


struct Stats {
    var headerData: HeaderData
    var mostUsedData: MostUsedData
    var myEmotionDatas: [EmotionData]?
    var friendEmotionDatas: [EmotionData]?
    var topicDatas: [TopicData]?
    var conversationTipData: ConversationTipData?
    
    func addingMyEmotionData(emotionDatas: [EmotionData]) -> Stats {
        var myEmotionDatas = myEmotionDatas ?? []
        myEmotionDatas += emotionDatas
        return Stats(
            headerData: headerData,
            mostUsedData: mostUsedData,
            myEmotionDatas: myEmotionDatas,
            friendEmotionDatas: friendEmotionDatas,
            topicDatas: topicDatas,
            conversationTipData: conversationTipData
        )
    }
    
    func addingFriendEmotionData(emotionDatas: [EmotionData]) -> Stats {
        var friendEmotionDatas = friendEmotionDatas ?? []
        friendEmotionDatas += emotionDatas
        return Stats(
            headerData: headerData,
            mostUsedData: mostUsedData,
            myEmotionDatas: myEmotionDatas,
            friendEmotionDatas: friendEmotionDatas,
            topicDatas: topicDatas,
            conversationTipData: conversationTipData
        )
    }
    
    func addingTopicData(topicData: TopicData) -> Stats {
        var topicDatas = topicDatas ?? []
        topicDatas.append(topicData)
        return Stats(
            headerData: headerData,
            mostUsedData: mostUsedData,
            myEmotionDatas: myEmotionDatas,
            friendEmotionDatas: friendEmotionDatas,
            topicDatas: topicDatas,
            conversationTipData: conversationTipData
        )
    }
    
    func addingAdviceData(conversationTipData: ConversationTipData) -> Stats {
        return Stats(
            headerData: headerData,
            mostUsedData: mostUsedData,
            myEmotionDatas: myEmotionDatas,
            friendEmotionDatas: friendEmotionDatas,
            topicDatas: topicDatas,
            conversationTipData: conversationTipData
        )
    }
}
