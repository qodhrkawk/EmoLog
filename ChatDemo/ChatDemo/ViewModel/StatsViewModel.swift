import Combine
import FoundationModels
internal import SwiftUI

class StatsViewModel: ObservableObject {
    @Published var stats: Stats?
    let chatRoom: ChatRoom
    var partner: User? {
        chatRoom.participants.first(where: { $0.name != User.me.name })
    }

    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
    }
    
    func fetchMessages() -> [any Message] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current

        // 최근 7일간의 날짜 스트링 만들기
        let recent7Days: Set<String> = (0..<7).map {
            guard let day = calendar.date(byAdding: .day, value: -$0, to: today) else { return "" }
            return formatter.string(from: day)
        }.reduce(into: Set<String>()) { $0.insert($1) }

        print("Recent 7 days (String): \(recent7Days)")

        // 메시지를 해당 날짜 문자열 기준으로 필터링
        return chatRoom.messages.filter { message in
            let messageDateString = formatter.string(from: message.date)
            return recent7Days.contains(messageDateString)
        }
    }

    func makeReportPerDay() {
        Task {
            let calendar = Calendar.current
            let messages = fetchMessages()
            
            // 날짜 포매터 (String 기반 그룹핑용)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current
            
            // 1. 날짜별 메시지 분리 (문자열 기준)
            let groupedMessages = Dictionary(grouping: messages) { message in
                formatter.string(from: message.date)
            }

            let mostUsedWord = mostUsedWord(messages: messages)
            let mostUsedSticker = mostUsedSticker(messages: messages)
            
            self.stats = Stats(
                headerData: HeaderData(
                    name: User.myName,
                    formattedDateString: formattedDate(Date())
                ),
                mostUsedData: MostUsedData(
                    word: mostUsedWord?.word ?? "",
                    wordEmotion: .happy,
                    usedWordCount: mostUsedWord?.count ?? 0,
                    stickerEmotion: mostUsedSticker?.sticker.emotion ?? .happy,
                    stickerImageName: mostUsedSticker?.sticker.imageName ?? Sticker.joy.imageName
                )
            )

            var dailyReports: [DailyReport] = []

            for (dateString, messagesForDay) in groupedMessages.sorted(by: { $0.key < $1.key }) {
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
                    
                    print("YJKIM Daily Report For \(dateString): \(dailyReport)")
                    
                    dailyReports.append(dailyReport)

                    // Date 객체 필요 시 변환
                    let date = formatter.date(from: dateString) ?? Date()

                    let myEmotions = emotionDatas(from: dailyReport, for: .me, date: date)
                    self.stats = self.stats?.addingMyEmotionData(emotionDatas: myEmotions)

                    if let partner = chatRoom.participants.first(where: { $0.name != User.me.name }) {
                        let friendEmotions = emotionDatas(from: dailyReport, for: partner, date: date)
                        self.stats = self.stats?.addingFriendEmotionData(emotionDatas: friendEmotions)
                    }

                    self.stats = self.stats?.addingTopicData(topicData: topicData(from: dailyReport))
                }
                catch {
                    print("YJKIM ⚠️ Failed to create report for \(dateString): \(error)")
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
                    Wrap up the advice based on the advices you gave before. 
                    Each advice is separated with a new line.
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
            percentage: dailyReport.category.confidence
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
        var updatedTopicDatas = topicDatas ?? []

        // 기존에 같은 category가 있는지 확인
        if let index = updatedTopicDatas.firstIndex(where: { $0.category == topicData.category }) {
            // 이미 존재하면 더 높은 percentage일 때만 교체
            if topicData.percentage > updatedTopicDatas[index].percentage {
                updatedTopicDatas[index] = topicData
            }
            // 아니면 아무것도 안 함
        } else {
            // category가 없다면 추가
            updatedTopicDatas.append(topicData)
        }

        // percentage 기준 내림차순 정렬
        updatedTopicDatas.sort { $0.percentage > $1.percentage }

        return Stats(
            headerData: headerData,
            mostUsedData: mostUsedData,
            myEmotionDatas: myEmotionDatas,
            friendEmotionDatas: friendEmotionDatas,
            topicDatas: updatedTopicDatas,
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
