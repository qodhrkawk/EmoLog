import Foundation
import SwiftData

@Model
class ChatRoomEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var participantNames: [String]

    @Relationship(deleteRule: .cascade)
    var messages: [MessageEntity]

    init(id: UUID = UUID(), name: String, participantNames: [String], messages: [MessageEntity] = []) {
        self.id = id
        self.name = name
        self.participantNames = participantNames
        self.messages = messages
    }
}

extension ChatRoomEntity {
    func toChatRoom() -> ChatRoom {
        let participants = participantNames.compactMap { participantName in
            User.allUsers.first(where: { $0.name == participantName })
        }
        let messages = messages.compactMap { $0.toModel() }
        return ChatRoom(
            id: id,
            name: name,
            participants: participants,
            messages: messages
        )
    }
}
