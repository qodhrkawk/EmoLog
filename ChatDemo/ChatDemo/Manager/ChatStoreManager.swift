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
//            ChatRoom(name: "Chat Bot", participants: [User.bot, User.me], messages: [], chatType: .bot),
//            ChatRoom(
//                name: "Friends",
//                participants: [User.me] + User.friends,
//                messages: day1Messages + day2Messages + day3Messages + day4Messages + day5Messages + day6Messages + day7Messages,
//                chatType: .friend
//            ),
//            ChatRoom(name: "Blind Date", participants: [User.me, User.cony], messages: blindDateMessages(), chatType: .blindDate),
//            ChatRoom(name: "Summary", participants: [User.me] + User.friends, messages: summarizeMessages(), chatType: .friend),
//            ChatRoom(name: "Summary - Korean", participants: [User.me] + User.friends, messages: summarizeMessagesKorean(), chatType: .friend),
//            ChatRoom(name: "Summary - Japanese", participants: [User.me] + User.friends, messages: summarizeMessagesJapanese(), chatType: .friend),
//            ChatRoom(name: "Sticker", participants: [User.me] + User.friends, messages: stickerMessages(), chatType: .friend),
//            ChatRoom(name: "Album", participants: [User.me] + User.friends, messages: albumMessages(), chatType: .friend),
//            ChatRoom(name: "Emotion", participants: [User.me] + User.friends, messages: sentimentMessages(), chatType: .friend),
//            ChatRoom(name: "Translate", participants: [User.me] + User.friends, messages: translateMessages(), chatType: .friend),
//            ChatRoom(name: "Font", participants: [User.me] + User.friends, messages: fontConversationMessages(), chatType: .friend),
            ChatRoom(name: "Spam", participants: [User.me] + User.friends, messages: investmentInvitationMessages(), chatType: .friend),
            ChatRoom(name: "Spam1", participants: User.sampleUsers, messages: spamSample1(), chatType: .friend),
            ChatRoom(name: "Spam2", participants: User.sampleUsers, messages: spamSample2(), chatType: .friend),
            ChatRoom(name: "Spam3", participants: [User.userA, User.userB, User.userC, User.userD], messages: spamSample3(), chatType: .friend),
            ChatRoom(name: "Spam4", participants: User.sampleUsers, messages: spamSample4(), chatType: .friend),
            ChatRoom(name: "Spam5", participants: User.sampleUsers, messages: spamSample5(), chatType: .friend),
            ChatRoom(name: "Spam6", participants: User.sampleUsers, messages: spamSample6(), chatType: .friend),
            ChatRoom(name: "Spam7", participants: User.sampleUsers, messages: spamSample7(), chatType: .friend),
            ChatRoom(name: "Spam8", participants: User.sampleUsers, messages: spamSample8(), chatType: .friend),
            ChatRoom(name: "Spam9", participants: User.sampleUsers, messages: spamSample9(), chatType: .friend),
            ChatRoom(name: "Spam9", participants: User.sampleUsers, messages: spamSample9(), chatType: .friend),
            ChatRoom(name: "Spam10", participants: User.sampleUsers, messages: spamSample10(), chatType: .friend),
            ChatRoom(name: "Spam11", participants: User.sampleUsers, messages: spamSample11(), chatType: .friend),
            ChatRoom(name: "Spam12", participants: User.sampleUsers, messages: spamSample12(), chatType: .friend),
            ChatRoom(name: "Spam13", participants: User.sampleUsers, messages: spamSample13(), chatType: .friend),
            ChatRoom(name: "Spam14", participants: User.sampleUsers, messages: spamSample14(), chatType: .friend),
            ChatRoom(name: "Spam15", participants: User.sampleUsers, messages: spamSample15(), chatType: .friend),
            ChatRoom(name: "Spam16", participants: User.sampleUsers, messages: spamSample16(), chatType: .friend),
            ChatRoom(name: "Spam17", participants: User.sampleUsers, messages: spamSample17(), chatType: .friend),
            ChatRoom(name: "Spam18", participants: User.sampleUsers, messages: spamSample18(), chatType: .friend),
            ChatRoom(name: "Spam19", participants: User.sampleUsers, messages: spamSample19(), chatType: .friend),
            ChatRoom(name: "Spam20", participants: User.sampleUsers, messages: spamSample20(), chatType: .friend),


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
    // 1. ISO8601 형식 먼저 시도
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    if let isoDate = isoFormatter.date(from: dateString) {
        return isoDate
    }
    
    // 2. "yyyy-MM-dd" 형식 fallback
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    return dateFormatter.date(from: dateString)
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

func spamSample1() -> [any Message] {
    let baseDate = dateFromString("2025-06-12")!

    return [
        TextMessage(sender: .userA, text: "こんばんは、前澤友作です。急に連絡してごめんね…", date: baseDate),
        TextMessage(sender: .userB, text: "え、本物の前澤さん？LINEで…何のご用件ですか？", date: baseDate.addingTimeInterval(60)),
        TextMessage(sender: .userA, text: "実は今、極秘のデジタルアート投資プロジェクトを準備していて君をぜひ招待したいんだ。", date: baseDate.addingTimeInterval(120)),
        TextMessage(sender: .userB, text: "デジタルアート投資？NFTのことですか？", date: baseDate.addingTimeInterval(180)),
        TextMessage(sender: .userA, text: "そう。僕が所有するアーティスト作品をトークン化して、今後市場価値が5倍、10倍は確実視されている。", date: baseDate.addingTimeInterval(240)),
        TextMessage(sender: .userB, text: "すごい…でも参加者は限られているんですか？", date: baseDate.addingTimeInterval(300)),
        TextMessage(sender: .userA, text: "はい、今回はたった10名限定で、1人あたり最低1000万円、最大5000万円の投資枠になります。", date: baseDate.addingTimeInterval(360)),
        TextMessage(sender: .userB, text: "1000万円…かなり大きい額ですね。契約書とか投資説明書はありますか？", date: baseDate.addingTimeInterval(420)),
        TextMessage(sender: .userA, text: "機密保持のため、参加確定後にPDFで送ります。先に入金いただくのがフローなんだ。", date: baseDate.addingTimeInterval(480)),
        TextMessage(sender: .userB, text: "先入金…でもリスクが心配です。元本保証はありますか？", date: baseDate.addingTimeInterval(540)),
        TextMessage(sender: .userA, text: "僕の個人ファンドが全額保証しているから安全だよ。前回も全員利益を確定してる。", date: baseDate.addingTimeInterval(600)),
        TextMessage(sender: .userB, text: "前回の投資実績のスクリーンショットとか見せてもらえますか？", date: baseDate.addingTimeInterval(660)),
        TextMessage(sender: .userA, text: "もちろん。これが先月分の配当履歴だ。ほら。", date: baseDate.addingTimeInterval(720)),
        TextMessage(sender: .userB, text: "本当だ…すごい額ですね。手数料とかはかかりますか？", date: baseDate.addingTimeInterval(780)),
        TextMessage(sender: .userA, text: "通常は3%かかるけど、君には特別に無料にしておくよ。", date: baseDate.addingTimeInterval(840)),
        TextMessage(sender: .userB, text: "それなら…どうしても今日中に決めなきゃいけない理由はありますか？", date: baseDate.addingTimeInterval(900)),
        TextMessage(sender: .userA, text: "世界中の投資家が殺到していて、あと数時間で締め切るんだ。日本時間24時までに振り込める？", date: baseDate.addingTimeInterval(960)),
        TextMessage(sender: .userB, text: "わかりました…では3000万円を試しに入金します。振込先を教えてください。", date: baseDate.addingTimeInterval(1020)),
        TextMessage(sender: .userA, text: "口座情報はスイスのHSBC銀行。口座番号とSWIFTコードをこれから送るね。", date: baseDate.addingTimeInterval(1080)),
        TextMessage(sender: .userB, text: "了解です。すぐに送金して、送金後にご連絡します。", date: baseDate.addingTimeInterval(1140))
    ]
}

