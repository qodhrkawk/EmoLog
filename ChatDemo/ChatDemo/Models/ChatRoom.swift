import Foundation

enum ChatRoomType {
    case live
    case archived
}

struct ChatRoom: Identifiable {
    let id = UUID()
    let roomType: ChatRoomType
    let title: String
    let messages: [Message]
    let koreanMessages: [Message]?
}
