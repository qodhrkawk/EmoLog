import Combine
import Foundation
import FoundationModels

enum ChatAnalysis: String, CaseIterable, Identifiable {
    case summary
    case sentiment
    case keyword
    case translate
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .summary: return "Summarize Chat"
        case .sentiment: return "Analyze Emotion"
        case .keyword: return "Extract Keywords"
        case .translate: return "Translate All"
        }
    }
}

class ArchivedChatViewModel: ObservableObject, ChatViewModel {
    @Published var messages: [Message]
    @Published var inputText: String = ""
    @Published var isStreamingEnabled: Bool = true   // 실시간 응답은 없음
    @Published var isKorean: Bool = false {
        didSet {
            if isKorean, let koreanMessages {
                messages = koreanMessages
            }
            else {
                messages = originalMessages
            }
        }
    }
    
    private let session: LanguageModelSession
    private var koreanMessages: [Message]?
    private var originalMessages: [Message]
    
    init(messages: [Message], koreanMessages: [Message]?) {
        originalMessages = messages
        self.messages = messages
        self.koreanMessages = koreanMessages
        session = LanguageModelSession()
    }
    
    func prewarm() {
        session.prewarm()
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(sender: User.me, text: inputText)
        messages.append(userMessage)
        let context = messages.map { "\($0.sender): \($0.text)" }.joined(separator: "\n")
        
        inputText = ""
    }
    
    func anlayze(type: ChatAnalysis) {
        switch type {
        case .summary:
            summarize()
        case .sentiment:
            sentimentAnalysis()
        case .keyword:
            extractKeywords()
        case .translate:
            translate()
        }
    }
    
    private func summarize() {
        var instruction: String =
        """
        Please summarize the following conversation.
        
        The dialogue is formatted with each message on a new line, using this structure:
        [UserName]: message
        
        Provide a concise and clear summary of the key points or topics discussed.
        Focus only on decisions or key points, omit greetings and small talk.
        The summary should not exceed 40 words.
        """
        
        if isKorean {
            instruction += "You must summary into Korean, not other languages."
        }
        
        let session = LanguageModelSession(instructions: instruction)
        
        let chatContext = formattedTranscript()
        
        Task {
            do {
                if isStreamingEnabled {
                    let botMessage = Message(sender: User.bot, text: "")
                    messages.append(botMessage)
                    let botMessageIndex = messages.count - 1
                    
                    // 2. Stream 시작
                    let stream = session.streamResponse(to: chatContext)
                    for try await partial in stream {
                        // 3. partial은 누적된 값이므로 바로 반영 가능
                        await MainActor.run {
                            messages[botMessageIndex] = Message(sender: User.bot, text: partial)
                        }
                    }
                }
                else {
                    let response = try await session.respond(to: chatContext)
                    let botMessage = response.content
                    let newMessage = Message(sender: User.bot, text: botMessage)
                    messages.append(newMessage)
                }
            }
            catch {
                let botMessage = Message(sender: User.bot, text: "Summary Failed")
                print("YJKIM Summary error: \(error)")
                messages.append(botMessage)
            }
        }
    }
    
    private func extractKeywords() {
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
                let response = try await session.respond(generating: KeywordAnalysisResult.self) {
                    "Extract keyword from chat history: \(formattedTranscript())"
                }
                
                let botMessage = "Keywords detected: \(response.content.keyword.rawValue)\nConfidence: \(response.content.confidence)"
                let newMessage = Message(sender: User.bot, text: botMessage)
                messages.append(newMessage)
            }
            catch {
                let botMessage = Message(sender: User.bot, text: "Keyword Failed")
                messages.append(botMessage)
            }
        }
    }
    
    private func translate() {
        let session = LanguageModelSession(instructions:
            """
            Translate the following conversation from English to Korean.
            
            The conversation consists of informal, everyday messages exchanged between friends or colleagues. Your translation should be natural, casual, and appropriate for native Korean speakers in a similar context.
            
            Do not preserve speaker labels or formatting — just translate the text content naturally, sentence by sentence.
            
            Avoid overly literal translation. Focus on capturing the tone, intent, and flow of the conversation in Korean.
            
            Do not add, omit, or modify any information.
            """
        )
        Task {
            for index in messages.indices {
                let original = messages[index]
                
                // 이미 번역되었거나 Bot 메시지는 생략
                if original.sender == User.bot {
                    continue
                }
                
                // 초기 빈 메시지 추가
                await MainActor.run {
                    messages[index] = Message(sender: original.sender, text: "")
                }
                
                do {
                    let stream = session.streamResponse(to: original.text)
                    for try await partial in stream {
                        await MainActor.run {
                            messages[index] = Message(sender: original.sender, text: partial)
                        }
                    }
                } catch {
                    await MainActor.run {
                        messages[index] = Message(sender: original.sender, text: "[번역 실패] \(original.text)")
                    }
                }
                
            }
        }
    }
    
    private func sentimentAnalysis() {
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
                
                let formattedLines = uniqueEmotions.map { user in
                    return "• \(user.name): \(user.emotion.rawValue.capitalized)"
                }
                
                let reportText = """
                        🧠 Sentiment Analysis Report
                        
                        \(formattedLines.joined(separator: "\n"))
                        """
                
                let botMessage = Message(sender: User.bot, text: reportText)
                messages.append(botMessage)
            }
            catch {
                let botMessage = Message(sender: User.bot, text: "Sentiment Analyze Failed")
                print("YJKIM Sentiment error: \(error)")
                messages.append(botMessage)
            }
        }
    }
    
    private func formattedTranscript() -> String {
        messages.map { "[\($0.sender)]: \($0.text)" }.joined(separator: "\n")
    }
}

@Generable(description: "A detected keyword information")
struct KeywordAnalysisResult {
    @Guide(description: "")
    let keyword: Category
    @Guide(description: "A confidence of the keyword", .range(0...100))
    let confidence: Int
}