func spamSample2() -> [any Message] {
    let baseDate = dateFromString("2025-05-29")!

    return [
        TextMessage(sender: .userC, text: "3000円の呪縛解いたか\nこのド硬いレジスタンスをブレイクすれば將來期待できますね", date: baseDate.addingTimeInterval(0)),
        TextMessage(sender: .userA, text: "皆さん、こんにちは！\n本日29日午前の東京株式市場では、日経平均株価が大きく反発しました。前場の終値は、前日比で633円30銭高い3万8355円70銭となり、上昇率は約1.68％でした。\n\n背景としては、アメリカの半導体大手・エヌビディアの決算が非常に良かったと受け止められたことがあり、それをきっかけに東京市場でも、特に値がさのハイテク株を中心に買いが先行しました。その後も、アメリカの関税措置に関する「違法」との判断が出たことで急速な円安・ドル高が進み、これに乗じた海外の短期筋が株価指数先物を買い進めた結果、日経平均は一段と上げ幅を広げました。", date: baseDate.addingTimeInterval(8580)),
        TextMessage(sender: .userE, text: "やっぱ海外勢すごいですね\n昨日も高寄りの結果マイ転\n今日は持ち堪えられそう", date: baseDate.addingTimeInterval(8700)),
        TextMessage(sender: .userA, text: "具体的には、アメリカ時間の28日に発表されたエヌビディアの2025年2〜4月期の決算内容が、前年同期比で69％増の売上高440億6200万ドルとなり、四半期ベースでは過去最高でした。この数字は市場の予想も上回っており、生成AI（人工知能）への強い需要が継続しているとの見方から、東京エレクトロンやアドバンテストといった半導体関連株にも買いが入り、日経平均を押し上げる要因となりました。", date: baseDate.addingTimeInterval(9000)),
        TextMessage(sender: .userA, text: "また、米国際貿易裁判所が、トランプ大統領が発動した関税について「違法」との判断を下したことで、アメリカの通商政策が世界経済に与える悪影響への懸念がやや和らぎました。これを受けて、29日午前の東京外国為替市場では、一時1ドル＝146円近辺まで円安が進みました。こうした円安の動きを見て、海外の短期投資家が円安に合わせる形で日経平均先物を買い進めたことも、株価の一段高を後押ししたと考えられます。", date: baseDate.addingTimeInterval(9360)),
        TextMessage(sender: .userA, text: "東海東京インテリジェンス・ラボの沢田遼太郎シニアアナリストは、「エヌビディアの好決算や米関税措置の違法判断はいずれも日本株にとって非常にポジティブな材料です。特に関税措置の問題は、輸出企業の多い日本企業にとって重荷だったため、それが和らぐことで今後の企業業績に上振れ期待が生まれています」とコメントしていました。\n東証株価指数（TOPIX）も続伸しており、前場の終値は40.62ポイント高い2810.13となりました。また、JPXプライム150指数も反発し、前場を21.35ポイント高の1241.39で終えています。", date: baseDate.addingTimeInterval(9750)),
        TextMessage(sender: .userF, text: "関税措置違法か\n貿易戦争の終焉が来るのか", date: baseDate.addingTimeInterval(10020)),
        TextMessage(sender: .userC, text: "終焉とまで行かなくても今の無茶苦茶なやり方がなくなれば\n市場の警戒感がだいぶ和らぎますね", date: baseDate.addingTimeInterval(10140)),
        TextMessage(sender: .userD, text: "関税終われば輸出株好調になるね\nこんだけ関税に振り回されてきたから", date: baseDate.addingTimeInterval(10440)),
        TextMessage(sender: .userH, text: "カンロ下がってきましたね\n売って良かったです\nカンロ様ありがとうございました\n先生ありがとうございました", date: baseDate.addingTimeInterval(10860)),
        TextMessage(sender: .userG, text: "僕は4260円で売れました\n売りの指示が出たタイミング良すぎますね", date: baseDate.addingTimeInterval(11160)),
        TextMessage(sender: .userE, text: "これがプロの実力ってやつですよ\n先生の指示をちゃんと聞けば間違いなく着実に資産を増やせる", date: baseDate.addingTimeInterval(11460)),
        TextMessage(sender: .userC, text: "そんぽに三井物産それからサイエンスも着実に上昇中\n最近の相場がイマイチなのにな！\nすごい！", date: baseDate.addingTimeInterval(11640)),
        TextMessage(sender: .userI, text: "物産3000円以上まで来れたら戦闘力上昇するね\n機関の買いとかも入りそうだし", date: baseDate.addingTimeInterval(11940)),
        TextMessage(sender: .userJ, text: "さぁね、近いうちに落ちてこなければ上昇の余地は全然ありそうだけどね\n5大商社の一つだし、バフェットさんと先生の目を信じてますよ", date: baseDate.addingTimeInterval(12360)),
        TextMessage(sender: .userB, text: "一応自分で先生のオススメ銘柄とかまとめてますけど\n今月だけでこれ\n利確してない含み益も入れれば既に30パー近く行ってますよ", date: baseDate.addingTimeInterval(12660)),
        TextMessage(sender: .userB, text: "[写真]", date: baseDate.addingTimeInterval(12660)),
        TextMessage(sender: .userK, text: "すごいですね\nまとめてるって\n取引履歴あるじゃんここまでしなくても", date: baseDate.addingTimeInterval(13080)),
        TextMessage(sender: .userE, text: "日経頑張ったね\nこの調子でいけば持ち株さらに上がる:grin:", date: baseDate.addingTimeInterval(13260)),
        TextMessage(sender: .userE, text: "[写真]", date: baseDate.addingTimeInterval(13560)),
    ]
}

func spamSample3() -> [any Message] {
    let baseDate = dateFromString("2025-06-12")!

    return [
        TextMessage(sender: .userA, text: "@all みんなー、そろそろ文化祭の出し物決めないとヤバくない？先生が明日までに案を出せって言ってたよ。", date: baseDate),
        TextMessage(sender: .userB, text: "うわ、まじか！定番だけど、お化け屋敷とかどう？絶対盛り上がるって！", date: baseDate.addingTimeInterval(45)),
        TextMessage(sender: .userC, text: "お化け屋敷、準備大変じゃない？教室真っ暗にしたり、小道具作ったりするの、結構時間かかりそう…。", date: baseDate.addingTimeInterval(90)),
        TextMessage(sender: .userD, text: "俺がお化け役やったら、みんな笑って終わりそうw", date: baseDate.addingTimeInterval(125)),
        TextMessage(sender: .userA, text: "確かに準備は大変かも。でもインパクトはあるよね。他になんか案ある人いる？", date: baseDate.addingTimeInterval(160)),
        TextMessage(sender: .userC, text: "食べ物系は？タピオカとかフルーツ飴とか。初期費用はかかるけど、売れたら利益出るし。", date: baseDate.addingTimeInterval(230)),
        TextMessage(sender: .userB, text: "食べ物系は他のクラスとめっちゃ被りそうじゃない？", date: baseDate.addingTimeInterval(265)),
        TextMessage(sender: .userD, text: "利益で打ち上げ代稼ぐのありだな(笑)", date: baseDate.addingTimeInterval(300)),
        TextMessage(sender: .userA, text: "うーん、どっちも一長一短かあ。お化け屋敷は「楽しさ・思い出」重視、食べ物は「手軽さ・利益」重視って感じ？", date: baseDate.addingTimeInterval(370)),
        TextMessage(sender: .userB, text: "せっかくの文化祭だし、みんなで何か作り上げる系が良くない？やっぱりお化け屋敷推し！", date: baseDate.addingTimeInterval(420)),
        TextMessage(sender: .userC, text: "でも、受験生だし、準備に時間かけすぎると勉強時間が…。", date: baseDate.addingTimeInterval(460)),
        TextMessage(sender: .userD, text: "それな。俺は勉強についていくだけで必死なんだが…。", date: baseDate.addingTimeInterval(485)),
        TextMessage(sender: .userA, text: "確かに勉強も大事だよね。じゃあ、体験型だけど準備がそこまでじゃないやつとかは？例えば、縁日みたいな感じで射的とか輪投げとか。", date: baseDate.addingTimeInterval(540)),
        TextMessage(sender: .userB, text: "縁日！それいいね！景品とか用意したら楽しそう！", date: baseDate.addingTimeInterval(585)),
        TextMessage(sender: .userC, text: "それなら準備も分担しやすそうだし、いいかも！", date: baseDate.addingTimeInterval(610)),
        TextMessage(sender: .userD, text: "俺、射的得意かも。景品はうまい棒で。", date: baseDate.addingTimeInterval(630)),
        TextMessage(sender: .userA, text: "w じゃあ、今のところの候補は「お化け屋敷」「食べ物屋（タピオカ等）」「縁日」の３つかな？", date: baseDate.addingTimeInterval(680)),
        TextMessage(sender: .userB, text: "縁日がいい感じな気がする！", date: baseDate.addingTimeInterval(710)),
        TextMessage(sender: .userA, text: "よし、じゃあこの３つの案で明日朝のホームルームでみんなにアンケート取ってみようか。それで決めるってことでどう？", date: baseDate.addingTimeInterval(750)),
        TextMessage(sender: .userC, text: "それがいいね！賛成！", date: baseDate.addingTimeInterval(780)),
    ]
}

func spamSample4() -> [any Message] {
    let baseDate = dateFromString("2025-04-05")!

    return [
        TextMessage(sender: .userA, text: "🌸春の宴会シーズン到来🌸\n歓送迎会のご予約はお済みですか？\n当店自慢の「春野菜と鮮魚のコース」で素敵なひとときを！\n早期予約で幹事様1名無料キャンペーン実施中✨", date: baseDate),
        TextMessage(sender: .userA, text: "【週末限定クーポン🍻】\nお会計から10%OFF！\n本日と明日、ご来店のお客様限定です。\nこの画面をスタッフにご提示ください！\n※有効期限: 2025/04/13", date: baseDate.addingTimeInterval(7 * 86400 + 3600)),
        TextMessage(sender: .userA, text: "✨ゴールデンウィークの営業について✨\n休まず毎日営業します！\n連休中は混雑が予想されますので、お早目のご予約がおすすめです。\n皆様のご来店を心よりお待ちしております！", date: baseDate.addingTimeInterval(15 * 86400 + 2100)),
        TextMessage(sender: .userB, text: "予約", date: baseDate.addingTimeInterval(15 * 86400 + 2220)),
        TextMessage(sender: .userA, text: "ご予約ですね！ありがとうございます。\n以下のリンクからオンライン予約が可能です。\n[https://example.com/reservation]\nお電話（03-XXXX-XXXX）でも承っております。", date: baseDate.addingTimeInterval(15 * 86400 + 2225)),
        TextMessage(sender: .userA, text: "【GWスペシャルクーポン】\n期間中ずっと使える！ドリンク1杯無料クーポンをプレゼント🎁\n生ビール、サワー、ハイボールなど対象ドリンク多数！\nこの機会をお見逃しなく！", date: baseDate.addingTimeInterval(23 * 86400)),
        TextMessage(sender: .userA, text: "GWは楽しめましたか？\n本日より通常営業です！\n連休明け、仕事帰りの一杯にぜひお立ち寄りください🍺", date: baseDate.addingTimeInterval(32 * 86400 + 64800)),
        TextMessage(sender: .userA, text: "🍶新しい日本酒、入荷しました🍶\nフルーティーな香りが特徴の「純米吟醸 夢幻」です。\n旬の肴との相性は抜群！ぜひご賞味ください。", date: baseDate.addingTimeInterval(35 * 86400 + 68400)),
        TextMessage(sender: .userA, text: "＼初夏のおすすめ／\n「アジのなめろう」や「冷やしトマト」など、さっぱりメニューが登場！\n暑い日には、キリッと冷えたビールと一緒にいかがですか？", date: baseDate.addingTimeInterval(40 * 86400 + 66600)),
        TextMessage(sender: .userA, text: "【フォロワー様限定】\n合言葉は「LINE見ました」！\nお会計時にスタッフに伝えると、本日のおすすめ小鉢一品サービスいたします🎁", date: baseDate.addingTimeInterval(47 * 86400 + 68400)),
        TextMessage(sender: .userA, text: "月末おつかれさまです！\n今週もあと少し！金曜は華金！🍻\n週末は当店で美味しいお酒と料理を楽しんで、一週間の疲れを癒してくださいね。", date: baseDate.addingTimeInterval(53 * 86400 + 64800)),
        TextMessage(sender: .userA, text: "6月スタート！\n梅雨のジメジメを吹き飛ばす、スタミナ満点メニューをご用意してお待ちしております💪", date: baseDate.addingTimeInterval(57 * 86400 + 43200)),
        TextMessage(sender: .userA, text: "☔雨の日クーポン☔\n雨の日にご来店のお客様に「揚げ出し豆腐」を1グループに1つプレゼント！\n足元が悪い中、ありがとうございます！\n※このメッセージが届いた本日限定です。", date: baseDate.addingTimeInterval(60 * 86400 + 61200)),
        TextMessage(sender: .userB, text: "👍", date: baseDate.addingTimeInterval(60 * 86400 + 61520)),
        TextMessage(sender: .userA, text: "【父の日WEEK👔】\n6/9(月)～6/15(日)まで！\n日頃の感謝を込めて、お父様とご来店で「お父様のドリンク1杯目」を無料でご提供します！\nぜひご家族でご利用ください。", date: baseDate.addingTimeInterval(62 * 86400 + 64800)),
        TextMessage(sender: .userA, text: "日曜のお昼、いかがお過ごしですか？\n当店はランチ営業もしております！\nボリューム満点の定食で、午後への活力をチャージ！", date: baseDate.addingTimeInterval(64 * 86400 + 46800)),
        TextMessage(sender: .userA, text: "週の始まり、お疲れ様です！\n今ならお席に余裕がございます。\nサクッと一杯いかがですか？ハッピーアワーは19時まで！", date: baseDate.addingTimeInterval(65 * 86400 + 68400)),
        TextMessage(sender: .userA, text: "＼夏を先取り！／\n「ゴーヤチャンプルー」と「冷やしきゅうりの一本漬け」が本日よりスタート！\nオリオンビールとの相性も抜群ですよ🍺", date: baseDate.addingTimeInterval(66 * 86400 + 63000)),
        TextMessage(sender: .userA, text: "【シークレットクーポン🤫】\nこのメッセージを受け取った方限定！\n「串焼き5種盛り合わせ」を半額でご提供！\nご注文時にこの画面をお見せください。\n※有効期限: 本日より1週間", date: baseDate.addingTimeInterval(67 * 86400 + 66600)),
        TextMessage(sender: .userA, text: "木曜日のランチタイムです！\n今日の唐揚げ定食は、特製ネギ塩だれでご提供。\nご飯大盛り無料です！お待ちしております！", date: baseDate.addingTimeInterval(68 * 86400 + 43200))
    ]
}

