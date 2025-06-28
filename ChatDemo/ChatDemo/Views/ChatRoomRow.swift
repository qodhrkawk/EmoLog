import SwiftUI

struct ChatRoomRow: View {
    let room: ChatRoom

    var body: some View {
        VStack(alignment: .leading) {
            Text(room.title)
                .font(.headline)
            if let lastMessage = room.messages.last {
                Text("\(lastMessage.text)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
