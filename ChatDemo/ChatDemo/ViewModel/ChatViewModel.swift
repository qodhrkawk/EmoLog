import Combine
import Foundation
import FoundationModels

class ChatViewModel: ObservableObject {
    @Published var messages: [any Message] = []
    @Published var inputText: String = ""
    @Published var isStreamingEnabled: Bool = true
    
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
                store.addMessage(messages[replyMessageIndex], to: chatRoom)
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