func spamSample5() -> [any Message] {
    let baseDate = dateFromString("2025-05-28")!

    return [
        TextMessage(sender: .userA, text: "https://votesjpok.com/", date: baseDate.addingTimeInterval(1016640)),
        TextMessage(sender: .userB, text: "ギフト券がもらえるの？やった！助かります！絶対投票します👍", date: baseDate.addingTimeInterval(1016760)),
        TextMessage(sender: .userC, text: "簡単そうだから投票します😁", date: baseDate.addingTimeInterval(1016880)),
        TextMessage(sender: .userD, text: "妻と昔話しながら飲んでたら、\n缶ビール10缶も空けました\nしかも、そのうちの8缶は妻が飲んでたｗ\n我妻は酒豪である😂", date: baseDate.addingTimeInterval(1018680)),
        TextMessage(sender: .userE, text: "皆さん、こんばんは\n奥さんと飲むビールは一番美味しいですね（笑）\nさて、明日から株式市場が再開します。\n今週は米国CPIやメジャーSQなど控えており、\nいつも以上に情報にアンテナを張る必要があります。\n今週の経済イベントのスケジュールをまとめました\n参考にしてください", date: baseDate.addingTimeInterval(1019940)),
        TextMessage(sender: .userF, text: "先生、こんばんは！\nいつも資料共有ありがとうございます\nアメリカのCPIは今週ですね\n雇用統計の翌週ですし、\n要注目ですねｗ", date: baseDate.addingTimeInterval(1020300)),
        TextMessage(sender: .userG, text: "今週はメジャーSQですね", date: baseDate.addingTimeInterval(1020600)),
        TextMessage(sender: .userE, text: "先週の日経平均株価は前週比0.59％安、TOPIXは1.15％安と軟調でした。約1カ月間、横ばいの動きが続いており、上値の重さが意識されていますが、チャート自体は決して悪くありません。短期移動平均線が株価水準に接近しており、目先の下値サポートとして機能しやすい位置にあります。ただ、この短期線を明確に割り込むと投資家心理が悪化する恐れがあるため、今週に大きな下落があった場合には、マーケット心理の冷え込みに注意が必要です。", date: baseDate.addingTimeInterval(1020840)),
        TextMessage(sender: .userC, text: "先生、こんばんは。\n日曜日も共有していただき、ありがとうございます😊", date: baseDate.addingTimeInterval(1021140)),
        TextMessage(sender: .userE, text: "レーザーテックや東京エレクトロンなど半導体株には底入れの動きもみられますがまだ本調子ではなく、防衛・インフラなど依然としてバリュー株優位 の地合いが続いている様子です。\nTOPIXについては中期移動平均線が長期線を上抜けできれば、いわゆる移動平均線のパーフェクトオーダーを形成できるためチャートの印象はさらに改善するでしょう。ただし、今のところ中期線は横ばいで、上向くまでにはもう少し時間がかかりそうです。", date: baseDate.addingTimeInterval(1021260)),
        TextMessage(sender: .userE, text: "先週の株価が比較的堅調だった背景には、外国人投資家による大幅な買い越しがありました。また、自社株買いも非常に活発で、年度末の3月第4週を除くと、年初からほぼ毎週、買い越しが続いています。当初の見通し通り、2025年は自社株買いが株価の下支え要因になっています。一方、個人投資家は現物株を7週連続で売り越しており、典型的な「逆張り」の動きが見られています。", date: baseDate.addingTimeInterval(1021440)),
        TextMessage(sender: .userH, text: "TSMCの決算がありますね、半導体関連銘柄は動くでしょう", date: baseDate.addingTimeInterval(1022100)),
        TextMessage(sender: .userE, text: "株価が回復する中で市場全体の売り残は増加し、信用倍率は 4.87 倍 まで低下しました。V 字回復が順調すぎて高値警戒が強まっているものの、市場が売りをぶつけても株価が崩れていない点はポジティブです。このまま売りを吸収できれば、将来の上昇エネルギーとなるでしょう。なお、金曜のメジャーSQに向けて上昇/下落のトレンドが強まる場合には、翌週にトレンドの反転が見られる可能性があります。", date: baseDate.addingTimeInterval(1022220)),
        TextMessage(sender: .userG, text: "今週はSQ週だから、水曜日は要注意ですね", date: baseDate.addingTimeInterval(1022520)),
        TextMessage(sender: .userI, text: "SQとはなんでしょうか？", date: baseDate.addingTimeInterval(1022580)),
        TextMessage(sender: .userE, text: "「SQ」とは、Special Quotationの略で「エスキュー」と呼ばれます。日本語では「特別清算指数」です。", date: baseDate.addingTimeInterval(1022880)),
    ]
}

func spamSample6() -> [any Message] {
    let baseDate = dateFromString("2025-06-08")!
    return [
        TextMessage(sender: .userA, text: "みなさん、お疲れ様です。今日は超限定の大型投資案件をご紹介します。", date: baseDate.addingTimeInterval(360000)),
        TextMessage(sender: .userA, text: "今回の案件は、東南アジア上場前テックベンチャー向けファンドで、年利約40%、更に元本補償付きです。", date: baseDate.addingTimeInterval(360060)),
        TextMessage(sender: .userB, text: "僕は先月5,000万円で参加して、今月末には約7,000万円に跳ね上がりました。", date: baseDate.addingTimeInterval(360120)),
        TextMessage(sender: .userC, text: "私も先々月に3,000万円入れたら、先週配当で1,200万円入ってきました！", date: baseDate.addingTimeInterval(360180)),
        TextMessage(sender: .userD, text: "すごい数字ですね…でも、本当に元本保証はあるんですか？", date: baseDate.addingTimeInterval(360240)),
        TextMessage(sender: .userA, text: "はい。弊社のエスコロー口座で1億円まで全額保証しています。", date: baseDate.addingTimeInterval(360300)),
        TextMessage(sender: .userB, text: "実際に僕も1,000万円の損失が出た月がありましたが、全額返金されました。", date: baseDate.addingTimeInterval(360360)),
        TextMessage(sender: .userD, text: "その実績を確認できる資料などはありますか？", date: baseDate.addingTimeInterval(360420)),
        TextMessage(sender: .userA, text: "匿名化した補填履歴PDFをお送りします。まずは簡単なKYC登録をお願いします。", date: baseDate.addingTimeInterval(360480)),
        TextMessage(sender: .userC, text: "KYCは2日前に済ませましたが、登録から証明書受け取りまで3時間程度でしたよ。", date: baseDate.addingTimeInterval(360540)),
        TextMessage(sender: .userA, text: "なお、本案件の募集枠はわずか5名、最低投資額は5,000万円からです。", date: baseDate.addingTimeInterval(360600)),
        TextMessage(sender: .userD, text: "5,000万円…かなりの大金ですね。分割払いは可能でしょうか？", date: baseDate.addingTimeInterval(360660)),
        TextMessage(sender: .userA, text: "申し訳ありませんが、本ファンドは一括投資のみとなっております。", date: baseDate.addingTimeInterval(360720)),
        TextMessage(sender: .userB, text: "でも一括にすれば手数料ゼロになるし、管理報酬も無料になりますよ。", date: baseDate.addingTimeInterval(360780)),
        TextMessage(sender: .userC, text: "私も全額一括で入金しましたが、運用利回りが最大化されてすごくよかったです！", date: baseDate.addingTimeInterval(360840)),
        TextMessage(sender: .userD, text: "うーん…どうしても今日中に決断しなければならない理由は？", date: baseDate.addingTimeInterval(360900)),
        TextMessage(sender: .userA, text: "世界中の富裕層から引き合いが強く、今夜23:59に締切ります。", date: baseDate.addingTimeInterval(360960)),
        TextMessage(sender: .userB, text: "振込先はスイス銀行のエスコロー口座です。後ほど口座情報を個チャで送りますね。", date: baseDate.addingTimeInterval(361020)),
        TextMessage(sender: .userC, text: "入金が確認でき次第、正式契約書と匿名補填履歴をお送りします。", date: baseDate.addingTimeInterval(361080)),
        TextMessage(sender: .userD, text: "わかりました…では今夜中に5,000万円を一括で振り込みます。口座情報をお願いします。", date: baseDate.addingTimeInterval(361140))
    ]
}

