import Foundation
import SwiftData

@Model
class MessageEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var type: String // "text" or "sticker"
    var text: String?
    var stickerID: String?

    @Relationship var sender: UserEntity
    @Relationship var chatRoom: ChatRoomEntity

    init(id: UUID = UUID(), sender: UserEntity, date: Date, type: String, text: String? = nil, stickerID: String? = nil, chatRoom: ChatRoomEntity) {
        self.id = id
        self.sender = sender
        self.date = date
        self.type = type
        self.text = text
        self.stickerID = stickerID
        self.chatRoom = chatRoom
    }
}
extension MessageEntity {
    func toModel() -> any Message {
        if type == "text", let text {
            return TextMessage(id: id, sender: sender.toModel(), text: text, date: date)
        }
        else if type == "sticker", let stickerID, let sticker = Sticker(rawValue: stickerID) {
            return StickerMessage(id: id, sender: sender.toModel(), sticker: sticker, date: date)
        }
        else {
            fatalError("Invalid message entity: \(self)")
        }
    }
}
