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
            ChatRoom(name: "Blind Date", participants: [User.me, User.cony], messages: blindDateMessages(), chatType: .blindDate)
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
    let baseDateDay1 = dateFromString("2025-06-27")!

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
    let baseDateDay2 = dateFromString("2025-06-28")!

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
    let baseDateDay3 = dateFromString("2025-06-29")!

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
    let baseDateDay4 = dateFromString("2025-06-30")!

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
    let baseDateDay5 = dateFromString("2025-07-01")!

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
    let baseDateDay6 = dateFromString("2025-07-02")!

    let sixthDateConversation: [any Message] = [
        TextMessage(sender: .me, text: "Hey Cony, how's your Wednesday going?", date: baseDateDay6),
        TextMessage(sender: .cony, text: "Hi! It's going well, just a bit busy. You?", date: baseDateDay6.addingTimeInterval(60)),
        TextMessage(sender: .me, text: "Pretty much the same. Just trying to get through the week.", date: baseDateDay6.addingTimeInterval(120)),
        TextMessage(sender: .cony, text: "Hang in there! The weekend is almost here.", date: baseDateDay6.addingTimeInterval(180)),
        TextMessage(sender: .me, text: "True! Let's make it a good one.", date: baseDateDay6.addingTimeInterval(240)),
        StickerMessage(sender: .cony, sticker: .love, date: baseDateDay6.addingTimeInterval(300))
    ]

    // Day 7 Conversation - 갑자기 만나서 피크닉 다녀오고, 저녁에 이어진 대화
    let baseDateDay7 = dateFromString("2025-07-03")!

    let seventhDateConversation: [any Message] = [
        TextMessage(sender: .me, text: "Hey Cony! Want to meet up again today?", date: baseDateDay7),
        TextMessage(sender: .cony, text: "Hi! I’d love to. What do you have in mind?", date: baseDateDay7.addingTimeInterval(60)),
        TextMessage(sender: .me, text: "Maybe another hike or a picnic?", date: baseDateDay7.addingTimeInterval(120)),
        TextMessage(sender: .cony, text: "Both sound great! Let’s decide based on the weather.", date: baseDateDay7.addingTimeInterval(180)),
        TextMessage(sender: .me, text: "Sounds good. I’ll keep an eye on the forecast.", date: baseDateDay7.addingTimeInterval(240)),
        TextMessage(sender: .cony, text: "Looking forward to it!", date: baseDateDay7.addingTimeInterval(300)),
        StickerMessage(sender: .me, sticker: .joy, date: baseDateDay7.addingTimeInterval(360)),
        // Additional conversation
//        TextMessage(sender: .me, text: "I really enjoyed our meeting today. Did you get home safely?", date: baseDateDay7.addingTimeInterval(36000)),
//        TextMessage(sender: .cony, text: "Yes! I had a lot of fun too. Thank you so much for dinner. Next time, I'll treat you.", date: baseDateDay7.addingTimeInterval(36480)),
//        TextMessage(sender: .me, text: "Then how about we go see a movie next time?", date: baseDateDay7.addingTimeInterval(36540)),
//        TextMessage(sender: .cony, text: "Sounds great!", date: baseDateDay7.addingTimeInterval(36600))
    ]
    
    return firstDateConversation + secondDateConversation + thirdDateConversation + fourthDateConversation + fifthDateConversation + sixthDateConversation + seventhDateConversation

}