func spamSample7() -> [any Message] {
    let baseDate = dateFromString("2025-06-10")!
    return [
        TextMessage(sender: .userA, text: "永田、今ちょっといい？", date: baseDate.addingTimeInterval(72900)),
        TextMessage(sender: .userB, text: "おう、どうした？", date: baseDate.addingTimeInterval(72945)),
        TextMessage(sender: .userA, text: "ちょっと相談というか、お願いがあって…。", date: baseDate.addingTimeInterval(73200)),
        TextMessage(sender: .userA, text: "かなり言いにくいんだけど、お金を貸してもらえないかなと思って…", date: baseDate.addingTimeInterval(73310)),
        TextMessage(sender: .userB, text: "お、おう。急だな。何かあったのか？いくら必要？", date: baseDate.addingTimeInterval(73440)),
        TextMessage(sender: .userA, text: "実は急な出費が重なっちゃって…。20万ほど貸してもらえると本当に助かる。", date: baseDate.addingTimeInterval(73590)),
        TextMessage(sender: .userA, text: "来月の給料日には絶対に返すから！", date: baseDate.addingTimeInterval(73605)),
        TextMessage(sender: .userB, text: "20万か…わかった。大変そうだしな。いいよ。口座情報教えて。", date: baseDate.addingTimeInterval(73800)),
        TextMessage(sender: .userA, text: "本当に！？ありがとう…！マジで助かる。", date: baseDate.addingTimeInterval(73830)),
        TextMessage(sender: .userA, text: "XX銀行 YY支店 普通 1234567 ホッタ タロウ", date: baseDate.addingTimeInterval(73875)),
        TextMessage(sender: .userB, text: "OK。明日午前中に振り込んどくわ。", date: baseDate.addingTimeInterval(73940)),
        TextMessage(sender: .userA, text: "本当にありがとう。恩に着る。", date: baseDate.addingTimeInterval(73960)),
        TextMessage(sender: .userB, text: "堀田、今から振り込むわー", date: baseDate.addingTimeInterval(86400 + 36300)), // 다음 날 10:05
        TextMessage(sender: .userA, text: "お、おう！まじですまん、ありがとう！", date: baseDate.addingTimeInterval(86400 + 36330)),
        TextMessage(sender: .userB, text: "振り込んだよ。確認してみて。", date: baseDate.addingTimeInterval(86400 + 36480)),
        TextMessage(sender: .userA, text: "ちょっと待ってね、今確認する！", date: baseDate.addingTimeInterval(86400 + 36505)),
        TextMessage(sender: .userA, text: "入ってた…！永田、本当にありがとう。命拾いした。", date: baseDate.addingTimeInterval(86400 + 36600)),
        TextMessage(sender: .userB, text: "いいってことよ。ちゃんと返すように頼むな笑", date: baseDate.addingTimeInterval(86400 + 36660)),
        TextMessage(sender: .userA, text: "もちろん！約束は絶対守る。一応、ちゃんと借用書も書くよ。", date: baseDate.addingTimeInterval(86400 + 36735)),
        TextMessage(sender: .userB, text: "俺らの仲でいらんて笑 とにかく、大変だろうけど頑張れよ。", date: baseDate.addingTimeInterval(86400 + 36840))
    ]
}

func spamSample8() -> [any Message] {
    let baseDate = dateFromString("2025-06-12")!
    return [
        TextMessage(sender: .userA, text: "みんな、今日の夜ご飯どうする？何時くらいに帰れそう？", date: baseDate.addingTimeInterval(63015)),
        TextMessage(sender: .userC, text: "ごめん、今日部活で少し遅くなる！19時半くらいかな。", date: baseDate.addingTimeInterval(63105)),
        TextMessage(sender: .userD, text: "もうすぐ学校でるよー。18時くらいには着くと思う。", date: baseDate.addingTimeInterval(63140)),
        TextMessage(sender: .userA, text: "はーい、了解！", date: baseDate.addingTimeInterval(63200)),
        TextMessage(sender: .userB, text: "父さんも今日は会議で遅くなる。20時過ぎると思う。夕飯いらないです。", date: baseDate.addingTimeInterval(63910)),
        TextMessage(sender: .userA, text: "あら、そうなのね。わかったわ。じゃあ今日は唐揚げにするね！", date: baseDate.addingTimeInterval(63965)),
        TextMessage(sender: .userD, text: "やったー！", date: baseDate.addingTimeInterval(63990)),
        TextMessage(sender: .userC, text: "唐揚げ嬉しい！", date: baseDate.addingTimeInterval(64021)),
        TextMessage(sender: .userA, text: "パパの分も少し取っておくわね。", date: baseDate.addingTimeInterval(64030)),
        TextMessage(sender: .userB, text: "ありがとう、助かる。", date: baseDate.addingTimeInterval(64225)),
        TextMessage(sender: .userD, text: "今、最寄駅ついたー", date: baseDate.addingTimeInterval(65150)),
        TextMessage(sender: .userA, text: "おかえりー。気をつけてね。", date: baseDate.addingTimeInterval(65170)),
        TextMessage(sender: .userD, text: "ただいまー！", date: baseDate.addingTimeInterval(65320)),
        TextMessage(sender: .userA, text: "おかえりなさい。先に手洗いうがいしてね。", date: baseDate.addingTimeInterval(65335)),
        TextMessage(sender: .userD, text: "[スタンプ]", date: baseDate.addingTimeInterval(65355)),
        TextMessage(sender: .userC, text: "今部活終わった！電車乗る！", date: baseDate.addingTimeInterval(68715)),
        TextMessage(sender: .userA, text: "お疲れ様！", date: baseDate.addingTimeInterval(68740)),
        TextMessage(sender: .userA, text: "そろそろご飯にするから、準備してー＞user_D", date: baseDate.addingTimeInterval(69600)),
        TextMessage(sender: .userD, text: "はーい", date: baseDate.addingTimeInterval(69620)),
        TextMessage(sender: .userC, text: "ただいまー！お腹すいたー！", date: baseDate.addingTimeInterval(70150))
    ]
}

func spamSample9() -> [any Message] {
    let baseDate = dateFromString("2025-06-10")!
    return [
        TextMessage(sender: .userA, text: "佐藤ってさ、なんか投資とかやってる？", date: baseDate.addingTimeInterval(75600)),
        TextMessage(sender: .userB, text: "いや、全然。なんか難しそうだし、元本割れとか聞くと怖いじゃん。", date: baseDate.addingTimeInterval(75690)),
        TextMessage(sender: .userA, text: "わかるわかる。でも、最近よく聞くNISAって知ってる？国がやってる非課税制度だから、結構始めやすいと思うよ。", date: baseDate.addingTimeInterval(75800)),
        TextMessage(sender: .userB, text: "あー、名前だけは聞いたことあるかも。そんなにいいの？", date: baseDate.addingTimeInterval(75825)),
        TextMessage(sender: .userA, text: "うん。普通、投資で利益が出ると20%くらい税金取られるんだけど、NISA口座だとそれがゼロになるんだよ。長期でコツコツやるなら絶対使った方がいい。", date: baseDate.addingTimeInterval(75915)),
        TextMessage(sender: .userB, text: "へー、非課税はでかいな。去年から新しいNISAになったんだっけ？なんか複雑そうで手が出なかったんだよね。", date: baseDate.addingTimeInterval(133800)),
        TextMessage(sender: .userA, text: "そうそう！新NISAは生涯投資枠が1800万円もあって、すごく使いやすくなったよ。「つみたて投資枠」と「成長投資枠」ってのがあるだけ。", date: baseDate.addingTimeInterval(133930)),
        TextMessage(sender: .userB, text: "初心者だとどっちがいいとかあるの？", date: baseDate.addingTimeInterval(133985)),
        TextMessage(sender: .userA, text: "まずは「つみたて投資枠」で、手数料が安いインデックスファンドを毎月決まった額で買っていくのが王道かな。全世界株とかS&P500とか。", date: baseDate.addingTimeInterval(134100)),
        TextMessage(sender: .userB, text: "なるほどねー。金融機関ってどこで口座開くのがいいんだろ。銀行とか？", date: baseDate.addingTimeInterval(144050)),
        TextMessage(sender: .userA, text: "ネット証券がおすすめだよ。SBI証券とか楽天証券。手数料が断然安いから。", date: baseDate.addingTimeInterval(144120)),
        TextMessage(sender: .userB, text: "口座開設って面倒？色々書類とかいるんでしょ？", date: baseDate.addingTimeInterval(144195)),
        TextMessage(sender: .userA, text: "今はスマホでほとんど完結するよ。マイナンバーカードと本人確認書類があればすぐ。", date: baseDate.addingTimeInterval(144270)),
        TextMessage(sender: .userB, text: "まじか、思ったよりハードル低いな。ちょっと調べてみるわ！ありがとう！", date: baseDate.addingTimeInterval(144345)),
        TextMessage(sender: .userA, text: "どいたまー！いつでも聞いてくれ！", date: baseDate.addingTimeInterval(144420)),
        TextMessage(sender: .userB, text: "高橋、昨日教えてもらった楽天証券のサイト見てるんだけどさ。", date: baseDate.addingTimeInterval(176440)),
        TextMessage(sender: .userB, text: "いっぱいありすぎて、結局どの商品買えばいいか分からんなってきた笑", date: baseDate.addingTimeInterval(176475)),
        TextMessage(sender: .userA, text: "あー、最初の壁だな笑　迷ったら「eMAXIS Slim 全世界株式（オール・カントリー）」ってやつが一番人気で無難だと思うよ。これ1本で世界中の会社に分散投資できるから。", date: baseDate.addingTimeInterval(176580)),
        TextMessage(sender: .userA, text: "ただ、あくまで参考で！最終的に決めるのは自己責任で頼む！笑", date: baseDate.addingTimeInterval(176610)),
        TextMessage(sender: .userB, text: "もちろん！いやー助かるわ。おかげで一歩踏み出せそう。本当にありがとう！今度なんか奢るわ！", date: baseDate.addingTimeInterval(176700))
    ]
}

