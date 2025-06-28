
extension ChatRoom {
    func toEntity() -> ChatRoomEntity {
        ChatRoomEntity(
            id: id,
            name: name,
            participantNames: participants.map(\.name)
        )
    }
}
