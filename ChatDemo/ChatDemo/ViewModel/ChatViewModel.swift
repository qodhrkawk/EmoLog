import Combine
import Foundation
import FoundationModels

class ChatViewModel: ObservableObject {
    @Published var messages: [any Message] = []
    @Published var inputText: String = ""
    @Published var isStreamingEnabled: Bool = true
    
    private let store: ChatStoreManager
    private let chatRoom: ChatRoom
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
                store.addMessage(messages[replyMessageIndex], to: chatRoom)
            }
            catch {
                let newMessage = TextMessage(sender: User.bot, text: error.localizedDescription)
                // TODO: 삭제
                messages.append(newMessage)
            }
        }
    }
    
    func makeReport() {
        makeReportPerDay()
    }
    
    func sendSticker(_ sticker: Sticker) {
        let userMessage = StickerMessage(sender: User.me, sticker: sticker)
        messages.append(userMessage)
        store.addMessage(userMessage, to: chatRoom)
    }
    
    func makeReportPerDay() {
        Task {
            let calendar = Calendar.current
            
            // 1. 날짜별 메시지 분리
            let groupedMessages = Dictionary(grouping: messages) { message in
                calendar.startOfDay(for: message.date)
            }
            
            var reports: [Date: Report] = [:]
            
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
                    Make a report by analyzing users' conversation.

                    Each line represents a message and follows this format:
                    [UserName]: message
                    """
                    
                    print("YJKIM Transcript: \(transcript.count)")
                    
                    let session = LanguageModelSession(instructions: instruction)
                    
                    let response = try await session.respond(generating: Report.self) {
                    """
                    Make report from chat history:
                    \(transcript)
                    """
                    }
                    
                    print("YJKIM Report for day: \(date) : \(response.content)")
                    
//                    await MainActor.run {
//                        reports[date] = response.content
//                    }
                }
                catch {
                    print("YJKIM ⚠️ Failed to create report for \(date): \(error)")
                }
            }
            

            do {
                let advice = try await session.respond(generating: ConversationAdvice.self) {
                    """
                    Give the adivce based on conversation before, for user `Me`.
                    """
                }
                
                print("YJKIM Advice: \(advice.content)")
            }
            
//            await MainActor.run {
//                self.dailyReports = reports
//            }
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
}

