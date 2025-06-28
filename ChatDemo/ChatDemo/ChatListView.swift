import Combine
import Foundation
import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Bot")) {
                    ForEach(viewModel.chatRooms.filter { $0.roomType == .live }) { room in
                        NavigationLink(destination: ChatViewWrapper(chatRoom: room)) {
                            ChatRoomRow(room: room)
                        }
                    }
                }

                Section(header: Text("Archived")) {
                    ForEach(viewModel.chatRooms.filter { $0.roomType == .archived }) { room in
                        NavigationLink(destination: ChatViewWrapper(chatRoom: room)) {
                            ChatRoomRow(room: room)
                        }
                    }
                }
            }
            .navigationTitle("Chats")
        }
    }
}

struct ChatViewWrapper: View {
    let chatRoom: ChatRoom

    var body: some View {
        if chatRoom.roomType == .live {
            ChatView(viewModel: LiveChatViewModel(messages: chatRoom.messages))
                .navigationTitle(chatRoom.title)
                .navigationBarTitleDisplayMode(.inline)
        }
        else {
            ChatView(viewModel: ArchivedChatViewModel(messages: chatRoom.messages, koreanMessages: chatRoom.koreanMessages))
                .navigationTitle(chatRoom.title)
                .navigationBarTitleDisplayMode(.inline)
        }

    }
}