func spamSample10() -> [any Message] {
    let baseDate = dateFromString("2025-06-12")!
    return [
        TextMessage(sender: .userA, text: "久しぶり！ちょっとだけ教えたい投資案件があるんだけど、興味ある？", date: baseDate.addingTimeInterval(39960)),
        TextMessage(sender: .userB, text: "投資案件？何の投資？", date: baseDate.addingTimeInterval(40020)),
        TextMessage(sender: .userA, text: "海外のヘッジファンドで、初期20万円で年利30％、しかも元本保証付きなんだ。", date: baseDate.addingTimeInterval(40080)),
        TextMessage(sender: .userB, text: "年利30％で元本保証って…本当にリスクはゼロ？", date: baseDate.addingTimeInterval(40140)),
        TextMessage(sender: .userA, text: "運営会社が直接保証していて、もう15年の実績があるよ。", date: baseDate.addingTimeInterval(40200)),
        TextMessage(sender: .userB, text: "15年の実績って公式サイトに載ってる？", date: baseDate.addingTimeInterval(40260)),
        TextMessage(sender: .userA, text: "これは友人限定の特別枠だからウェブには非公開なんだ。", date: baseDate.addingTimeInterval(40320)),
        TextMessage(sender: .userB, text: "それだと信頼しにくいな…契約書とか見せてもらえる？", date: baseDate.addingTimeInterval(40380)),
        TextMessage(sender: .userA, text: "契約書は準備中で、まずは資金を入れてもらわないと送れないんだ。", date: baseDate.addingTimeInterval(40440)),
        TextMessage(sender: .userB, text: "振り込む前に書面がほしいんだけど…", date: baseDate.addingTimeInterval(40500)),
        TextMessage(sender: .userA, text: "ビジネスの常識として、入金確認後に正式書類を発行するフローなんだよ。", date: baseDate.addingTimeInterval(40560)),
        TextMessage(sender: .userB, text: "でも何かあったときに困るから、不安がぬぐえない…", date: baseDate.addingTimeInterval(40620)),
        TextMessage(sender: .userA, text: "大丈夫。運営会社が損失を全額補填する契約だから、実質リスクはゼロだよ。", date: baseDate.addingTimeInterval(40680)),
        TextMessage(sender: .userB, text: "他の人がちゃんと配当を受け取った証拠とか無いの？", date: baseDate.addingTimeInterval(40740)),
        TextMessage(sender: .userA, text: "参加者のプライバシー保護で具体的な声は出せないけど、全員着実に利益を得てる。", date: baseDate.addingTimeInterval(40800)),
        TextMessage(sender: .userB, text: "利用規約や詳細資料は？", date: baseDate.addingTimeInterval(40860)),
        TextMessage(sender: .userA, text: "登録後にまとめて送るから、まずは20万円を指定口座に振り込んでほしい。", date: baseDate.addingTimeInterval(40920)),
        TextMessage(sender: .userB, text: "うーん、今日は急いで決められないから、明日また相談してもいい？", date: baseDate.addingTimeInterval(40980)),
        TextMessage(sender: .userA, text: "明日だと枠がなくなるかもしれない。今日の24時までに入金できる？", date: baseDate.addingTimeInterval(41040)),
        TextMessage(sender: .userB, text: "わかった。今晩中に検討してみるね。", date: baseDate.addingTimeInterval(41100))
    ]
}

func spamSample11() -> [any Message] {
    let baseDate = dateFromString("2025-05-26")!
    return [
        TextMessage(sender: .userB, text: "承知いたしました。それではこちらからグループに招待し一緒に交流と学習をしましょう。ところで投資に触れてからどのくらいになりますか？", date: baseDate.addingTimeInterval(60)),
        TextMessage(sender: .userA, text: "まだ初心者です。証券口座も持ってないです。", date: baseDate.addingTimeInterval(180)),
        TextMessage(sender: .userB, text: "そうだったんですね。Dragoneer投資研究グループへのご参加、おめでとうございます。優良銘柄の情報は、最新の市場環境を考慮しながら毎日共有されますので、ぜひチェックしてみてください。また、新規メンバー向けに、宮本先生が作成した学習資料を無料で提供しております。投資の基礎をしっかり身につけるために、助手の佐々木さんを追加して資料を受け取ることをおすすめします。学習資料の受け取りをご希望されますか？", date: baseDate.addingTimeInterval(300)),
        TextMessage(sender: .userA, text: "ありがとうございます。ぜひ資料を欲しいです。", date: baseDate.addingTimeInterval(480)),
        TextMessage(sender: .userB, text: "承知いたしました 、佐々木さんは今回のイベント専属アシスタントであり、優良銘柄の最新情報や、日常の学習資料の配信を一括管理しています。ぜひ友達追加をして、情報を見逃さないようにしてください。追加が完了したら予約受付を送信してください。以下が佐々木さんの公式LINEリンクです👇", date: baseDate.addingTimeInterval(600)),
        TextMessage(sender: .userB, text: "https://lin.ee/XhWF1UY", date: baseDate.addingTimeInterval(630)),
        TextMessage(sender: .userA, text: "追加できました。ありがとうございました。", date: baseDate.addingTimeInterval(1200)),
        TextMessage(sender: .userB, text: "とんでもないです。宮本先生の講義が始まりましたので、ご注目ください。今後、投資に関してご不明な点やご相談がありましたら、いつでも私にご連絡いただくか、アシスタントの佐々木さんにご連絡ください。私たちは皆様に専門的で安心できるサポートを全力で提供いたします！", date: baseDate.addingTimeInterval(1800)),
        TextMessage(sender: .userA, text: "ありがとうございます。引き続きよろしくお願いします。", date: baseDate.addingTimeInterval(5400)),
        TextMessage(sender: .userB, text: "こんばんは。最近は相場の変動が激しくなっており、今後の市場の方向性に注目が集まっています。現状をより的確に把握し、投資チャンスを逃さないためにも、本日20時からグループ内で以下の内容について詳しく講義を行います。お時間のある方はぜひご注目ください。", date: baseDate.addingTimeInterval(86400)),
        TextMessage(sender: .userA, text: "了解しました。ありがとうございます。", date: baseDate.addingTimeInterval(86400 + 7200)),
        TextMessage(sender: .userB, text: "おはようございます。先週金曜日の米国市場では、ダウ平均が上昇し、S&P500とナスダックは下落しました。現在の相場についてどのようにお考えでしょうか？", date: baseDate.addingTimeInterval(2 * 86400)),
        TextMessage(sender: .userB, text: "おはようございます。昨夜の米国株市場では、主要三指数がそろって上昇し、特にテクノロジー株が好調で、エヌビディアは1％以上の上昇となりました。保有状況を踏まえて最適な運用戦略をご提案いたします。", date: baseDate.addingTimeInterval(3 * 86400)),
        TextMessage(sender: .userB, text: "こんばんは！本日20時より、宮本先生がグループ内で相場の分析と最新の投資理念についての講義を予定しております。今夜のご参加は可能でしょうか？ぜひご確認ください。", date: baseDate.addingTimeInterval(5 * 86400)),
        TextMessage(sender: .userB, text: "宮本先生が今夜共有された講義内容を要点を絞って整理いたしました📝。個別にサポートをさせていただきます。また、今夜の講義にご参加されていない場合は【1】とご返信ください📩", date: baseDate.addingTimeInterval(7 * 86400)),
        TextMessage(sender: .userB, text: "[ファイル]", date: baseDate.addingTimeInterval(8 * 86400)),
        TextMessage(sender: .userB, text: "おはようございます。昨日の日経平均は寄り付き後に上昇し、38,400円でレジスタンスラインに直面して最終的には122円高で引けました。投資に関するご質問があれば、いつでもご連絡ください。", date: baseDate.addingTimeInterval(9 * 86400))
    ]
}


func spamSample12() -> [any Message] {
    let baseDate = dateFromString("2022-07-10")!
    return [
        TextMessage(sender: .userA, text: "堀田ーーー！ヤバい！", date: baseDate.addingTimeInterval(92102400)),
        TextMessage(sender: .userA, text: "ついにやったぞ俺は！", date: baseDate.addingTimeInterval(92102415)),
        TextMessage(sender: .userB, text: "なんだなんだ、騒々しいな笑 どうした？", date: baseDate.addingTimeInterval(92102520)),
        TextMessage(sender: .userA, text: "前から言ってた投資の件、とんでもない利益が出た！", date: baseDate.addingTimeInterval(92102565)),
        TextMessage(sender: .userB, text: "まじで！？すげええ！おめでとう！", date: baseDate.addingTimeInterval(92102590)),
        TextMessage(sender: .userA, text: "で、だ！祝いにパーッと海外旅行行かね？俺が全部出す！", date: baseDate.addingTimeInterval(92102620)),
        TextMessage(sender: .userA, text: "ハワイでもタイでも、お前の行きたいとこ行こうぜ！", date: baseDate.addingTimeInterval(92102640)),
        TextMessage(sender: .userB, text: "ええ！？全部！？太っ腹すぎだろ…！", date: baseDate.addingTimeInterval(92102680)),
        TextMessage(sender: .userA, text: "たまにはいいだろ！日頃の疲れを癒しに行こうぜ！", date: baseDate.addingTimeInterval(92102725)),
        TextMessage(sender: .userB, text: "めちゃくちゃ行きたい…行きたいんだけど…", date: baseDate.addingTimeInterval(92102760)),
        TextMessage(sender: .userB, text: "ごめん、今ちょうど仕事がめちゃくちゃ忙しい時期でさ…とても休めない…", date: baseDate.addingTimeInterval(92102790)),
        TextMessage(sender: .userA, text: "うそーん。マジかよ。3日とかでも無理？", date: baseDate.addingTimeInterval(92102820)),
        TextMessage(sender: .userB, text: "無理だ…今俺が抜けたらプロジェクトが止まるレベルで…。本当に申し訳ない。", date: baseDate.addingTimeInterval(92102860)),
        TextMessage(sender: .userA, text: "そっかー、残念。じゃあ来月とかはどうだ？", date: baseDate.addingTimeInterval(92226210)),
        TextMessage(sender: .userB, text: "それも厳しいかも…。今月いっぱいは身動き取れないんだ。せっかく誘ってくれたのに、本当にごめん。", date: baseDate.addingTimeInterval(92226520)),
        TextMessage(sender: .userA, text: "しゃーないな、仕事じゃ。まぁ、この話はいつでも有効だから、落ち着いたらまた言えよ！", date: baseDate.addingTimeInterval(92226730)),
        TextMessage(sender: .userB, text: "ありがとう！マジで神。落ち着いたら絶対行こう！", date: baseDate.addingTimeInterval(92226915)),
        TextMessage(sender: .userA, text: "じゃあ、とりあえず今週末に飯でもどうだ？祝杯あげようぜ！もちろん俺の奢りで！", date: baseDate.addingTimeInterval(92227180)),
        TextMessage(sender: .userB, text: "それは行きたい！ぜひ！", date: baseDate.addingTimeInterval(92227210)),
        TextMessage(sender: .userA, text: "よっしゃ！じゃあ土曜の19時に新宿でどう？店は探しとく！", date: baseDate.addingTimeInterval(92227450))
    ]
}

