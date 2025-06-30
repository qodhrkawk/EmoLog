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

    init(store: ChatStoreManager, chatRoom: ChatRoom) {
        self.store = store
        self.chatRoom = chatRoom
        self.messages = store.fetchMessages(for: chatRoom)
        if chatRoom.participants == [User.bot, User.me] {
            session = LanguageModelSession(
                instructions:
                """
                You are a chat bot in chat app.
                Based on given tools, you need to provide proper information for user.
                Use tools as much as possible.
                """
            )
        }
        else {
            session = LanguageModelSession()
        }
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
        sendBotMessage(request: userMessage.text)
    }
    
    private func sendBotMessage(request: String) {
        Task {
            do {
                let botMessage = TextMessage(sender: User.bot, text: "")
                messages.append(botMessage)
                let botMessageIndex = messages.count - 1

                // 2. Stream 시작
                let stream = session.streamResponse(to: request)
                for try await partial in stream {
                    // 3. partial은 누적된 값이므로 바로 반영 가능
                    await MainActor.run {
                        messages[botMessageIndex] = TextMessage(sender: User.bot, text: partial)
                    }
                }
                store.addMessage(messages[botMessageIndex], to: chatRoom)
            }
            catch {
                let newMessage = TextMessage(sender: User.bot, text: error.localizedDescription)
                messages.append(newMessage)
            }
        }
    }
    
    func makeReport() {
        
        Task {
            do {
                let instruction = """
                Make a report by analyzing users' conversation.
                
                Each line represents a message and follows this format:
                [UserName]: message
                """
                let session = LanguageModelSession(instructions: instruction)
                guard let script = formattedTranscript() else { return }
                
                let response = try await session.respond(generating: Report.self) {
                """
                Make report from chat history: 
                \(script)
                """
                }
                
                print("YJKIM report: \(response.content)")

            }
            catch {
                print("YJKIM Error: \(error)")
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

