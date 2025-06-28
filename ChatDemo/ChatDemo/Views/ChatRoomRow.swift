import SwiftUI

struct ChatRoomRow: View {
    let room: ChatRoom

    var body: some View {
        VStack(alignment: .leading) {
            Text(room.title)
                .font(.headline)
            if let lastMessage = room.messages.last {
                if case let .text(text) = lastMessage.type {
                    Text(text)
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
