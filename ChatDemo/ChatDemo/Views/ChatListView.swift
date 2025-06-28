import Combine
import Foundation
import SwiftUI
import SwiftData

struct ChatListView: View {
    @StateObject private var viewModel: ChatListViewModel

    init(context: ModelContext) {
        let store = ChatStoreManager(context: context)
        _viewModel = StateObject(wrappedValue: ChatListViewModel(store: store))
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Chat")) {
                    ForEach(viewModel.chatRooms) { room in
                        NavigationLink(
                            destination: ChatViewWrapper(chatRoom: room, store: viewModel.store)
                        ) {
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
    let store: ChatStoreManager

    var body: some View {
        let viewModel = ChatViewModel(store: store, chatRoom: chatRoom)
        ChatView(viewModel: viewModel)
            .navigationTitle(chatRoom.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}