func spamSample13() -> [any Message] {
    let baseDate = dateFromString("2025-06-08")!

    return [
        TextMessage(sender: .userB, text: "水谷さんに教えてもらえて光栄です", date: baseDate),
        TextMessage(sender: .userA, text: "300万円は実はそれほど多くないと思います。問題ないですよ。大切なのはご自身の投資意欲に従うことです。", date: baseDate.addingTimeInterval(60)),
        TextMessage(sender: .userB, text: "では入金してみます。", date: baseDate.addingTimeInterval(120)),
        TextMessage(sender: .userA, text: "それから、私はあなたを山崎社長のプライベート勉強会に招待しました。ここ最近の講義はとても良くて、初心者の方にも学びやすい内容だと思います。秘書の佐藤さんからノートは受け取りましたか？", date: baseDate.addingTimeInterval(180)),
        TextMessage(sender: .userA, text: "入金が成功したら教えてください。来週、良い銘柄の情報があれば、購入のタイミングをお知らせしますね。", date: baseDate.addingTimeInterval(240)),
        TextMessage(sender: .userA, text: "土日はお休みですよね。建設業は本当に大変なお仕事ですね。", date: baseDate.addingTimeInterval(300)),
        TextMessage(sender: .userA, text: "先週金曜日の米国株は大幅に上昇し、それに連動して225先物も上昇しました。日経平均のテクニカル面から見ても、すでに上方へのブレイクアウトの形が形成されており、本日は38,000円付近まで上昇する可能性が非常に高いと考えられます。", date: baseDate.addingTimeInterval(5700)),
        TextMessage(sender: .userB, text: "入金完了しました。", date: baseDate.addingTimeInterval(7920)),
        TextMessage(sender: .userA, text: "了解しました！\n今、株を購入する時間はありますか？", date: baseDate.addingTimeInterval(9300)),
        TextMessage(sender: .userA, text: "株を購入する時間がある時は、ぜひ教えてくださいね。", date: baseDate.addingTimeInterval(9360)),
        TextMessage(sender: .userB, text: "今日できそうです。", date: baseDate.addingTimeInterval(9984)),
        TextMessage(sender: .userA, text: "優良銘柄の5588をご購入ください。\n購入が完了しましたら、購入のスクリーンショットを送ってください。\nまずは100万円分の購入をおすすめします。", date: baseDate.addingTimeInterval(10320)),
        TextMessage(sender: .userA, text: "現在の価格であれば、600株購入できます。", date: baseDate.addingTimeInterval(10380)),
        TextMessage(sender: .userA, text: "優良株の5588は、昨日あなたが購入しなかったのに、今はもう上昇しています。", date: baseDate.addingTimeInterval(149700)),
        TextMessage(sender: .userA, text: "[写真]", date: baseDate.addingTimeInterval(154320)),
        TextMessage(sender: .userA, text: "昨晩の米国株市場は続伸し、それに伴って225先物も上昇しました。そのため、今日の日経平均株価も引き続き上昇が期待されます。ただし、上値の抵抗線である38,500円付近には注意が必要です。相場が上昇する局面では、冷静なリスク意識を持つことがより重要になります。なぜなら、リスクというのは上昇の中で蓄積されていくものだからです。", date: baseDate.addingTimeInterval(159120)),
        TextMessage(sender: .userB, text: "買えばよかったです。", date: baseDate.addingTimeInterval(193920)),
        TextMessage(sender: .userB, text: "すみません。", date: baseDate.addingTimeInterval(193920)),
        TextMessage(sender: .userA, text: "大丈夫です。\n今日はまだ5588を買い増しすることができますよ。", date: baseDate.addingTimeInterval(194100)),
        TextMessage(sender: .userA, text: "もし購入に成功したら、購入のスクリーンショットを送って確認させてください。", date: baseDate.addingTimeInterval(194160))
    ]
}

func spamSample14() -> [any Message] {
    let baseDate = dateFromString("2025-06-12")!

    return [
        TextMessage(sender: .userA, text: "こんにちは、警察庁捜査一課の佐藤と申します。○○さんのご本人ですか？", date: baseDate),
        TextMessage(sender: .userB, text: "え、はい私ですが…どういったご用件でしょうか？", date: baseDate.addingTimeInterval(30)),
        TextMessage(sender: .userA, text: "実は、最近あなたの名前が特殊詐欺グループの名簿に載っている疑いがありまして、確認が必要です。", date: baseDate.addingTimeInterval(60)),
        TextMessage(sender: .userB, text: "私が詐欺グループ？そんなはずはないです…。", date: baseDate.addingTimeInterval(105)),
        TextMessage(sender: .userA, text: "念のため、今から口座の取引履歴を確認させていただきます。銀行口座番号と暗証番号を教えていただけますか？", date: baseDate.addingTimeInterval(135)),
        TextMessage(sender: .userB, text: "銀行口座の暗証番号…？警察がそんな大事な情報を聞くんですか？", date: baseDate.addingTimeInterval(180)),
        TextMessage(sender: .userA, text: "はい。犯罪収益移転防止法に基づき、被疑者の口座特定を進めるために必要です。", date: baseDate.addingTimeInterval(210)),
        TextMessage(sender: .userB, text: "わかりました…。口座番号は1234‐5678ですが、暗証番号はちょっと…", date: baseDate.addingTimeInterval(255)),
        TextMessage(sender: .userA, text: "では、簡易認証として銀行Webバンキングのワンタイムパスワードを教えてください。今画面に表示されている6桁をお願いします。", date: baseDate.addingTimeInterval(285)),
        TextMessage(sender: .userB, text: "いま見たら『482759』です…", date: baseDate.addingTimeInterval(330)),
        TextMessage(sender: .userA, text: "ありがとうございます。確認できました。残高も問題ありませんね。", date: baseDate.addingTimeInterval(360)),
        TextMessage(sender: .userB, text: "良かった…。これで大丈夫なんでしょうか？", date: baseDate.addingTimeInterval(390)),
        TextMessage(sender: .userA, text: "いえ、念のため口座を一時凍結して調査します。その際、代わりの安全口座に資金をご移動いただく必要があります。", date: baseDate.addingTimeInterval(420)),
        TextMessage(sender: .userB, text: "安全口座？どこに移せばいいんですか？", date: baseDate.addingTimeInterval(465)),
        TextMessage(sender: .userA, text: "警察庁指定のエスクロー口座です。口座情報をこれから送りますので、すぐに全部移していただけますか？", date: baseDate.addingTimeInterval(495)),
        TextMessage(sender: .userB, text: "わかりました…。全部移しても問題ないですか？", date: baseDate.addingTimeInterval(540)),
        TextMessage(sender: .userA, text: "はい、こちらに移せば捜査終了後、すぐにご返金しますのでご安心を。", date: baseDate.addingTimeInterval(570)),
        TextMessage(sender: .userB, text: "急いで手続きします。振込先を教えてください。", date: baseDate.addingTimeInterval(600)),
        TextMessage(sender: .userA, text: "口座名義：警察庁エスクロー口座　銀行：東京第一銀行　支店：099　口座番号：0001234 です。", date: baseDate.addingTimeInterval(630)),
        TextMessage(sender: .userB, text: "了解しました。すぐに送金してご報告します…。", date: baseDate.addingTimeInterval(675))
    ]
}

func spamSample15() -> [any Message] {
    let baseDate = dateFromString("2025-06-11")!

    return [
        TextMessage(sender: .userB, text: "【明日の注目経済指標】\n6月12日(木)は、米国の生産者物価指数(PPI)が発表されます。インフレの先行指標として注目されており、市場の変動要因となる可能性があります。詳しい解説はこちらから。\nhttps://example-news.co.jp/reports/20250611_ppi_preview", date: baseDate),
        TextMessage(sender: .userA, text: "ありがとうございます。確認します。", date: baseDate.addingTimeInterval(305)),
        TextMessage(sender: .userB, text: "おはようございます！\n【本日のマーケット展望 6/12】\n昨晩の米国市場は小幅に反発。本日は日銀の金融政策決定会合の結果発表を控え、様子見ムードが広がる可能性があります。特に為替の動きに注意が必要です。", date: baseDate.addingTimeInterval(39610)),
        TextMessage(sender: .userB, text: "【速報】日経平均、寄り付きは小幅安でスタートしました。現在、前日比-50円の40,350円近辺で推移しています。", date: baseDate.addingTimeInterval(41100)),
        TextMessage(sender: .userA, text: "[スタンプ]", date: baseDate.addingTimeInterval(41425)),
        TextMessage(sender: .userB, text: "【為替情報】ドル円は1ドル157円台前半で推移しています。日銀会合の結果待ちで、積極的な売買は手控えられています。", date: baseDate.addingTimeInterval(45915)),
        TextMessage(sender: .userB, text: "【速報】日銀、金融政策の現状維持を決定。長期国債の買い入れ減額方針も示唆されました。詳細は追ってお知らせします。", date: baseDate.addingTimeInterval(47195)),
        TextMessage(sender: .userB, text: "先ほどの日銀の決定を受け、日経平均はプラスに転じています。為替は円安方向に振れています。\n▼専門家による解説動画はこちら\nhttps://example-news.co.jp/videos/20250612_boj", date: baseDate.addingTimeInterval(47305)),
        TextMessage(sender: .userA, text: "情報ありがとうございます！", date: baseDate.addingTimeInterval(47400)),
        TextMessage(sender: .userB, text: "【大引け】本日の日経平均株価は、前日比+120円の40,520円で取引を終えました。日銀の発表が好感され、後場に買いが集まりました。", date: baseDate.addingTimeInterval(50500)),
        TextMessage(sender: .userB, text: "【特集記事】「日銀の次の一手は？今後の金融政策と市場への影響を徹底分析」\n本日の決定内容を踏まえ、今後の展開をエコノミストが予測します。\nhttps://example-news.co.jp/features/boj_next_move", date: baseDate.addingTimeInterval(53240)),
        TextMessage(sender: .userA, text: "参考になります。", date: baseDate.addingTimeInterval(53250)),
        TextMessage(sender: .userB, text: "【ミニクイズ】\n今日の市場で最も上昇率が高かった業種は次のうちどれでしょう？\n1. 銀行業\n2. 不動産業\n3. 自動車", date: baseDate.addingTimeInterval(54000)),
        TextMessage(sender: .userA, text: "2. 不動産業", date: baseDate.addingTimeInterval(54090)),
        TextMessage(sender: .userB, text: "正解です！金融緩和の継続期待から、不動産業が大きく上昇しました。素晴らしいですね！", date: baseDate.addingTimeInterval(54115)),
        TextMessage(sender: .userB, text: "【欧州市場オープン】\n欧州株式市場は、日銀の決定を好感し、主要指数は軒並み上昇してスタートしています。", date: baseDate.addingTimeInterval(54620)),
        TextMessage(sender: .userB, text: "【速報】米国5月生産者物価指数(PPI)、市場予想を下回る結果となりました。インフレ圧力の緩和が示唆され、FRBの利下げ期待が高まる可能性があります。", date: baseDate.addingTimeInterval(55545)),
        TextMessage(sender: .userB, text: "この結果を受け、米長期金利は低下、ドル円は一時156円台まで下落しています。米国株式市場のオープンに向け、ダウ先物も上昇中です。", date: baseDate.addingTimeInterval(55705)),
        TextMessage(sender: .userA, text: "すごい動きですね…。", date: baseDate.addingTimeInterval(55895)),
        TextMessage(sender: .userB, text: "本日も一日お疲れ様でした。\n明日の朝も最新のマーケット情報をお届けします。良い夜をお過ごしください。", date: baseDate.addingTimeInterval(56195))
    ]
}

