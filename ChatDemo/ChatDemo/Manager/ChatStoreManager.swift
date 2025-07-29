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
    
    func removeMessage(_ message: any Message, from chatRoom: ChatRoom) {
        guard let roomEntity = fetchChatRoomEntity(id: chatRoom.id) else { return }

        // 해당 메시지에 해당하는 엔티티 찾기
        if let target = roomEntity.messages.first(where: { $0.id == message.id }) {
            roomEntity.messages.removeAll { $0.id == message.id }
            context.delete(target)
            try? context.save()
        }
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
        let baseDate = dateFromString("2025-06-19")!

        let day1Messages: [any Message] = [
            TextMessage(sender: .me, text: "I saw a really cheap ticket to Jeju Island.", date: baseDate),
            TextMessage(sender: .junhyuk, text: "Really? When are you thinking of going?", date: baseDate.addingTimeInterval(60)),
            TextMessage(sender: .me, text: "Maybe next weekend. Who’s in?", date: baseDate.addingTimeInterval(120)),
            TextMessage(sender: .hyeonji, text: "Count me in! I’ve been dying to get out of Seoul.", date: baseDate.addingTimeInterval(180)),
            StickerMessage(sender: .jongyoun, sticker: .love, date: baseDate.addingTimeInterval(240)),
            TextMessage(sender: .wonseob, text: "What’s the plan? Beach? Hiking?", date: baseDate.addingTimeInterval(300)),
            TextMessage(sender: .me, text: "A bit of everything. And of course, black pork BBQ.", date: baseDate.addingTimeInterval(360)),
            TextMessage(sender: .junhyuk, text: "We should rent scooters again like last time.", date: baseDate.addingTimeInterval(420)),
            StickerMessage(sender: .me, sticker: .joy, date: baseDate.addingTimeInterval(480)),
            TextMessage(sender: .hyeonji, text: "Can we stay near the ocean? I want to hear the waves at night.", date: baseDate.addingTimeInterval(540)),
            TextMessage(sender: .wonseob, text: "I’ll find us an Airbnb. Leave it to me.", date: baseDate.addingTimeInterval(600)),
            TextMessage(sender: .jongyoun, text: "No haunted houses this time, please.", date: baseDate.addingTimeInterval(660)),
            TextMessage(sender: .me, text: "Haha, yeah last time was wild.", date: baseDate.addingTimeInterval(720)),
            StickerMessage(sender: .junhyuk, sticker: .amazing, date: baseDate.addingTimeInterval(780)),
            TextMessage(sender: .me, text: "Flights are 69,000 won round trip. Should I book?", date: baseDate.addingTimeInterval(840)),
            TextMessage(sender: .hyeonji, text: "Do it!!", date: baseDate.addingTimeInterval(900)),
            TextMessage(sender: .wonseob, text: "Done. I’ll start a group itinerary.", date: baseDate.addingTimeInterval(960)),
            TextMessage(sender: .me, text: "This is going to be the best trip of the year.", date: baseDate.addingTimeInterval(1020)),
            TextMessage(sender: .jongyoun, text: "Let's bring board games this time too.", date: baseDate.addingTimeInterval(1080)),
            StickerMessage(sender: .hyeonji, sticker: .joy, date: baseDate.addingTimeInterval(1140)),
            TextMessage(sender: .junhyuk, text: "I can already feel the breeze!", date: baseDate.addingTimeInterval(1200)),
            TextMessage(sender: .me, text: "Summer, here we come!", date: baseDate.addingTimeInterval(1260)),
        ]
        
        let baseDate2 = dateFromString("2025-06-20")!
        
        let day2Messages: [any Message] = [
            TextMessage(sender: .me, text: "Is it just me, or was today’s meeting endless?", date: baseDate2),
            TextMessage(sender: .junhyuk, text: "You’re not alone. I almost fell asleep during the roadmap discussion.", date: baseDate2.addingTimeInterval(60)),
            TextMessage(sender: .jongyoun, text: "They really need to learn what 'concise' means.", date: baseDate2.addingTimeInterval(120)),
            StickerMessage(sender: .hyeonji, sticker: .angry, date: baseDate2.addingTimeInterval(180)),
            TextMessage(sender: .wonseob, text: "The part about ‘synergy’ almost killed me.", date: baseDate2.addingTimeInterval(240)),
            TextMessage(sender: .me, text: "And we’re doing another sprint review tomorrow?", date: baseDate2.addingTimeInterval(300)),
            TextMessage(sender: .hyeonji, text: "Let me live, please.", date: baseDate2.addingTimeInterval(360)),
            TextMessage(sender: .junhyuk, text: "Do we even have the new design ready?", date: baseDate2.addingTimeInterval(420)),
            TextMessage(sender: .me, text: "Nope. Still waiting on feedback from product team.", date: baseDate2.addingTimeInterval(480)),
            TextMessage(sender: .jongyoun, text: "They always say ‘ASAP’ but then disappear for 3 days.", date: baseDate2.addingTimeInterval(540)),
            StickerMessage(sender: .wonseob, sticker: .angry, date: baseDate2.addingTimeInterval(600)),
            TextMessage(sender: .me, text: "I’m just gonna make coffee and ignore Slack.", date: baseDate2.addingTimeInterval(660)),
            TextMessage(sender: .hyeonji, text: "Can I join your coping strategy?", date: baseDate2.addingTimeInterval(720)),
            TextMessage(sender: .junhyuk, text: "I already bought snacks for the emergency drawer.", date: baseDate2.addingTimeInterval(780)),
            TextMessage(sender: .me, text: "Let’s do a 'no meetings day' petition.", date: baseDate2.addingTimeInterval(840)),
            TextMessage(sender: .jongyoun, text: "I’ll sign it twice.", date: baseDate2.addingTimeInterval(900)),
            TextMessage(sender: .wonseob, text: "Can we add a mandatory nap time too?", date: baseDate2.addingTimeInterval(960)),
            StickerMessage(sender: .me, sticker: .sad, date: baseDate2.addingTimeInterval(1020)),
            TextMessage(sender: .hyeonji, text: "Okay but seriously, what do we present tomorrow?", date: baseDate2.addingTimeInterval(1080)),
            TextMessage(sender: .me, text: "We fake it. Like always.", date: baseDate2.addingTimeInterval(1140)),
            TextMessage(sender: .junhyuk, text: "I love how we’re all in sync, just exhausted.", date: baseDate2.addingTimeInterval(1200)),
            TextMessage(sender: .me, text: "Surviving together is still surviving.", date: baseDate2.addingTimeInterval(1260))
        ]
        
        let baseDate3 = dateFromString("2025-06-21")!

        let day3Messages: [any Message] = [
            TextMessage(sender: .me, text: "So… I went on a date yesterday.", date: baseDate3),
            TextMessage(sender: .hyeonji, text: "WHAT?! Details. Now.", date: baseDate3.addingTimeInterval(60)),
            TextMessage(sender: .junhyuk, text: "Wait, who??", date: baseDate3.addingTimeInterval(120)),
            TextMessage(sender: .me, text: "That person I met at the cafe last week.", date: baseDate3.addingTimeInterval(180)),
            TextMessage(sender: .wonseob, text: "The barista one?!", date: baseDate3.addingTimeInterval(240)),
            StickerMessage(sender: .hyeonji, sticker: .amazing, date: baseDate3.addingTimeInterval(300)),
            TextMessage(sender: .me, text: "Yup. We grabbed dinner and talked for 3 hours.", date: baseDate3.addingTimeInterval(360)),
            TextMessage(sender: .jongyoun, text: "That sounds like a movie scene.", date: baseDate3.addingTimeInterval(420)),
            TextMessage(sender: .hyeonji, text: "I’m literally squealing. Was there a spark?", date: baseDate3.addingTimeInterval(480)),
            TextMessage(sender: .me, text: "There was… something. Butterflies for sure.", date: baseDate3.addingTimeInterval(540)),
            TextMessage(sender: .junhyuk, text: "I demand to see a photo.", date: baseDate3.addingTimeInterval(600)),
            TextMessage(sender: .me, text: "Maybe later. But they're super kind. Easy to talk to.", date: baseDate3.addingTimeInterval(660)),
            StickerMessage(sender: .wonseob, sticker: .joy, date: baseDate3.addingTimeInterval(720)),
            TextMessage(sender: .jongyoun, text: "You deserve this. Seriously.", date: baseDate3.addingTimeInterval(780)),
            TextMessage(sender: .me, text: "Thank you. I’ve been smiling all day.", date: baseDate3.addingTimeInterval(840)),
            TextMessage(sender: .hyeonji, text: "Manifesting a second date. WHEN?", date: baseDate3.addingTimeInterval(900)),
            TextMessage(sender: .me, text: "We’re meeting again next Thursday.", date: baseDate3.addingTimeInterval(960)),
            TextMessage(sender: .junhyuk, text: "Please live text us the whole thing.", date: baseDate3.addingTimeInterval(1020)),
            TextMessage(sender: .me, text: "You’ll be the first to know.", date: baseDate3.addingTimeInterval(1080)),
            TextMessage(sender: .wonseob, text: "Proud of you. It’s hard putting yourself out there.", date: baseDate3.addingTimeInterval(1140)),
            TextMessage(sender: .me, text: "It is. But feels worth it this time.", date: baseDate3.addingTimeInterval(1200))
        ]
        
        let baseDate4 = dateFromString("2025-06-22")!

        let day4Messages: [any Message] = [
            TextMessage(sender: .me, text: "I bought a new pair of sneakers yesterday.", date: baseDate4),
            TextMessage(sender: .jongyoun, text: "Another one? How many is that now?", date: baseDate4.addingTimeInterval(60)),
            TextMessage(sender: .me, text: "Don’t judge. They were on sale!", date: baseDate4.addingTimeInterval(120)),
            TextMessage(sender: .wonseob, text: "Sales are the enemy of budgets.", date: baseDate4.addingTimeInterval(180)),
            TextMessage(sender: .me, text: "Okay, but listen, it was 40% off.", date: baseDate4.addingTimeInterval(240)),
            TextMessage(sender: .hyeonji, text: "Sneaker therapy is real. I support you.", date: baseDate4.addingTimeInterval(300)),
            TextMessage(sender: .junhyuk, text: "I almost bought a tablet I don’t need. We all struggle.", date: baseDate4.addingTimeInterval(360)),
            TextMessage(sender: .me, text: "What stopped you?", date: baseDate4.addingTimeInterval(420)),
            TextMessage(sender: .junhyuk, text: "My bank account balance.", date: baseDate4.addingTimeInterval(480)),
            StickerMessage(sender: .jongyoun, sticker: .angry, date: baseDate4.addingTimeInterval(540)),
            TextMessage(sender: .wonseob, text: "You know what’s not 40% off? Rent.", date: baseDate4.addingTimeInterval(600)),
            TextMessage(sender: .me, text: "Why are you attacking me with facts.", date: baseDate4.addingTimeInterval(660)),
            TextMessage(sender: .hyeonji, text: "I started using that finance app. It’s terrifying.", date: baseDate4.addingTimeInterval(720)),
            TextMessage(sender: .me, text: "Oh, the one that tracks subscriptions too?", date: baseDate4.addingTimeInterval(780)),
            TextMessage(sender: .hyeonji, text: "Yes. I was paying for 3 cloud storages I didn’t use.", date: baseDate4.addingTimeInterval(840)),
            TextMessage(sender: .junhyuk, text: "That’s… impressive in the worst way.", date: baseDate4.addingTimeInterval(900)),
            TextMessage(sender: .me, text: "Maybe we should do a no-spend week.", date: baseDate4.addingTimeInterval(960)),
            TextMessage(sender: .jongyoun, text: "I’m in. But coffee doesn’t count, right?", date: baseDate4.addingTimeInterval(1020)),
            TextMessage(sender: .me, text: "Of course not. That’s essential.", date: baseDate4.addingTimeInterval(1080)),
            TextMessage(sender: .wonseob, text: "We can’t be broke *and* caffeine-deprived.", date: baseDate4.addingTimeInterval(1140)),
            StickerMessage(sender: .me, sticker: .joy, date: baseDate4.addingTimeInterval(1200))
        ]
        
        let baseDate5 = dateFromString("2025-06-23")!

        let day5Messages: [any Message] = [
            TextMessage(sender: .me, text: "I started my day with a green smoothie today.", date: baseDate5),
            TextMessage(sender: .hyeonji, text: "Wow, who are you and what did you do with real-you?", date: baseDate5.addingTimeInterval(60)),
            TextMessage(sender: .me, text: "I’m trying to be healthy. My stomach was growling all night.", date: baseDate5.addingTimeInterval(120)),
            TextMessage(sender: .junhyuk, text: "Did you put kale in it? Or just blended ice cream and called it healthy?", date: baseDate5.addingTimeInterval(180)),
            TextMessage(sender: .me, text: "Kale, banana, almond milk. I'm serious this time.", date: baseDate5.addingTimeInterval(240)),
            TextMessage(sender: .wonseob, text: "Respect. I had ramyeon for breakfast.", date: baseDate5.addingTimeInterval(300)),
            TextMessage(sender: .jongyoun, text: "Classic. Add an egg and it's a balanced meal.", date: baseDate5.addingTimeInterval(360)),
            StickerMessage(sender: .me, sticker: .amazing, date: baseDate5.addingTimeInterval(420)),
            TextMessage(sender: .hyeonji, text: "I’ve been meal prepping these days. Feels good to eat proper food.", date: baseDate5.addingTimeInterval(480)),
            TextMessage(sender: .me, text: "Can you share your recipes? I’m out of ideas already.", date: baseDate5.addingTimeInterval(540)),
            TextMessage(sender: .hyeonji, text: "Sure! Sweet potato + chicken + greens is my go-to.", date: baseDate5.addingTimeInterval(600)),
            TextMessage(sender: .junhyuk, text: "Sounds healthy. I miss junk food already.", date: baseDate5.addingTimeInterval(660)),
            TextMessage(sender: .me, text: "It’s only Monday. Don’t give up yet.", date: baseDate5.addingTimeInterval(720)),
            TextMessage(sender: .wonseob, text: "Let’s all do a healthy lunch challenge this week?", date: baseDate5.addingTimeInterval(780)),
            TextMessage(sender: .jongyoun, text: "Do healthy snacks count too? I bought protein bars.", date: baseDate5.addingTimeInterval(840)),
            TextMessage(sender: .me, text: "If it’s not chocolate-coated, I’ll allow it.", date: baseDate5.addingTimeInterval(900)),
            TextMessage(sender: .hyeonji, text: "Let’s share meal pics in here too. For accountability.", date: baseDate5.addingTimeInterval(960)),
            TextMessage(sender: .junhyuk, text: "Then I’m skipping meals so I don’t have to post.", date: baseDate5.addingTimeInterval(1020)),
            TextMessage(sender: .me, text: "That’s not how this works!", date: baseDate5.addingTimeInterval(1080)),
            StickerMessage(sender: .wonseob, sticker: .joy, date: baseDate5.addingTimeInterval(1140))
        ]
        
        let baseDate6 = dateFromString("2025-06-24")!

        let day6Messages: [any Message] = [
            TextMessage(sender: .me, text: "This weather makes me want to travel somewhere.", date: baseDate6),
            TextMessage(sender: .jongyoun, text: "Same. It’s so sunny I feel like I’m wasting it indoors.", date: baseDate6.addingTimeInterval(60)),
            TextMessage(sender: .hyeonji, text: "Let’s plan a trip for real. We’ve been talking about it for months.", date: baseDate6.addingTimeInterval(120)),
            TextMessage(sender: .wonseob, text: "Can we go somewhere with both mountains and a beach?", date: baseDate6.addingTimeInterval(180)),
            TextMessage(sender: .junhyuk, text: "That sounds like a budget-destroyer.", date: baseDate6.addingTimeInterval(240)),
            StickerMessage(sender: .me, sticker: .joy, date: baseDate6.addingTimeInterval(300)),
            TextMessage(sender: .me, text: "Let’s make a group plan. I can do the logistics.", date: baseDate6.addingTimeInterval(360)),
            TextMessage(sender: .jongyoun, text: "I’m in. I need a break from work anyway.", date: baseDate6.addingTimeInterval(420)),
            TextMessage(sender: .hyeonji, text: "Same. Somewhere not too hot though.", date: baseDate6.addingTimeInterval(480)),
            TextMessage(sender: .wonseob, text: "Jeju again?", date: baseDate6.addingTimeInterval(540)),
            TextMessage(sender: .me, text: "Hmm… too familiar maybe. How about Gangneung?", date: baseDate6.addingTimeInterval(600)),
            TextMessage(sender: .junhyuk, text: "Love that idea. The sea food there is amazing.", date: baseDate6.addingTimeInterval(660)),
            TextMessage(sender: .me, text: "And we can go surfing again!", date: baseDate6.addingTimeInterval(720)),
            TextMessage(sender: .jongyoun, text: "I call dibs on not falling off the board this time.", date: baseDate6.addingTimeInterval(780)),
            TextMessage(sender: .hyeonji, text: "Let’s bring board games too. For the night.", date: baseDate6.addingTimeInterval(840)),
            TextMessage(sender: .wonseob, text: "Camping + surfing + board games. What a combo.", date: baseDate6.addingTimeInterval(900)),
            TextMessage(sender: .junhyuk, text: "We should start packing already at this point.", date: baseDate6.addingTimeInterval(960)),
            TextMessage(sender: .me, text: "I’ll make a checklist and share it here.", date: baseDate6.addingTimeInterval(1020)),
            TextMessage(sender: .hyeonji, text: "Should we do a vote for the exact dates?", date: baseDate6.addingTimeInterval(1080)),
            StickerMessage(sender: .wonseob, sticker: .amazing, date: baseDate6.addingTimeInterval(1140))
        ]

        let baseDate7 = dateFromString("2025-06-25")!

        let day7Messages: [any Message] = [
            TextMessage(sender: .me, text: "It’s already Wednesday night. This week flew by.", date: baseDate7),
            TextMessage(sender: .junhyuk, text: "Yeah… and it’s been a heavy one somehow.", date: baseDate7.addingTimeInterval(60)),
            TextMessage(sender: .hyeonji, text: "I felt that too. Like I’m tired, but not from doing much.", date: baseDate7.addingTimeInterval(120)),
            TextMessage(sender: .wonseob, text: "Maybe it's just emotional fatigue.", date: baseDate7.addingTimeInterval(180)),
            TextMessage(sender: .jongyoun, text: "We did talk about a lot of things recently. Good things, tough things.", date: baseDate7.addingTimeInterval(240)),
            StickerMessage(sender: .me, sticker: .sad, date: baseDate7.addingTimeInterval(300)),
            TextMessage(sender: .me, text: "But I honestly appreciate that we can have these talks.", date: baseDate7.addingTimeInterval(360)),
            TextMessage(sender: .hyeonji, text: "Same. It’s rare to have friends you can really open up to.", date: baseDate7.addingTimeInterval(420)),
            TextMessage(sender: .junhyuk, text: "We’ve known each other so long… I think that makes it easier.", date: baseDate7.addingTimeInterval(480)),
            TextMessage(sender: .jongyoun, text: "But we’ve also chosen to stay close. That’s not automatic.", date: baseDate7.addingTimeInterval(540)),
            TextMessage(sender: .wonseob, text: "Well, I choose you guys again next week too.", date: baseDate7.addingTimeInterval(600)),
            StickerMessage(sender: .hyeonji, sticker: .love, date: baseDate7.addingTimeInterval(660)),
            TextMessage(sender: .me, text: "Haha. Let's try to rest this weekend though.", date: baseDate7.addingTimeInterval(720)),
            TextMessage(sender: .junhyuk, text: "Agreed. No obligations. Just food and chill.", date: baseDate7.addingTimeInterval(780)),
            TextMessage(sender: .jongyoun, text: "Sounds like the perfect plan.", date: baseDate7.addingTimeInterval(840)),
            TextMessage(sender: .me, text: "Thanks for always being here, all of you.", date: baseDate7.addingTimeInterval(900)),
            TextMessage(sender: .hyeonji, text: "Let’s keep showing up for each other.", date: baseDate7.addingTimeInterval(960)),
            TextMessage(sender: .wonseob, text: "Yeah. One chat at a time.", date: baseDate7.addingTimeInterval(1020)),
            StickerMessage(sender: .me, sticker: .love, date: baseDate7.addingTimeInterval(1080)),
            TextMessage(sender: .me, text: "Good night, everyone.", date: baseDate7.addingTimeInterval(1140)),
            TextMessage(sender: .junhyuk, text: "Good night.", date: baseDate7.addingTimeInterval(1200)),
            TextMessage(sender: .hyeonji, text: "Night!", date: baseDate7.addingTimeInterval(1260)),
            TextMessage(sender: .wonseob, text: "Sleep well.", date: baseDate7.addingTimeInterval(1320))
        ]

        
        return [
            ChatRoom(name: "Chat Bot", participants: [User.bot, User.me], messages: [], chatType: .bot),
            ChatRoom(
                name: "Friends",
                participants: [User.me] + User.friends,
                messages: day1Messages + day2Messages + day3Messages + day4Messages + day5Messages + day6Messages + day7Messages,
                chatType: .friend
            ),
            ChatRoom(name: "Blind Date", participants: [User.me, User.cony], messages: blindDateMessages(), chatType: .blindDate),
            ChatRoom(name: "Summary", participants: [User.me] + User.friends, messages: summarizeMessages(), chatType: .friend),
            ChatRoom(name: "Summary - Korean", participants: [User.me] + User.friends, messages: summarizeMessagesKorean(), chatType: .friend),
            ChatRoom(name: "Summary - Japanese", participants: [User.me] + User.friends, messages: summarizeMessagesJapanese(), chatType: .friend),
            ChatRoom(name: "Sticker", participants: [User.me] + User.friends, messages: stickerMessages(), chatType: .friend),
            ChatRoom(name: "Album", participants: [User.me] + User.friends, messages: albumMessages(), chatType: .friend),
            ChatRoom(name: "Emotion", participants: [User.me] + User.friends, messages: sentimentMessages(), chatType: .friend),
            ChatRoom(name: "Translate", participants: [User.me] + User.friends, messages: translateMessages(), chatType: .friend),
            ChatRoom(name: "Font", participants: [User.me] + User.friends, messages: fontConversationMessages(), chatType: .friend),
            ChatRoom(name: "Spam", participants: [User.me] + User.friends, messages: investmentInvitationMessages(), chatType: .friend),

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

func dateFromString(_ dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX") // 항상 고정된 포맷을 쓰고 싶을 때
    formatter.timeZone = TimeZone(secondsFromGMT: 0) // 필요에 따라 조정

    return formatter.date(from: dateString)
}

func blindDateMessages() -> [any Message] {
    // Day 1 Conversation - 자기소개 및 취미 공유
    let baseDateDay1 = dateFromString("2025-07-03")!

    let firstDateConversation: [any Message] = [
        TextMessage(sender: .me, text: "Hey Cony! It's nice to finally meet you.", date: baseDateDay1),
        TextMessage(sender: .cony, text: "Hi! Yeah, I've been looking forward to this.", date: baseDateDay1.addingTimeInterval(60)),
        TextMessage(sender: .me, text: "Same here. So, tell me a bit about yourself.", date: baseDateDay1.addingTimeInterval(120)),
        TextMessage(sender: .cony, text: "Well, I love hiking and exploring new places. How about you?", date: baseDateDay1.addingTimeInterval(180)),
        TextMessage(sender: .me, text: "I'm into photography, always looking for new spots to capture.", date: baseDateDay1.addingTimeInterval(240)),
        TextMessage(sender: .cony, text: "That's awesome! Maybe we can go hiking together sometime.", date: baseDateDay1.addingTimeInterval(300)),
        StickerMessage(sender: .me, sticker: .joy, date: baseDateDay1.addingTimeInterval(360)),
        TextMessage(sender: .me, text: "I'd love that. Do you have any favorite trails?", date: baseDateDay1.addingTimeInterval(420)),
        TextMessage(sender: .cony, text: "There's a beautiful one near the lake. It's peaceful and has great views.", date: baseDateDay1.addingTimeInterval(480)),
        TextMessage(sender: .me, text: "Sounds perfect. Let's plan for it soon.", date: baseDateDay1.addingTimeInterval(540)),
        TextMessage(sender: .cony, text: "Definitely! I'm glad we're doing this.", date: baseDateDay1.addingTimeInterval(600)),
        TextMessage(sender: .me, text: "Me too. Here's to new adventures!", date: baseDateDay1.addingTimeInterval(660)),
        StickerMessage(sender: .cony, sticker: .love, date: baseDateDay1.addingTimeInterval(720))
    ]

    // Day 2 Conversation - 일요일에 만나자고 약속잡기
    let baseDateDay2 = dateFromString("2025-07-04")!

    let secondDateConversation: [any Message] = [
        TextMessage(sender: .me, text: "Hey Cony, how's your day going?", date: baseDateDay2),
        TextMessage(sender: .cony, text: "Hi! It's going well, just finished a meeting. You?", date: baseDateDay2.addingTimeInterval(60)),
        TextMessage(sender: .me, text: "Pretty good, just wrapping up some work. Want to meet up this Sunday?", date: baseDateDay2.addingTimeInterval(120)),
        TextMessage(sender: .cony, text: "Sure! What do you have in mind?", date: baseDateDay2.addingTimeInterval(180)),
        TextMessage(sender: .me, text: "How about a hike and then lunch?", date: baseDateDay2.addingTimeInterval(240)),
        StickerMessage(sender: .cony, sticker: .joy, date: baseDateDay2.addingTimeInterval(300)),
        TextMessage(sender: .cony, text: "Sounds perfect! What time?", date: baseDateDay2.addingTimeInterval(360)),
        TextMessage(sender: .me, text: "Let's meet at 10 AM.", date: baseDateDay2.addingTimeInterval(420)),
        TextMessage(sender: .cony, text: "Looking forward to it!", date: baseDateDay2.addingTimeInterval(480)),
        StickerMessage(sender: .cony, sticker: .love, date: baseDateDay2.addingTimeInterval(540))
    ]

    // Day 3 Conversation - 약속장소에 도착했다는 내용, 저녁엔 오늘 즐거웠다는 대화
    let baseDateDay3 = dateFromString("2025-07-05")!

    let thirdDateConversation: [any Message] = [
        TextMessage(sender: .me, text: "Hey Cony, I just arrived at the meeting spot.", date: baseDateDay3),
        TextMessage(sender: .cony, text: "Great! I'm almost there too.", date: baseDateDay3.addingTimeInterval(60)),
        TextMessage(sender: .me, text: "No rush, see you soon!", date: baseDateDay3.addingTimeInterval(120)),
        // Evening conversation
        TextMessage(sender: .me, text: "Today was really fun, Cony.", date: baseDateDay3.addingTimeInterval(3600)),
        TextMessage(sender: .cony, text: "I had a great time too! Thanks for suggesting this.", date: baseDateDay3.addingTimeInterval(3660)),
        TextMessage(sender: .me, text: "Looking forward to our next adventure.", date: baseDateDay3.addingTimeInterval(3720)),
        StickerMessage(sender: .cony, sticker: .love, date: baseDateDay3.addingTimeInterval(3780))
    ]

    // Day 4 Conversation - 일상공유
    let baseDateDay4 = dateFromString("2025-07-06")!

    let fourthDateConversation: [any Message] = [
        TextMessage(sender: .me, text: "Good morning, Cony! How's your Monday?", date: baseDateDay4),
        TextMessage(sender: .cony, text: "Morning! It's a bit hectic, but manageable. How about you?", date: baseDateDay4.addingTimeInterval(60)),
        TextMessage(sender: .me, text: "Same here, just getting through the usual grind.", date: baseDateDay4.addingTimeInterval(120)),
        TextMessage(sender: .cony, text: "Anything exciting planned for the week?", date: baseDateDay4.addingTimeInterval(180)),
        TextMessage(sender: .me, text: "Not much, just the usual work stuff. You?", date: baseDateDay4.addingTimeInterval(240)),
        TextMessage(sender: .cony, text: "Same here. Let's catch up again soon!", date: baseDateDay4.addingTimeInterval(300)),
        StickerMessage(sender: .me, sticker: .joy, date: baseDateDay4.addingTimeInterval(360))
    ]

    // Day 5 Conversation - 저녁에 갑자기 만나서 가볍게 맥주마시자는 내용
    let baseDateDay5 = dateFromString("2025-07-07")!

    let fifthDateConversation: [any Message] = [
        TextMessage(sender: .me, text: "Hey Cony, are you free tonight?", date: baseDateDay5),
        TextMessage(sender: .cony, text: "Hi! I think I can be. What's up?", date: baseDateDay5.addingTimeInterval(60)),
        TextMessage(sender: .me, text: "Want to grab a beer and catch up?", date: baseDateDay5.addingTimeInterval(120)),
        TextMessage(sender: .cony, text: "That sounds great! What time?", date: baseDateDay5.addingTimeInterval(180)),
        TextMessage(sender: .me, text: "How about 7 PM at our usual spot?", date: baseDateDay5.addingTimeInterval(240)),
        TextMessage(sender: .cony, text: "Perfect, see you then!", date: baseDateDay5.addingTimeInterval(300)),
        StickerMessage(sender: .cony, sticker: .amazing, date: baseDateDay5.addingTimeInterval(360))
    ]

    // Day 6 Conversation - 일상공유
    let baseDateDay6 = dateFromString("2025-07-08")!

    let sixthDateConversation: [any Message] = [
        TextMessage(sender: .me, text: "Hey Cony, how's your Wednesday going?", date: baseDateDay6),
        TextMessage(sender: .cony, text: "Hi! It's going well, just a bit busy. You?", date: baseDateDay6.addingTimeInterval(60)),
        TextMessage(sender: .me, text: "Pretty much the same. Just trying to get through the week.", date: baseDateDay6.addingTimeInterval(120)),
        TextMessage(sender: .cony, text: "Hang in there! The weekend is almost here.", date: baseDateDay6.addingTimeInterval(180)),
        TextMessage(sender: .me, text: "True! Let's make it a good one.", date: baseDateDay6.addingTimeInterval(240)),
        StickerMessage(sender: .cony, sticker: .love, date: baseDateDay6.addingTimeInterval(300))
    ]

    // Day 7 Conversation - 갑자기 만나서 피크닉 다녀오고, 저녁에 이어진 대화
    let baseDateDay7 = dateFromString("2025-07-09")!

    let seventhDateConversation: [any Message] = [
        TextMessage(sender: .me, text: "Hey Cony! Want to meet up again today?", date: baseDateDay7),
        TextMessage(sender: .cony, text: "Hi! I’d love to. What do you have in mind?", date: baseDateDay7.addingTimeInterval(60)),
        TextMessage(sender: .me, text: "Maybe another hike or a picnic?", date: baseDateDay7.addingTimeInterval(120)),
        TextMessage(sender: .cony, text: "Both sound great! Let’s decide based on the weather.", date: baseDateDay7.addingTimeInterval(180)),
        TextMessage(sender: .me, text: "Sounds good. I’ll keep an eye on the forecast.", date: baseDateDay7.addingTimeInterval(240)),
        TextMessage(sender: .cony, text: "Looking forward to it!", date: baseDateDay7.addingTimeInterval(300)),
        StickerMessage(sender: .me, sticker: .joy, date: baseDateDay7.addingTimeInterval(360)),
        // Additional conversation
        TextMessage(sender: .me, text: "I really enjoyed our meeting today. Did you get home safely?", date: baseDateDay7.addingTimeInterval(36000)),
        TextMessage(sender: .cony, text: "Yes! I had a lot of fun too. Thank you so much for dinner. Next time, I'll treat you.", date: baseDateDay7.addingTimeInterval(36480)),
        TextMessage(sender: .me, text: "Then how about we go see a movie next time?", date: baseDateDay7.addingTimeInterval(36540)),
        TextMessage(sender: .cony, text: "Sounds great!", date: baseDateDay7.addingTimeInterval(36600))
    ]
    
    return firstDateConversation + secondDateConversation + thirdDateConversation + fourthDateConversation + fifthDateConversation + sixthDateConversation + seventhDateConversation

}


func summarizeMessages() -> [any Message] {
    let baseDateDay1 = dateFromString("2025-07-09")!

    return [
        TextMessage(sender: User.junhyuk, text: "Hey everyone, do we have any ideas for the team dinner?", date: baseDateDay1),
        TextMessage(sender: User.me, text: "Hey! Just got back from a meeting. I'm good with anything, but something hearty would be nice.", date: baseDateDay1.addingTimeInterval(60)),
        TextMessage(sender: User.hyeonji, text: "Hi hi! Korean BBQ, anyone?", date: baseDateDay1.addingTimeInterval(120)),
        TextMessage(sender: User.wonseob, text: "Hey all. Korean BBQ sounds good, but haven’t we had that like twice this month?", date: baseDateDay1.addingTimeInterval(180)),
        TextMessage(sender: User.jongyoun, text: "Yeah, I think we had it last week too.", date: baseDateDay1.addingTimeInterval(240)),
        TextMessage(sender: User.hyeonji, text: "Oh right, forgot about that. Then maybe something different...", date: baseDateDay1.addingTimeInterval(300)),
        TextMessage(sender: User.me, text: "I’d be up for trying something new too.", date: baseDateDay1.addingTimeInterval(360)),
        TextMessage(sender: User.junhyuk, text: "Same here. Any suggestions?", date: baseDateDay1.addingTimeInterval(420)),
        TextMessage(sender: User.hyeonji, text: "Hmm... then how about grilled eel? It’s supposed to be great for stamina.", date: baseDateDay1.addingTimeInterval(480)),
        TextMessage(sender: User.wonseob, text: "Interesting choice! Haven’t had that in a while.", date: baseDateDay1.addingTimeInterval(540)),
        TextMessage(sender: User.jongyoun, text: "Actually, that sounds pretty good.", date: baseDateDay1.addingTimeInterval(600)),
        TextMessage(sender: User.me, text: "Yeah, grilled eel sounds amazing. Good idea.", date: baseDateDay1.addingTimeInterval(660)),
        TextMessage(sender: User.junhyuk, text: "I’m in. Let's go with that.", date: baseDateDay1.addingTimeInterval(720)),
        TextMessage(sender: User.wonseob, text: "I'm down. When and where?", date: baseDateDay1.addingTimeInterval(780)),
        TextMessage(sender: User.jongyoun, text: "Nice. I’ll look for a place and share the link.", date: baseDateDay1.addingTimeInterval(840)),
        TextMessage(sender: User.hyeonji, text: "Yay, can’t wait!", date: baseDateDay1.addingTimeInterval(900)),
        TextMessage(sender: User.me, text: "Same here. It's been a while since we all hung out like this.", date: baseDateDay1.addingTimeInterval(960))
    ]
}

func summarizeMessagesKorean() -> [any Message] {
    let baseDateDay1 = dateFromString("2025-07-09")!

    return [
        TextMessage(sender: User.junhyuk, text: "여러분, 팀 회식 어디서 할지 아이디어 있어요?", date: baseDateDay1),
        TextMessage(sender: User.me, text: "회의 막 끝났어요! 전 뭐든 괜찮은데, 든든한 거였으면 좋겠어요.", date: baseDateDay1.addingTimeInterval(60)),
        TextMessage(sender: User.hyeonji, text: "안녕하세요~! 고기 어때요, 고기?", date: baseDateDay1.addingTimeInterval(120)),
        TextMessage(sender: User.wonseob, text: "좋긴 한데 이번 달에 벌써 두 번 먹지 않았나요?", date: baseDateDay1.addingTimeInterval(180)),
        TextMessage(sender: User.jongyoun, text: "맞아요, 지난주에도 갔던 것 같아요.", date: baseDateDay1.addingTimeInterval(240)),
        TextMessage(sender: User.hyeonji, text: "아 맞다… 까먹었어요. 그럼 다른 걸로...", date: baseDateDay1.addingTimeInterval(300)),
        TextMessage(sender: User.me, text: "저도 새로운 거 먹고 싶어요.", date: baseDateDay1.addingTimeInterval(360)),
        TextMessage(sender: User.junhyuk, text: "좋아요. 다른 추천은요?", date: baseDateDay1.addingTimeInterval(420)),
        TextMessage(sender: User.hyeonji, text: "그럼 장어구이는 어때요? 몸보신에도 좋대요!", date: baseDateDay1.addingTimeInterval(480)),
        TextMessage(sender: User.wonseob, text: "오! 장어라니 오랜만인데요?", date: baseDateDay1.addingTimeInterval(540)),
        TextMessage(sender: User.jongyoun, text: "생각보다 괜찮은데요?", date: baseDateDay1.addingTimeInterval(600)),
        TextMessage(sender: User.me, text: "좋아요. 장어구이 완전 좋네요.", date: baseDateDay1.addingTimeInterval(660)),
        TextMessage(sender: User.junhyuk, text: "그럼 장어로 결정~", date: baseDateDay1.addingTimeInterval(720)),
        TextMessage(sender: User.wonseob, text: "좋아요! 장소랑 시간은요?", date: baseDateDay1.addingTimeInterval(780)),
        TextMessage(sender: User.jongyoun, text: "제가 장소 찾아보고 링크 공유할게요.", date: baseDateDay1.addingTimeInterval(840)),
        TextMessage(sender: User.hyeonji, text: "꺄, 기대돼요!", date: baseDateDay1.addingTimeInterval(900)),
        TextMessage(sender: User.me, text: "맞아요. 다 같이 모이는 거 진짜 오랜만이네요.", date: baseDateDay1.addingTimeInterval(960))
    ]
}

func summarizeMessagesJapanese() -> [any Message] {
    let baseDateDay1 = dateFromString("2025-07-09")!

    return [
        TextMessage(sender: User.junhyuk, text: "みんな、チームの食事会どうする？アイデアある？", date: baseDateDay1),
        TextMessage(sender: User.me, text: "やっと会議終わった！何でもいいけど、ガッツリ系がいいな。", date: baseDateDay1.addingTimeInterval(60)),
        TextMessage(sender: User.hyeonji, text: "こんにちは〜！焼肉どう？", date: baseDateDay1.addingTimeInterval(120)),
        TextMessage(sender: User.wonseob, text: "いいけど、今月もう2回くらい行ってない？", date: baseDateDay1.addingTimeInterval(180)),
        TextMessage(sender: User.jongyoun, text: "うん、先週も行った気がする。", date: baseDateDay1.addingTimeInterval(240)),
        TextMessage(sender: User.hyeonji, text: "あ、そうだった！じゃあ別のにしよう〜", date: baseDateDay1.addingTimeInterval(300)),
        TextMessage(sender: User.me, text: "新しいのにチャレンジしてみたい！", date: baseDateDay1.addingTimeInterval(360)),
        TextMessage(sender: User.junhyuk, text: "そうだね。何かオススメある？", date: baseDateDay1.addingTimeInterval(420)),
        TextMessage(sender: User.hyeonji, text: "じゃあ、うなぎはどう？スタミナにもいいらしいよ。", date: baseDateDay1.addingTimeInterval(480)),
        TextMessage(sender: User.wonseob, text: "おっ、それは久しぶりかも。", date: baseDateDay1.addingTimeInterval(540)),
        TextMessage(sender: User.jongyoun, text: "実はそれ、いいかも！", date: baseDateDay1.addingTimeInterval(600)),
        TextMessage(sender: User.me, text: "うなぎいいね！美味しそう。", date: baseDateDay1.addingTimeInterval(660)),
        TextMessage(sender: User.junhyuk, text: "じゃあ、それで決まり！", date: baseDateDay1.addingTimeInterval(720)),
        TextMessage(sender: User.wonseob, text: "OK〜！いつ、どこにする？", date: baseDateDay1.addingTimeInterval(780)),
        TextMessage(sender: User.jongyoun, text: "お店探してリンク送るね。", date: baseDateDay1.addingTimeInterval(840)),
        TextMessage(sender: User.hyeonji, text: "楽しみ〜！", date: baseDateDay1.addingTimeInterval(900)),
        TextMessage(sender: User.me, text: "みんなで集まるの、久しぶりだよね。", date: baseDateDay1.addingTimeInterval(960))
    ]
}

func stickerMessages() -> [any Message] {
    let baseDateDay1 = dateFromString("2025-07-09")!

    return [
        TextMessage(sender: User.me, text: "I think today’s meeting went pretty smoothly.", date: baseDateDay1),
        TextMessage(sender: User.junhyuk, text: "Yeah, we actually wrapped up on time for once.", date: baseDateDay1.addingTimeInterval(60)),
        TextMessage(sender: User.jongyoun, text: "That rarely happens. Kind of impressive.", date: baseDateDay1.addingTimeInterval(120)),
        TextMessage(sender: User.hyeonji, text: "Everyone was surprisingly focused today.", date: baseDateDay1.addingTimeInterval(180)),
        TextMessage(sender: User.wonseob, text: "Except when we got sidetracked by the coffee machine discussion.", date: baseDateDay1.addingTimeInterval(240)),
        StickerMessage(sender: User.hyeonji, sticker: .joy, date: baseDateDay1.addingTimeInterval(300)),
        TextMessage(sender: User.me, text: "Wait, that sticker is adorable.", date: baseDateDay1.addingTimeInterval(360)),
        TextMessage(sender: User.junhyuk, text: "I was just about to say that! I’ve never seen that one.", date: baseDateDay1.addingTimeInterval(420)),
        TextMessage(sender: User.jongyoun, text: "Seriously, how do you always have the best stickers?", date: baseDateDay1.addingTimeInterval(480)),
        TextMessage(sender: User.hyeonji, text: "Haha, glad you like it.", date: baseDateDay1.addingTimeInterval(540)),
        TextMessage(sender: User.wonseob, text: "That one fits you perfectly, too.", date: baseDateDay1.addingTimeInterval(600))
    ]
}

func fontConversationMessages() -> [any Message] {
    let baseDateDay1 = dateFromString("2025-07-09")!

    return [
        TextMessage(sender: User.hyeonji, text: "I just got a new font!", date: baseDateDay1),
        TextMessage(sender: User.junhyuk, text: "A new font? What kind?", date: baseDateDay1.addingTimeInterval(60)),
        TextMessage(sender: User.jongyoun, text: "Wait, like a typeface? Show us!", date: baseDateDay1.addingTimeInterval(120)),
        TextMessage(sender: User.wonseob, text: "Did you buy it or was it free?", date: baseDateDay1.addingTimeInterval(180)),
        TextMessage(sender: User.hyeonji, text: "I bought it. It's super clean and stylish—perfect for titles.", date: baseDateDay1.addingTimeInterval(240)),
        TextMessage(sender: User.me, text: "Ooo I’m curious. Can you send a sample?", date: baseDateDay1.addingTimeInterval(300)),
        TextMessage(sender: User.hyeonji, text: "Sure, give me a sec!", date: baseDateDay1.addingTimeInterval(360)),
        StickerMessage(sender: User.hyeonji, sticker: .joy, date: baseDateDay1.addingTimeInterval(420)),
        TextMessage(sender: User.junhyuk, text: "Looks so modern! I love it.", date: baseDateDay1.addingTimeInterval(480)),
        TextMessage(sender: User.jongyoun, text: "What's it called? I might get it too.", date: baseDateDay1.addingTimeInterval(540)),
        TextMessage(sender: User.hyeonji, text: "It’s called ‘Mushin’. Totally worth it.", date: baseDateDay1.addingTimeInterval(600))
    ]
}
func albumMessages() -> [any Message] {
    let baseDateDay1 = dateFromString("2025-07-09")!

    return [
        TextMessage(sender: User.me, text: "Morning everyone. Hope you're not too swamped today.", date: baseDateDay1),
        TextMessage(sender: User.hyeonji, text: "Hey! Feels like a long week already.", date: baseDateDay1.addingTimeInterval(60)),
        TextMessage(sender: User.wonseob, text: "Tell me about it. I haven’t even finished Tuesday’s work.", date: baseDateDay1.addingTimeInterval(120)),
        TextMessage(sender: User.jongyoun, text: "Same here. Can we fast-forward to the weekend?", date: baseDateDay1.addingTimeInterval(180)),
        TextMessage(sender: User.junhyuk, text: "Haha, only if someone finds the remote.", date: baseDateDay1.addingTimeInterval(240)),

        TextMessage(sender: User.me, text: "By the way, remember our trip to Sokcho last spring?", date: baseDateDay1.addingTimeInterval(360)),
        TextMessage(sender: User.hyeonji, text: "Of course! That café by the beach was so relaxing.", date: baseDateDay1.addingTimeInterval(420)),
        TextMessage(sender: User.wonseob, text: "Was that the place with the huge window view?", date: baseDateDay1.addingTimeInterval(480)),
        TextMessage(sender: User.jongyoun, text: "Yeah, and the drinks were overpriced but looked amazing.", date: baseDateDay1.addingTimeInterval(540)),
        TextMessage(sender: User.junhyuk, text: "Didn’t it rain the first day though?", date: baseDateDay1.addingTimeInterval(600)),
        TextMessage(sender: User.me, text: "Yeah, but the sky cleared up just in time for those sunset shots.", date: baseDateDay1.addingTimeInterval(660)),
        TextMessage(sender: User.hyeonji, text: "I still love that photo we took on the rocks. The colors were unreal.", date: baseDateDay1.addingTimeInterval(720)),
        TextMessage(sender: User.jongyoun, text: "Didn’t we post a bunch of those here back then?", date: baseDateDay1.addingTimeInterval(780))
    ]
}

func sentimentMessages() -> [any Message] {
    let baseDateDay1 = dateFromString("2025-07-09")!

    return [
        TextMessage(sender: User.me, text: "The release has been delayed. Again.", date: baseDateDay1),
        TextMessage(sender: User.junhyuk, text: "Of course it has. Why am I not surprised.", date: baseDateDay1.addingTimeInterval(30)),
        TextMessage(sender: User.wonseob, text: "I’m actually angry now. This is the third damn delay this month.", date: baseDateDay1.addingTimeInterval(60)),
        TextMessage(sender: User.junhyuk, text: "Every single time it’s the same excuse.", date: baseDateDay1.addingTimeInterval(90)),
        TextMessage(sender: User.wonseob, text: "This isn’t just frustrating. I’m really angry at how we’re being treated.", date: baseDateDay1.addingTimeInterval(120)),

        TextMessage(sender: User.jongyoun, text: "I was actually really looking forward to the release today...", date: baseDateDay1.addingTimeInterval(180)),
        TextMessage(sender: User.jongyoun, text: "I told my family I’d finally be able to show them something.", date: baseDateDay1.addingTimeInterval(240)),
        TextMessage(sender: User.jongyoun, text: "Now I just feel... deflated.", date: baseDateDay1.addingTimeInterval(300)),

        TextMessage(sender: User.hyeonji, text: "Did anyone try that new matcha place near the office?", date: baseDateDay1.addingTimeInterval(420)),
        TextMessage(sender: User.wonseob, text: "...Hyeonji? Are you even listening? We’re all angry here.", date: baseDateDay1.addingTimeInterval(450)),
        TextMessage(sender: User.hyeonji, text: "What? I got the soft cream latte, and it was amazing.", date: baseDateDay1.addingTimeInterval(480)),
        TextMessage(sender: User.junhyuk, text: "We’re talking about release delays, not desserts.", date: baseDateDay1.addingTimeInterval(510)),
        TextMessage(sender: User.hyeonji, text: "I mean... it helped me feel better, at least.", date: baseDateDay1.addingTimeInterval(540)),

        TextMessage(sender: User.wonseob, text: "That’s great. While you’re out having desserts, I’m stuck being angry at this mess.", date: baseDateDay1.addingTimeInterval(600)),
        TextMessage(sender: User.me, text: "Alright, let’s stay on track.", date: baseDateDay1.addingTimeInterval(660)),

        TextMessage(sender: User.jongyoun, text: "I guess we just wait. Again.", date: baseDateDay1.addingTimeInterval(720)),
        TextMessage(sender: User.junhyuk, text: "Waiting doesn’t fix the process.", date: baseDateDay1.addingTimeInterval(750)),
        TextMessage(sender: User.wonseob, text: "I’m angry because we’ve been completely ignored. Over and over again.", date: baseDateDay1.addingTimeInterval(780)),
        TextMessage(sender: User.me, text: "Let’s regroup tomorrow and plan around the new schedule.", date: baseDateDay1.addingTimeInterval(840))
    ]
}

func translateMessages() -> [any Message] {
    let baseDateDay1 = dateFromString("2025-07-09")!
    
    return [
        TextMessage(sender: User.me, text: "Good morning, everyone!", date: baseDateDay1),
        TextMessage(sender: User.hyeonji, text: "Morning! Did you all sleep well?", date: baseDateDay1.addingTimeInterval(30)),
        TextMessage(sender: User.wonseob, text: "I stayed up too late watching a movie.", date: baseDateDay1.addingTimeInterval(60)),
        TextMessage(sender: User.jongyoun, text: "Same here. What movie did you watch?", date: baseDateDay1.addingTimeInterval(90)),
        TextMessage(sender: User.wonseob, text: "The new sci-fi one on Netflix. It was pretty good.", date: baseDateDay1.addingTimeInterval(120)),
        TextMessage(sender: User.junhyuk, text: "I started that too but fell asleep halfway.", date: baseDateDay1.addingTimeInterval(150)),
        TextMessage(sender: User.me, text: "You guys and your late-night habits.", date: baseDateDay1.addingTimeInterval(180)),
        TextMessage(sender: User.hyeonji, text: "I actually slept early for once.", date: baseDateDay1.addingTimeInterval(210)),
        TextMessage(sender: User.jongyoun, text: "That’s rare! What’s the occasion?", date: baseDateDay1.addingTimeInterval(240)),
        TextMessage(sender: User.hyeonji, text: "Just super tired from yesterday’s meetings.", date: baseDateDay1.addingTimeInterval(270)),
        TextMessage(sender: User.junhyuk, text: "Speaking of which, do we have any today?", date: baseDateDay1.addingTimeInterval(300)),
        TextMessage(sender: User.me, text: "Yeah, just the sync at 2 PM.", date: baseDateDay1.addingTimeInterval(330)),
        TextMessage(sender: User.wonseob, text: "Is it online or in person?", date: baseDateDay1.addingTimeInterval(360)),
        TextMessage(sender: User.me, text: "Online. Link’s in the calendar invite.", date: baseDateDay1.addingTimeInterval(390)),
        TextMessage(sender: User.junhyuk, text: "Cool, thanks.", date: baseDateDay1.addingTimeInterval(420)),
        TextMessage(sender: User.hyeonji, text: "Also, don’t forget to submit your timesheets today.", date: baseDateDay1.addingTimeInterval(450)),
        TextMessage(sender: User.jongyoun, text: "Ugh, thanks for the reminder.", date: baseDateDay1.addingTimeInterval(480)),
        TextMessage(sender: User.me, text: "Let’s all do it right after lunch.", date: baseDateDay1.addingTimeInterval(510)),
        TextMessage(sender: User.wonseob, text: "Agreed. Then I won’t forget.", date: baseDateDay1.addingTimeInterval(540)),
        TextMessage(sender: User.junhyuk, text: "Sounds like a plan.", date: baseDateDay1.addingTimeInterval(570))
    ]
}

func investmentInvitationMessages() -> [any Message] {
    let baseDate = dateFromString("2025-07-09")!

    return [
        TextMessage(sender: User.akihiro, text: "My name is Akihiro Nishino. What should I call you?", date: baseDate),
        TextMessage(sender: User.me, text: "It's Takahashi!", date: baseDate.addingTimeInterval(60)),
        TextMessage(sender: User.akihiro, text: "Want to know about blue chip stocks? Want to learn investment skills?", date: baseDate.addingTimeInterval(120)),
        TextMessage(sender: User.me, text: "I want to learn!", date: baseDate.addingTimeInterval(180)),
        TextMessage(sender: User.akihiro, text: "Do you have investment experience?", date: baseDate.addingTimeInterval(240)),
        TextMessage(sender: User.me, text: "Not!", date: baseDate.addingTimeInterval(300)),
        TextMessage(sender: User.akihiro, text: "Please add official LINE to invite to study group", date: baseDate.addingTimeInterval(360))
    ]
}
