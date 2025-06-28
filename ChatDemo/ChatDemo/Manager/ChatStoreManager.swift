import Foundation
import SwiftData

@Observable
class ChatStoreManager {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - User 저장
    func saveUser(_ user: User) {
        if let _ = fetchUserEntity(name: user.name) {
            return // 이미 있음
        }
        let entity = user.toEntity()
        context.insert(entity)
        try? context.save()
    }

    // MARK: - 여러 유저 저장
    func saveUsers(_ users: [User]) {
        for user in users {
            saveUser(user)
        }
    }

    // MARK: - UserEntity 가져오기
    func fetchUserEntity(name: String) -> UserEntity? {
        var descriptor = FetchDescriptor<UserEntity>(
            predicate: #Predicate { $0.name == name }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    // MARK: - 모든 User 불러오기
    func fetchAllUsers() -> [User] {
        do {
            let entities = try context.fetch(FetchDescriptor<UserEntity>())
            return entities.map { $0.toModel() }
        } catch {
            print("⚠️ Failed to fetch users: \(error)")
            return []
        }
    }

    // MARK: - 초기 사용자 저장
    func insertInitialUsersIfNeeded() {
        var descriptor = FetchDescriptor<UserEntity>()
        descriptor.fetchLimit = 1
        let hasUsers = (try? context.fetchCount(descriptor)) ?? 0 > 0
        if hasUsers { return }

        saveUsers(User.allUsers)
    }

    // MARK: - 채팅방 존재 여부
    func hasNoChatRooms() -> Bool {
        var descriptor = FetchDescriptor<ChatRoomEntity>()
        descriptor.fetchLimit = 1
        do {
            return try context.fetchCount(descriptor) == 0
        } catch {
            print("⚠️ Failed to check chat room count: \(error)")
            return true
        }
    }

    // MARK: - 더미 채팅방 추가
    func insertInitialDummyRooms() {
        let dummyRooms = makeInitialDummyRooms()
        for room in dummyRooms {
            let entity = room.toEntity()
            context.insert(entity)
            for message in room.messages {
                let senderEntity = resolveOrInsertUserEntity(for: message.sender)
                let messageEntity = message.toEntity(chatRoom: entity, sender: senderEntity)
                context.insert(messageEntity)
                entity.messages.append(messageEntity)
            }
            entity.messages.sort { $0.date < $1.date }
        }

        do {
            try context.save()
        } catch {
            print("⚠️ Failed to save dummy chat rooms: \(error)")
        }
    }

    private func makeInitialDummyRooms() -> [ChatRoom] {
        let date = Date()
        return [
            ChatRoom(name: "Chat Bot", participants: [], messages: []),
            ChatRoom(
                name: "스티커",
                participants: [],
                messages: [
                    TextMessage(sender: .me, text: "I think today’s meeting went pretty smoothly.", date: date),
                    TextMessage(sender: .junhyuk, text: "Yeah, we actually wrapped up on time for once.", date: date.addingTimeInterval(1)),
                    TextMessage(sender: .jongyoun, text: "That rarely happens. Kind of impressive.",date: date.addingTimeInterval(2)),
                    TextMessage(sender: .hyeonji, text: "Everyone was surprisingly focused today.", date: date.addingTimeInterval(3)),
                    TextMessage(sender: .wonseob, text: "Except when we got sidetracked by the coffee machine discussion.", date: date.addingTimeInterval(4)),
                    StickerMessage(sender: .hyeonji, sticker: .angry, date: date.addingTimeInterval(5)),
                    TextMessage(sender: .me, text: "Wait, that sticker is adorable.", date: date.addingTimeInterval(6)),
                    TextMessage(sender: .junhyuk, text: "I was just about to say that! I’ve never seen that one.", date: date.addingTimeInterval(7)),
                    TextMessage(sender: .jongyoun, text: "Seriously, how do you always have the best stickers?", date:  date.addingTimeInterval(8)),
                    TextMessage(sender: .hyeonji, text: "Haha, glad you like it.", date: date.addingTimeInterval(9)),
                    TextMessage(sender: .wonseob, text: "That one fits you perfectly, too.", date: date.addingTimeInterval(19)),
                ]
            )
        ]
    }

    // MARK: - 전체 채팅방 불러오기
    func fetchChatRooms() -> [ChatRoom] {
        var descriptor = FetchDescriptor<ChatRoomEntity>(sortBy: [SortDescriptor(\.name)])
        do {
            return try context.fetch(descriptor).map { $0.toChatRoom() }
        } catch {
            print("⚠️ Failed to fetch chat rooms: \(error)")
            return []
        }
    }

    // MARK: - 채팅방 저장
    func saveChatRoom(_ chatRoom: ChatRoom) {
        guard !isExistingChatRoom(id: chatRoom.id) else { return }

        let roomEntity = chatRoom.toEntity()
        context.insert(roomEntity)

        for message in chatRoom.messages {
            let senderEntity = resolveOrInsertUserEntity(for: message.sender)
            context.insert(message.toEntity(chatRoom: roomEntity, sender: senderEntity))
        }

        try? context.save()
    }

    private func isExistingChatRoom(id: UUID) -> Bool {
        var descriptor = FetchDescriptor<ChatRoomEntity>(
            predicate: #Predicate { entity in entity.id == id }
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor).first) != nil
    }

    // MARK: - 채팅방 삭제
    func deleteChatRoom(_ chatRoom: ChatRoom) {
        let roomId = chatRoom.id
        var descriptor = FetchDescriptor<ChatRoomEntity>(
            predicate: #Predicate { entity in entity.id == roomId }
        )
        descriptor.fetchLimit = 1
        if let entity = try? context.fetch(descriptor).first {
            context.delete(entity)
            try? context.save()
        }
    }

    // MARK: - 메시지 추가
    func addMessage(_ message: any Message, to chatRoom: ChatRoom) {
        guard let entity = fetchChatRoomEntity(id: chatRoom.id) else { return }

        let senderEntity = resolveOrInsertUserEntity(for: message.sender)
        let messageEntity = message.toEntity(chatRoom: entity, sender: senderEntity)
        context.insert(messageEntity)
        entity.messages.append(messageEntity)

        try? context.save()
    }

    // MARK: - 특정 채팅방 메시지 불러오기
    func fetchMessages(for chatRoom: ChatRoom) -> [any Message] {
        guard let entity = fetchChatRoomEntity(id: chatRoom.id) else { return [] }

        return entity.messages
            .sorted(by: { $0.date < $1.date })
            .compactMap { $0.toModel() }
    }

    private func fetchChatRoomEntity(id: UUID) -> ChatRoomEntity? {
        var descriptor = FetchDescriptor<ChatRoomEntity>(
            predicate: #Predicate { entity in entity.id == id }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    // MARK: - 전체 삭제 (개발용)
    func resetAllData() {
        do {
            let allRooms = try context.fetch(FetchDescriptor<ChatRoomEntity>())
            for room in allRooms {
                context.delete(room)
            }
            try context.save()
        } catch {
            print("⚠️ Failed to reset all data: \(error)")
        }
    }

    private func resolveOrInsertUserEntity(for user: User) -> UserEntity {
        if let existing = fetchUserEntity(name: user.name) {
            return existing
        } else {
            let newEntity = user.toEntity()
            context.insert(newEntity)
            return newEntity
        }
    }
}