func spamSample16() -> [any Message] {
    let baseDate = dateFromString("2025-06-11")!

    return [
        TextMessage(sender: .userA, text: "永田さん、お疲れ様です！昨日の巨人の試合、見ました？サヨナラ勝ち、最高でしたね！", date: baseDate),
        TextMessage(sender: .userB, text: "お疲れ様です、吉良さん！見ましたよ！岡本選手のあの一発は痺れましたね！", date: baseDate.addingTimeInterval(155)),
        TextMessage(sender: .userA, text: "本当に！それで思いついたんですが、来週末の土曜日、7月5日の阪神戦のチケットが2枚手に入ったんです。もし予定が空いてたら、一緒にどうですか？", date: baseDate.addingTimeInterval(220)),
        TextMessage(sender: .userB, text: "え、本当ですか！？伝統の一戦じゃないですか！", date: baseDate.addingTimeInterval(270)),
        TextMessage(sender: .userB, text: "ちょっと待ってください、スケジュール確認します！", date: baseDate.addingTimeInterval(305)),
        TextMessage(sender: .userA, text: "はい、ぜひ！席も内野のいい席なんですよ。", date: baseDate.addingTimeInterval(320)),
        TextMessage(sender: .userB, text: "吉良さん、7月5日、空いてます！ぜひ行きたいです！", date: baseDate.addingTimeInterval(435)),
        TextMessage(sender: .userA, text: "よかった！じゃあ決まりですね！", date: baseDate.addingTimeInterval(460)),
        TextMessage(sender: .userB, text: "ありがとうございます！めちゃくちゃ嬉しいです！", date: baseDate.addingTimeInterval(483)),
        TextMessage(sender: .userA, text: "いえいえ！永田さんと行ったら絶対楽しいと思って！", date: baseDate.addingTimeInterval(510)),
        TextMessage(sender: .userA, text: "試合は18時からなんで、17時くらいに水道橋駅で待ち合わせでもいいですか？", date: baseDate.addingTimeInterval(555)),
        TextMessage(sender: .userB, text: "もちろんです！17時水道橋、了解です。", date: baseDate.addingTimeInterval(590)),
        TextMessage(sender: .userA, text: "先に軽く一杯やりますか？笑", date: baseDate.addingTimeInterval(630)),
        TextMessage(sender: .userB, text: "最高ですね！ぜひ！", date: baseDate.addingTimeInterval(645)),
        TextMessage(sender: .userB, text: "いやー、楽しみだなあ。戸郷が先発だといいですね！", date: baseDate.addingTimeInterval(691)),
        TextMessage(sender: .userA, text: "ですね！相手は村上でしょうから、投手戦が見たいですね！", date: baseDate.addingTimeInterval(730)),
        TextMessage(sender: .userB, text: "熱い試合になりそう！", date: baseDate.addingTimeInterval(760)),
        TextMessage(sender: .userA, text: "また日が近くなったら連絡しますね！", date: baseDate.addingTimeInterval(810)),
        TextMessage(sender: .userB, text: "承知しました！吉良さん、本当にありがとうございます！", date: baseDate.addingTimeInterval(835)),
        TextMessage(sender: .userA, text: "とんでもないです！楽しみにしてます！", date: baseDate.addingTimeInterval(870))
    ]
}

func spamSample17() -> [any Message] {
    let baseDate = dateFromString("2025-06-11")!

    return [
        TextMessage(sender: .userA, text: "Aya、久しぶり！元気？ちょっと超絶ヤバい投資案件があって教えたくて連絡したんだ。", date: baseDate),
        TextMessage(sender: .userB, text: "え、Kenta？本当久しぶりだけど……投資案件って何？", date: baseDate.addingTimeInterval(40)),
        TextMessage(sender: .userA, text: "実はね、今話題の\"秘密NFTマイニング\"に参加してて、わずか3日で元本が2倍になるんだよ。", date: baseDate.addingTimeInterval(65)),
        TextMessage(sender: .userB, text: "3日で200%って怪しすぎない？そんなうまい話あるの？", date: baseDate.addingTimeInterval(103)),
        TextMessage(sender: .userA, text: "香港の極秘プロジェクトで、選ばれた紹介者しか入れない仕組みなんだ。一般公開は一切なし。", date: baseDate.addingTimeInterval(140)),
        TextMessage(sender: .userB, text: "香港のプロジェクト……仕組みをもう少し詳しく教えてよ。", date: baseDate.addingTimeInterval(175)),
        TextMessage(sender: .userA, text: "最新鋭のマイニング機器を使って、ブロック報酬を次々獲得してるらしくてね。機器1台が500万円×100台をまとめて稼働中。", date: baseDate.addingTimeInterval(210)),
        TextMessage(sender: .userB, text: "500万円の機械100台ってとんでもない額だね…。", date: baseDate.addingTimeInterval(255)),
        TextMessage(sender: .userA, text: "でも小口投資もOKで、最低1万円から入れられる。しかも俺を通じて申込むと手数料100%免除！", date: baseDate.addingTimeInterval(290)),
        TextMessage(sender: .userB, text: "公式サイトとか資料はないの？普通ページくらいあるでしょ？", date: baseDate.addingTimeInterval(333)),
        TextMessage(sender: .userA, text: "サイトはあるけど完全クローズドで、招待リンクしかアクセスできない仕様なんだ。", date: baseDate.addingTimeInterval(365)),
        TextMessage(sender: .userB, text: "なんだか余計に怪しいよ…。", date: baseDate.addingTimeInterval(395)),
        TextMessage(sender: .userA, text: "リスクはほぼゼロだから安心して。運営が\"補償基金\"を用意してて、投資額の90%までは補填保証するって言ってる。", date: baseDate.addingTimeInterval(435)),
        TextMessage(sender: .userB, text: "90%保証って、運営が損しまくりじゃない？", date: baseDate.addingTimeInterval(480)),
        TextMessage(sender: .userA, text: "AI分析ツールと複数のヘッジ先を使ってるから、むしろ安定運用が可能なんだって。", date: baseDate.addingTimeInterval(520)),
        TextMessage(sender: .userB, text: "本当に返ってきた実績とかないの？", date: baseDate.addingTimeInterval(565)),
        TextMessage(sender: .userA, text: "俺自身、先週10万円だけ入れたら丸5日で19万円に増えたよ。証拠はスクショで送れる。", date: baseDate.addingTimeInterval(603)),
        TextMessage(sender: .userB, text: "スクショ見たらちょっと安心するかも…。", date: baseDate.addingTimeInterval(645)),
        TextMessage(sender: .userA, text: "あとね、紹介者枠はあと数名だけ。迷ってると締め切られちゃうから、今夜24時までに振り込んだ方がいいよ。", date: baseDate.addingTimeInterval(690)),
        TextMessage(sender: .userB, text: "わかった…。とりあえず1万円だけ試しに入れてみる。振込先教えて。", date: baseDate.addingTimeInterval(735))
    ]
}

