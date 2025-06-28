import Foundation

struct ChatRoom: Identifiable, Hashable {
    let id: UUID
    var name: String
    var participants: [User]
    var messages: [any Message]

    init(id: UUID = UUID(), name: String, participants: [User], messages: [any Message] = []) {
        self.id = id
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
