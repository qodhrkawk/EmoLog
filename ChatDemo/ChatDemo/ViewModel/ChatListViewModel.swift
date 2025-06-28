import Combine
import SwiftData
import Foundation

class ChatListViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoom] = []
    
    let store: ChatStoreManager
    
    init(store: ChatStoreManager) {
        self.store = store
        loadChatRooms()
    }

    func loadChatRooms() {
        if store.hasNoChatRooms() {
            store.insertInitialDummyRooms()
        }
        chatRooms = store.fetchChatRooms()
    }
    
    func delete(room: ChatRoom) {
        store.deleteChatRoom(room)
        loadChatRooms()
    }
}
