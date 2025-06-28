import Combine
import Foundation
import FoundationModels

class ChatViewModel: ObservableObject {
    @Published var messages: [any Message] = []
    @Published var inputText: String = ""
    @Published var isStreamingEnabled: Bool = true
    
    private let store: ChatStoreManager
    private let chatRoom: ChatRoom
    private let session = LanguageModelSession()

    init(store: ChatStoreManager, chatRoom: ChatRoom) {
        self.store = store
        self.chatRoom = chatRoom
        self.messages = store.fetchMessages(for: chatRoom)
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
    }
}
