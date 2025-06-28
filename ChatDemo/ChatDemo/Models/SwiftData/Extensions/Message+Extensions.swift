extension Message {
    func toEntity(chatRoom: ChatRoomEntity, sender: UserEntity) -> MessageEntity {
        MessageEntity(
            id: self.id,
            sender: sender,
            date: self.date,
            type: self is TextMessage ? "text" : "sticker",
            text: (self as? TextMessage)?.text,
            stickerID: (self as? StickerMessage)?.sticker.rawValue,
            chatRoom: chatRoom
        )
    }
}