func spamSample18() -> [any Message] {
    let baseDate = dateFromString("2025-06-06")!

    return [
        TextMessage(sender: .userB, text: "どういうことでしょうか。", date: baseDate),
        TextMessage(sender: .userA, text: "おはようございます。\n取引時間中に、取引を行う時間があまり取れないということですか？", date: baseDate.addingTimeInterval(35160)), // +9h 46m
        TextMessage(sender: .userA, text: "週末は友人や家族と一緒に出かけてリラックスすることはありましたか？\n最近、私のメンバーに追加された方々の多くは初心者なので、現在投資に関する資料や心得を整理しています。\n整理が完了したら、これらの内容をファイルにまとめて皆さんに共有する予定です。\n投資に関して、自分に不足していると感じる部分や、さらに学びたいと思う分野はありますか？\n投資市場でより高い利益を得たり、経済的自由を実現したい場合は、現在の状況を詳しく教えてください。\n合った取引計画を作成しますので、よろしくお願いします。", date: baseDate.addingTimeInterval(196980)), // +2d 6h 53m
        TextMessage(sender: .userB, text: "ありがとうございます。あまり金銭の余裕がなく、旅行に行けてないです。", date: baseDate.addingTimeInterval(201960)),
        TextMessage(sender: .userB, text: "計画作成してくれると嬉しいです。", date: baseDate.addingTimeInterval(201960)),
        TextMessage(sender: .userA, text: "将来的に十分な経済的基盤を築けると信じています。\n多くのメンバーが投資市場を通じて経済的自由を実現してきました。\n投資の流れにしっかりとついて行けば、きっとその目標を達成できると信じています。\n取引計画を作成するお手伝いはできますが、まずは現在の投資状況を教えていただくか、保有しているポジションのスクリーンショットを送ってください。\n具体的な状況に基づいて、適切な計画を立てさせていただきます。\nよろしくお願いします。", date: baseDate.addingTimeInterval(203100)),
        TextMessage(sender: .userB, text: "現在は投資信託がメインです。300万円ぐらい入れてます。", date: baseDate.addingTimeInterval(204180)),
        TextMessage(sender: .userA, text: "大変お待たせして申し訳ありませんでした。\n先ほどは他のメンバーの投資計画を作成する手助けをしていました。\n彼らはこれまでほとんど損失を出しており、利益を得ることはほとんどありませんでした。\n中には投資市場でマンションを購入するためのお金を稼ぎたいと考えている人もいれば、経済的自由を実現し、十分な年金を得たいと考えている人もいます。\n\n投資計画を作成するお手伝いもできますが、それには一定の実行力が必要です。\n実行力が足りなければ、計画を立てても理想的な利益を上げるのは難しいでしょう。\nまず、投資信託を選んでいる点から、比較的安定志向の投資家であると感じました。\nしかし、投資信託の利益は比較的低い傾向にあります。\n時には、私が購入した優良株1つの利益が、投資信託の1年分の利益に匹敵することもあります。\nそのため、私は一般的に、メンバーに投資信託を勧めることはあまりありません。", date: baseDate.addingTimeInterval(250460)),
        TextMessage(sender: .userA, text: "おはようございます。\n以下は私が作成した投資計画です：\n\n株式投資：資金の70%を配分\n投資理由：株式市場は収益性の潜在力が高く、長期的に見れば魅力的なリターンが期待できます。\n優良株を選定し、リスク分散を図りながら、適切な売買タイミングを見極めることで、効率的な運用が可能です。\n\nFXやその他の市場：資金の30%を配分\nFXやその他の市場（例えば、金、FX、不動産など）はリスク分散に役立ちます。\nFX市場は変動が大きいため、リスク許容度の高い投資家に適しており、経済の不確実性が高い時期にはヘッジ手段として活用できます。\n\n株式投資を資金の大部分に配分する理由は、長期的なリターンが見込める点にあります。\n一方で、FXやその他の市場を利用することで、リスク分散を図り、市場の変動に柔軟に対応することが可能です。", date: baseDate.addingTimeInterval(314460)),
        TextMessage(sender: .userB, text: "ありがとうございます😊", date: baseDate.addingTimeInterval(317040)),
        TextMessage(sender: .userB, text: "考えてくれて嬉しいです", date: baseDate.addingTimeInterval(317040)),
        TextMessage(sender: .userB, text: "その通りに運用してみたいです", date: baseDate.addingTimeInterval(317040)),
        TextMessage(sender: .userA, text: "最初のうちは、私の投資ペースに合わせることをお勧めします。\nご自身で売買のタイミングを判断するのは難しく、損失を招く可能性が高いからです。", date: baseDate.addingTimeInterval(319500)),
        TextMessage(sender: .userA, text: "私の投資交流グループに参加することをお勧めします。\n毎日、投資交流グループで投資の心得やテクニックを共有しており、優れた株式情報も提供しています。\n興味があれば、招待させていただきます。\nこれが将来の投資に大いに役立つでしょう", date: baseDate.addingTimeInterval(319860)),
        TextMessage(sender: .userB, text: "ぜひよろしくお願い致します。", date: baseDate.addingTimeInterval(327240)),
        TextMessage(sender: .userA, text: "とんでもないです。\n現在、投資グループへの参加を招待します。\nグループへの参加申請をした後、お名前を教えてください。\nすぐにアシスタントが承認いたします。\nよろしくお願いいたします。", date: baseDate.addingTimeInterval(327900)),
        TextMessage(sender: .userA, text: "オープンチャット「退職計画」\nhttps://line.me/ti/g2/aS-FcOCrwTckE5q61GP_KkkTboj4Wr_Yovm0eg?utm_source=invitation&utm_medium=link_copy&utm_campaign=default", date: baseDate.addingTimeInterval(327960)),
        TextMessage(sender: .userB, text: "ヨシダで入りました", date: baseDate.addingTimeInterval(375180)),
        TextMessage(sender: .userB, text: "よろしくお願いします", date: baseDate.addingTimeInterval(375180)),
        TextMessage(sender: .userA, text: "わかりました。\n先ほどすでにアシスタントに伝えましたので、彼女にすぐ承認するようお願いしました。", date: baseDate.addingTimeInterval(377820))
    ]
}

func spamSample19() -> [any Message] {
    let baseDate = dateFromString("2025-06-12")!

    return [
        TextMessage(sender: .userA, text: "みんな見てくれ！今日の日経平均、すごかったな。俺の持ち株も爆上がりだぞ！", date: baseDate),
        TextMessage(sender: .userB, text: "あら、よかったわね。でも、あまり無理はしないでよ。", date: baseDate.addingTimeInterval(35)),
        TextMessage(sender: .userA, text: "大丈夫だって。ちゃんと分散投資してるからリスク管理はバッチリさ。これで来月の旅行、ちょっと豪華にできるかもな！", date: baseDate.addingTimeInterval(70)),
        TextMessage(sender: .userC, text: "お、マジで！？やったー！寿司！焼肉！", date: baseDate.addingTimeInterval(93)),
        TextMessage(sender: .userD, text: "すごいね、お父さん。どういう銘柄が上がったの？", date: baseDate.addingTimeInterval(115)),
        TextMessage(sender: .userA, text: "主に半導体関連だな。これからはAIの時代だから、そこを見越して仕込んでおいたのが当たった感じだ。", date: baseDate.addingTimeInterval(170)),
        TextMessage(sender: .userB, text: "AIねぇ…よく分からないけど、とにかく良かったわ。夕飯、どうする？", date: baseDate.addingTimeInterval(220)),
        TextMessage(sender: .userA, text: "今日はパーッと外で食べないか？俺が奢るぞ！", date: baseDate.addingTimeInterval(255)),
        TextMessage(sender: .userC, text: "賛成！お父さん、太っ腹！", date: baseDate.addingTimeInterval(270)),
        TextMessage(sender: .userD, text: "わーい！嬉しい！でも、投資ってそんなに簡単に儲かるものなの？ちょっと怖い気もする。", date: baseDate.addingTimeInterval(303)),
        TextMessage(sender: .userA, text: "簡単じゃないさ。毎日、経済ニュースをチェックして、自分なりに分析してるんだ。勉強の成果だよ。", date: baseDate.addingTimeInterval(365)),
        TextMessage(sender: .userB, text: "あなたが毎晩パソコンに向かってるのは、そういうことだったのね。", date: baseDate.addingTimeInterval(405)),
        TextMessage(sender: .userA, text: "そういうこと！タカコも社会人になったら、少しずつでも始めるといいぞ。NISAとか、いい制度もあるし。", date: baseDate.addingTimeInterval(450)),
        TextMessage(sender: .userD, text: "NISAかぁ。よく聞くけど、何から始めたらいいか全然分からなくて。今度教えてほしいな。", date: baseDate.addingTimeInterval(498)),
        TextMessage(sender: .userC, text: "俺にも教えてくれ！一攫千金狙うぜ！", date: baseDate.addingTimeInterval(527)),
        TextMessage(sender: .userA, text: "こらこら、タカシ。投資はギャンブルじゃないぞ。コツコツ増やすのが基本だ。", date: baseDate.addingTimeInterval(585)),
        TextMessage(sender: .userB, text: "そうよ。お父さんの言う通り。まずはちゃんと勉強しなさい。", date: baseDate.addingTimeInterval(630)),
        TextMessage(sender: .userC, text: "はーい…", date: baseDate.addingTimeInterval(645)),
        TextMessage(sender: .userA, text: "よし、じゃあ今からお店探すか！何が食べたい？イタリアン？中華？", date: baseDate.addingTimeInterval(690)),
        TextMessage(sender: .userD, text: "お父さんの奢りなら、ちょっとお高いお寿司屋さんとか…？😋", date: baseDate.addingTimeInterval(749))
    ]
}

func spamSample20() -> [any Message] {
    let baseDate = dateFromString("2025-06-11")!

    return [
        TextMessage(sender: .userA, text: "みんな、ちょっといい話があるんだけど、聞いてくれる？", date: baseDate),
        TextMessage(sender: .userC, text: "お、成浦！どうした？", date: baseDate.addingTimeInterval(53)),
        TextMessage(sender: .userD, text: "なになに？", date: baseDate.addingTimeInterval(76)),
        TextMessage(sender: .userA, text: "最近、将来のためにお金の勉強しててさ。怪しいやつじゃなくて、ちゃんとした資産運用の話なんだけど。", date: baseDate.addingTimeInterval(183)),
        TextMessage(sender: .userB, text: "出たｗ 投資の話か？大丈夫なやつ？", date: baseDate.addingTimeInterval(291)),
        TextMessage(sender: .userA, text: "大丈夫だって！笑　むしろ、もっと早く知っておきたかったって思うくらい健全なやつ。新しいNISAとかとは別に、もっと手軽に始められる積立投資。", date: baseDate.addingTimeInterval(438)),
        TextMessage(sender: .userC, text: "へー！面白そう！詳しく！", date: baseDate.addingTimeInterval(489)),
        TextMessage(sender: .userB, text: "手軽って言っても、元手が必要なんでしょ？リスクとかどうなの？", date: baseDate.addingTimeInterval(633)),
        TextMessage(sender: .userA, text: "それが月々1000円からでも始められるんだって。もちろん投資だからリスクはゼロじゃないけど、長期でコツコツ積み立てるタイプだから、銀行に預けてるだけよりはるかに良いと思う。", date: baseDate.addingTimeInterval(770)),
        TextMessage(sender: .userD, text: "1000円からなら、まあ…。どこの金融機関の商品？", date: baseDate.addingTimeInterval(899)),
        TextMessage(sender: .userA, text: "大手のネット証券のやつだよ。アプリで全部管理できるし、すごい簡単だった。", date: baseDate.addingTimeInterval(12883)),
        TextMessage(sender: .userE, text: "うーん、俺はあんまりそういうの興味ないかなあ。パスで。", date: baseDate.addingTimeInterval(12988)),
        TextMessage(sender: .userA, text: "そっか！全然無理には誘わないから大丈夫だよ！", date: baseDate.addingTimeInterval(13018)),
        TextMessage(sender: .userC, text: "私はめっちゃ興味ある！始め方教えてほしい！", date: baseDate.addingTimeInterval(13193)),
        TextMessage(sender: .userB, text: "もう少し具体的に、どういう商品に投資するのかとか知りたいな。手数料とかも気になるし。", date: baseDate.addingTimeInterval(13430)),
        TextMessage(sender: .userA, text: "もちろん！今度、オンラインで無料のセミナーがあるんだけど、それに参加してみるのが一番分かりやすいと思う。無理な勧誘とか一切ないやつ。", date: baseDate.addingTimeInterval(13726)),
        TextMessage(sender: .userD, text: "オンラインセミナーか。それなら参加しやすいかも。日時はいつ？", date: baseDate.addingTimeInterval(13995)),
        TextMessage(sender: .userA, text: "来週の水曜の夜！URL送ろうか？", date: baseDate.addingTimeInterval(14241)),
        TextMessage(sender: .userC, text: "送ってー！絶対参加する！", date: baseDate.addingTimeInterval(14389)),
        TextMessage(sender: .userB, text: "俺もとりあえず話だけ聞いてみようかな。URLお願い。", date: baseDate.addingTimeInterval(14627))
    ]
}
