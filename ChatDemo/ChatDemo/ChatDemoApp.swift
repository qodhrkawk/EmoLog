import SwiftUI
import SwiftData

@main
struct ChatDemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [ChatRoomEntity.self, MessageEntity.self, UserEntity.self])
    }
}

private struct RootView: View {
    @Environment(\.modelContext) private var context
    var body: some View {
        ChatListView(context: context)
    }
}
