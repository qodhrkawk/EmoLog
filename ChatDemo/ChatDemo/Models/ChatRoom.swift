import Foundation

struct ChatRoom: Identifiable, Hashable {
    let id: UUID
    let chatType: ChatType
    var name: String
    var participants: [User]
    var messages: [any Message]

    init(id: UUID = UUID(), name: String, participants: [User], messages: [any Message] = [], chatType: ChatType = .friend) {
        self.id = id
        self.chatType = chatType
        self.name = name
        self.participants = participants
        self.messages = messages
    }
    
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum ChatType {
    case blindDate
    case friend
    case bot
}

extension ChatType {
    var instruction: String {
        switch self {
        case .blindDate:
        """
        You are my blind date partner, and you have a romantic interest in me. 
        You are chatting with me through text.
        When an input is given, respond with something you might say as a blind date partner who is interested in me.
        """
        case .friend:
        """
        You are a friend of mine, who is participating in a conversation using chat app.
        When an input is given, respond with something you might say as a close friend.
        """
        case .bot:
        """
        You are a chat bot in chat app.
        Based on given tools, you need to provide proper information for user.
        Use tools as much as possible.
        """
        }
    }
}
