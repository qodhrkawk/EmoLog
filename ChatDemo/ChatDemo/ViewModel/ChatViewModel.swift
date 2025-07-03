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
//        store.addMessage(report, to: chatRoom)
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

