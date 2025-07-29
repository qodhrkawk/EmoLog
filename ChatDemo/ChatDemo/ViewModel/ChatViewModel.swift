import Combine
import Foundation
import FoundationModels

class ChatViewModel: ObservableObject {
    @Published var messages: [any Message] = []
    @Published var inputText: String = ""
    @Published var isStreamingEnabled: Bool = true
    @Published var extractedKeyword: Keyword?
    @Published var someInt: Int = 1
    
    private let store: ChatStoreManager
    let chatRoom: ChatRoom
    private let session: LanguageModelSession
    
    private var is1on1: Bool {
        chatRoom.participants.count == 2
    }

    init(store: ChatStoreManager, chatRoom: ChatRoom) {
        self.store = store
        self.chatRoom = chatRoom
        self.messages = store.fetchMessages(for: chatRoom)
        session = LanguageModelSession(instructions: chatRoom.chatType.instruction)
    }

    func prewarm() {
        session.prewarm()
    }

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = TextMessage(sender: User.me, text: inputText)
        messages.append(userMessage)
        store.addMessage(userMessage, to: chatRoom)

        inputText = ""
        replyToMessage(request: userMessage.text)
    }
    
    private func replyToMessage(request: String) {
        Task {
            do {
                guard let replier = chatRoom.participants.first(where: { $0 != User.me }) else { return }
                let replyMessage = TextMessage(sender: replier, text: "")
                messages.append(replyMessage)
                let replyMessageIndex = messages.count - 1

                // 2. Stream 시작
                let stream = session.streamResponse(to: request)
                for try await partial in stream {
                    // 3. partial은 누적된 값이므로 바로 반영 가능
                    await MainActor.run {
                        messages[replyMessageIndex] = TextMessage(sender: replier, text: partial)
                    }
                }
//                store.addMessage(messages[replyMessageIndex], to: chatRoom)
            }
            catch {
                let newMessage = TextMessage(sender: User.bot, text: error.localizedDescription)
                // TODO: 삭제
                messages.append(newMessage)
            }
        }
    }
    
    func sendSticker(_ sticker: Sticker) {
        let userMessage = StickerMessage(sender: User.me, sticker: sticker)
        messages.append(userMessage)
        store.addMessage(userMessage, to: chatRoom)
    }
    
    func sendReport(_ stats: Stats) {
        let report = ReportMessage(sender: User.me, stats: stats)
        messages.append(report)
    }
    
    func sendDemoMessages() {
        let baseDateDay7 = dateFromString("2025-07-03")!
        let messages = [
            TextMessage(sender: .me, text: "I really enjoyed our meeting today. Did you get home safely?", date: baseDateDay7.addingTimeInterval(36000)),
            TextMessage(sender: .cony, text: "Yes! I had a lot of fun too. Thank you so much for dinner. Next time, I'll treat you.", date: baseDateDay7.addingTimeInterval(36480)),
            TextMessage(sender: .me, text: "Then how about we go see a movie next time?", date: baseDateDay7.addingTimeInterval(36540)),
            TextMessage(sender: .cony, text: "Sounds great!", date: baseDateDay7.addingTimeInterval(36600))
        ]
        Task {
            for message in messages {
                await MainActor.run {
                    self.messages.append(message)
                    store.addMessage(message, to: chatRoom)
                }
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }

    func removeCustomMessages() {
        let lastDay = dateFromString("2025-07-02")!
        let lastMessageDate = lastDay.addingTimeInterval(36600)

        let messagesToRemove = messages.filter { $0.date > lastMessageDate }

        // 메모리에서 제거
        messages.removeAll(where: { $0.date > lastMessageDate })

        // DB에서도 제거
        for message in messagesToRemove {
            store.removeMessage(message, from: chatRoom)
        }
    }
    
    private func formattedTranscript() -> String? {
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
    
    func summarize() {
        var instruction: String =
        """
        Please summarize the following conversation, in Japanese.
        
        The dialogue is formatted with each message on a new line, using this structure:
        [UserName]: message
        
        Provide a concise and clear summary of the key points or topics discussed.
        Focus only on decisions or key points, omit greetings and small talk.
        The summary should not exceed 40 words.
        """

        let session = LanguageModelSession(instructions: instruction)
        guard let chatContext = formattedTranscript() else { return }
        
        Task {
            do {
                if isStreamingEnabled {
                    let botMessage = TextMessage(sender: User.bot, text: "")
                    messages.append(botMessage)
                    let botMessageIndex = messages.count - 1
                    
                    // 2. Stream 시작
                    let stream = session.streamResponse(to: chatContext)
                    for try await partial in stream {
                        // 3. partial은 누적된 값이므로 바로 반영 가능
                        await MainActor.run {
                            messages[botMessageIndex] = TextMessage(sender: User.bot, text: partial)
                        }
                    }
                    print(messages[botMessageIndex])
                }
                else {
                    let response = try await session.respond(to: chatContext)
                    let botMessage = response.content
                    let newMessage = TextMessage(sender: User.bot, text: botMessage)
                    messages.append(newMessage)
                }
            }
            catch {
                let botMessage = TextMessage(sender: User.bot, text: "Summary Failed")
                print("YJKIM Summary error: \(error)")
                messages.append(botMessage)
            }
        }
    }
    
    func extractKeywords() {
        let session = LanguageModelSession(instructions:
            """
            You are a keyword extractor from the conversation input. 
            
            The dialogue is formatted with each message on a new line, using this structure:
            [UserName]: message
            
            From the chat context, give the related keyword.
            If none of Keyword is related, choose none.
            """
        )
        Task {
            do {
                let conversationKeyword = try await session.respond(generating: ConversationKeyword.self) {
                    "Extract keyword from chat history: \(formattedTranscript())"
                }.content
                
                let botMessage = "Keyword detected: \(conversationKeyword.keyword) \nConfidence: \(conversationKeyword.confidence)"
                let newMessage = TextMessage(sender: User.bot, text: botMessage)
//                self.extractedKeyword = conversationKeyword
                self.extractedKeyword = conversationKeyword.keyword
//                messages.append(newMessage)
            }
            catch {
                let botMessage = TextMessage(sender: User.bot, text: "Keyword Failed")
                messages.append(botMessage)
                print("YJKIM error: \(error)")
            }
        }
    }
    
    func translate() {
        let session = LanguageModelSession(instructions:
            """
            Translate the following conversation from English to Japanese.
            
            The conversation consists of informal, everyday messages exchanged between friends or colleagues. Your translation should be natural, casual, and appropriate for native Japanese speakers in a similar context.
            
            Do not preserve speaker labels or formatting — just translate the text content naturally, sentence by sentence.
            
            Avoid overly literal translation. Focus on capturing the tone, intent, and flow of the conversation in Japanese.
            
            Do not add, omit, or modify any information.
            """
        )
        Task {
            for index in messages.indices {
                guard let original = messages[index] as? TextMessage else { continue }
                
                // 이미 번역되었거나 Bot 메시지는 생략
                if original.sender == User.bot {
                    continue
                }
                
                // 초기 빈 메시지 추가
                await MainActor.run {
                    messages[index] = TextMessage(sender: original.sender, text: "")
                }
                
                do {
                    let stream = session.streamResponse(to: original.text)
                    for try await partial in stream {
                        await MainActor.run {
                            messages[index] = TextMessage(sender: original.sender, text: partial)
                        }
                    }
                } catch {
                    await MainActor.run {
                        messages[index] = TextMessage(sender: original.sender, text: "[번역 실패] \(original.text)")
                    }
                }
                
            }
        }
    }
    
    func sentimentAnalysis() {
        let instruction = """
        Analyze the emotions of each user in the following conversation.
        
        Each line represents a message and follows this format:
        [UserName]: message
        """
        
        let session = LanguageModelSession(instructions: instruction)
        Task {
            do {
                let response = try await session.respond(generating: [UserEmotion].self) {
                """
                Extract emotions from chat history: 
                \(formattedTranscript())
                """
                }
                let rawEmotions: [UserEmotion] = response.content
                
                // 이름 기준 중복 제거
                var seen = Set<String>()
                let uniqueEmotions = rawEmotions.filter { seen.insert($0.name).inserted }
                
                // 이모지 + 설명 매핑
//                func formatEmotion(_ emotion: Emotion) -> String {
//                    switch emotion {
//                    case .joy: return ("😊")
//                    case .happy: return ("😄")
//                    case .sad: return ("😢")
//                    case .frustrated: return ("😤")
//                    case .angry: return ("😠")
//                    case .anticipation: return ("🤔")
//                    case .surprise: return ("😲")
//                    case .trust: return ("🤝")
//                    case .fear: return ("😨")
//                    }
//                }
                
                let formattedLines = uniqueEmotions.map { user in
//                    let emoji = formatEmotion(user.emotion.emotionWithScoreList.first?.emotion)
                    guard let emotionWithScore = user.emotionWithScoreList.first else { return "" }
                    return "\(user.name): \(emotionWithScore.emotion) , Score: \(emotionWithScore.score)"
                }
                
                let reportText = """
                        🧠 Sentiment Analysis Report
                        
                        \(formattedLines.joined(separator: "\n"))
                        """
                
                let botMessage = TextMessage(sender: User.bot, text: reportText)
                messages.append(botMessage)
            }
            catch {
                let botMessage = TextMessage(sender: User.bot, text: "Sentiment Analyze Failed")
                print("YJKIM Sentiment error: \(error)")
                messages.append(botMessage)
            }
        }
    }
    
    func checkSpam() {
        let session = LanguageModelSession(instructions:
            """
            Anlayze the chat history. Check if the users are potentially spam, fraud, or phishing.
            
            The dialogue is formatted with each message on a new line, using this structure:
            [UserName]: message
            """
        )
        Task {
            do {
                let userInfos = try await session.respond(generating: [SpamInfo].self) {
                """
                Extract KindInfo array from chat history: 
                \(formattedTranscript())
                """
                }.content
                
                let formattedLines = userInfos.map { userInfo in
                    return "\(userInfo.userName)'s Spam Score: \(userInfo.spamScore)"
                }
                
                let reportText = "\(formattedLines.joined(separator: "\n"))"
                
                let newMessage = TextMessage(sender: User.bot, text: reportText)
                messages.append(newMessage)
            }
            catch {
                let botMessage = TextMessage(sender: User.bot, text: "Keyword Failed")
                messages.append(botMessage)
                print("YJKIM error: \(error)")
            }
        }
    }
}


@Generable(description: "Check if the user is phishing, fraud, or scam")
struct SpamInfo {
    @Guide(description: "The name of user.")
    let userName: String
    
    @Guide(description: "The confidence for the user is phishing, fraud, or scam", .range(0...100))
    let spamScore: Int
}
