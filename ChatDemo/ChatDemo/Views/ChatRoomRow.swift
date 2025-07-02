internal import SwiftUI

struct ChatRoomRow: View {
    let room: ChatRoom

    var body: some View {
        VStack(alignment: .leading) {
            Text(room.name)
                .font(.headline)
            if let lastMessage = room.messages.last {
                if let textMessage = lastMessage as? TextMessage {
                    Text(textMessage.text)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                else {
                    // TODO
                }
            }
        }
        .padding(.vertical, 4)
    }
}
