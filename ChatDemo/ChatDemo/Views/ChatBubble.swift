import SwiftUI

struct ChatBubble: View {
    let message: Message

    var isSender: Bool {
        message.sender == User.me
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isSender {
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.sender.name)
                        .font(.caption).bold()
                        .foregroundColor(.black)
                    Text(message.text)
                        .padding(10)
                        .background(Color.messageGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            else {
                VStack {
                    Circle()
                        .fill(profileColor(for: message.sender.name))
                        .frame(width: 36, height: 36)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.sender.name)
                        .font(.caption).bold()
                        .foregroundColor(.black)
                    Text(message.text)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
            }
        }
        .id(message.id)
    }
    
    private func profileColor(for name: String) -> Color {
         let colors: [Color] = [.pink, .blue, .orange, .purple, .mint, .teal]
         let index = abs(name.hashValue) % colors.count
         return colors[index]
     }
}
