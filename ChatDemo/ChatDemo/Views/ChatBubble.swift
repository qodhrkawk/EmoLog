internal import SwiftUI

struct ChatBubble: View {
    let message: any Message
    let onReportTap: ((Stats) -> Void)?

    var isSender: Bool {
        message.sender == User.me
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isSender {
                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text(timeString)
                            .font(.caption2)
                            .foregroundColor(Color(white: 0.35))

                        contentView
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        // 프로필
                        if let imageName = message.sender.imageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                        }
                        else {
                            Circle()
                                .fill(profileColor(for: message.sender.name))
                                .frame(width: 36, height: 36)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(message.sender.name)
                                .font(.caption).bold()
                                .foregroundColor(.black)
                                .padding(.bottom, 2)

                            HStack(alignment: .bottom, spacing: 4) {
                                contentView

                                Text(timeString)
                                    .font(.caption2)
                                    .foregroundColor(Color(white: 0.35))
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .id(message.id)
    }

    @ViewBuilder
    private var contentView: some View {
        if let textMessage = message as? TextMessage {
            Text(textMessage.text)
                .padding(10)
                .background(isSender ? Color.messageGreen : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        else if let stickerMessage = message as? StickerMessage {
            stickerMessage.sticker.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding(6)
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        else if let reportMessage = message as? ReportMessage {
            ReportSummaryView(stats: reportMessage.stats) {
                onReportTap?(reportMessage.stats)
            }
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }

    private func profileColor(for name: String) -> Color {
        let colors: [Color] = [.pink, .blue, .orange, .purple, .mint, .teal]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: message.date)
    }
}

struct ReportSummaryView: View {
    let stats: Stats
    let onViewReport: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📊 Conversation Report")
                .font(.headline)

            HeaderView(headerData: stats.headerData)
            Spacer(minLength: 8)

            Button(action: onViewReport) {
                Text("View Full Report")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
