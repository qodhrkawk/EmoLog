import Combine

class ChatListViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoom] = []
    
    init() {
        chatRooms = [
            ChatRoom(
                roomType: .live,
                title: "Chat Bot",
                messages: [],
                koreanMessages: nil
            ),
            ChatRoom(
                roomType: .archived,
                title: "회식 메뉴 정하기",
                messages: [
                    Message(sender: User.junhyuk, text: "Hey everyone, do we have any ideas for the team dinner?"),
                    Message(sender: User.me, text: "Hey! Just got back from a meeting. I'm good with anything, but something hearty would be nice."),
                    Message(sender: User.hyeonji, text: "Hi hi! Korean BBQ, anyone?"),
                    Message(sender: User.wonseob, text: "Hey all. Korean BBQ sounds good, but haven’t we had that like twice this month?"),
                    Message(sender: User.jongyoun, text: "Yeah, I think we had it last week too."),
                    Message(sender: User.hyeonji, text: "Oh right, forgot about that. Then maybe something different..."),
                    Message(sender: User.me, text: "I’d be up for trying something new too."),
                    Message(sender: User.junhyuk, text: "Same here. Any suggestions?"),
                    Message(sender: User.hyeonji, text: "Hmm... then how about grilled eel? It’s supposed to be great for stamina."),
                    Message(sender: User.wonseob, text: "Interesting choice! Haven’t had that in a while."),
                    Message(sender: User.jongyoun, text: "Actually, that sounds pretty good."),
                    Message(sender: User.me, text: "Yeah, grilled eel sounds amazing. Good idea."),
                    Message(sender: User.junhyuk, text: "I’m in. Let's go with that."),
                    Message(sender: User.wonseob, text: "I'm down. When and where?"),
                    Message(sender: User.jongyoun, text: "Nice. I’ll look for a place and share the link."),
                    Message(sender: User.hyeonji, text: "Yay, can’t wait!"),
                    Message(sender: User.me, text: "Same here. It's been a while since we all hung out like this.")
                ],
                koreanMessages: [
                    Message(sender: User.junhyuk, text: "여러분, 이번 회식 메뉴 뭐로 할까요?"),
                    Message(sender: User.me, text: "안녕하세요! 방금 회의 끝났어요. 든든한 거면 다 좋아요."),
                    Message(sender: User.hyeonji, text: "안녕안녕~ 삼겹살 어때요?"),
                    Message(sender: User.wonseob, text: "안녕하세요. 삼겹살 좋긴 한데, 이번 달에 두 번이나 먹지 않았나요?"),
                    Message(sender: User.jongyoun, text: "맞아요, 지난주에도 먹었죠."),
                    Message(sender: User.hyeonji, text: "아 그러네요. 그럼 좀 다른 걸로 해볼까요..."),
                    Message(sender: User.me, text: "저도 색다른 메뉴 괜찮아요."),
                    Message(sender: User.junhyuk, text: "저도요. 추천 있을까요?"),
                    Message(sender: User.hyeonji, text: "음... 그럼 장어 구이 어때요? 원기 회복에도 좋대요."),
                    Message(sender: User.wonseob, text: "오! 오랜만에 듣는 메뉴네요."),
                    Message(sender: User.jongyoun, text: "괜찮은데요? 맛도 좋고."),
                    Message(sender: User.me, text: "좋아요, 장어 구이 완전 좋네요."),
                    Message(sender: User.junhyuk, text: "저도 찬성이요. 그걸로 하죠."),
                    Message(sender: User.wonseob, text: "좋습니다. 언제, 어디로 갈까요?"),
                    Message(sender: User.jongyoun, text: "제가 장소 찾아서 링크 공유할게요."),
                    Message(sender: User.hyeonji, text: "좋아요~ 기대돼요!"),
                    Message(sender: User.me, text: "맞아요. 다 같이 모인 지 좀 된 것 같네요.")
                ]
            ),
            ChatRoom(
                roomType: .archived,
                title: "스티커",
                messages: [
                    Message(sender: User.me, text: "I think today’s meeting went pretty smoothly."),
                    Message(sender: User.junhyuk, text: "Yeah, we actually wrapped up on time for once."),
                    Message(sender: User.jongyoun, text: "That rarely happens. Kind of impressive."),
                    Message(sender: User.hyeonji, text: "Everyone was surprisingly focused today."),
                    Message(sender: User.wonseob, text: "Except when we got sidetracked by the coffee machine discussion."),
                    Message(sender: User.hyeonji, sticker: .angry),
                    Message(sender: User.me, text: "Wait, that sticker is adorable."),
                    Message(sender: User.junhyuk, text: "I was just about to say that! I’ve never seen that one."),
                    Message(sender: User.jongyoun, text: "Seriously, how do you always have the best stickers?"),
                    Message(sender: User.hyeonji, text: "Haha, glad you like it."),
                    Message(sender: User.wonseob, text: "That one fits you perfectly, too."),
                ],
                koreanMessages: [
                    Message(sender: User.me, text: "오늘 회의 꽤 매끄럽게 진행된 것 같지 않아?"),
                    Message(sender: User.junhyuk, text: "맞아, 오랜만에 제시간에 끝났네."),
                    Message(sender: User.jongyoun, text: "진짜 드문 일이야. 놀랍다."),
                    Message(sender: User.hyeonji, text: "오늘따라 다들 집중력이 엄청났어."),
                    Message(sender: User.wonseob, text: "그 커피머신 얘기로 잠깐 새긴 했지만 말이야."),
                    Message(sender: User.hyeonji, text: "[스티커]"),
                    Message(sender: User.me, text: "헉, 저 스티커 너무 귀엽다."),
                    Message(sender: User.junhyuk, text: "나도 방금 그 말 하려던 참이었어! 처음 보는 건데?"),
                    Message(sender: User.jongyoun, text: "진짜 어떻게 맨날 그런 귀여운 스티커만 골라 쓰는 거야?"),
                    Message(sender: User.hyeonji, text: "헤헤, 마음에 들어서 다행이다."),
                    Message(sender: User.wonseob, text: "진짜 너랑 찰떡이다, 그 스티커."),
                    Message(sender: User.me, text: "나도 스티커 좀 새로 사야겠어.")
                ]
            ),
            ChatRoom(
                roomType: .archived,
                title: "앨범",
                messages: [
                    Message(sender: User.me, text: "Morning everyone. Hope you're not too swamped today."),
                    Message(sender: User.hyeonji, text: "Hey! Feels like a long week already."),
                    Message(sender: User.wonseob, text: "Tell me about it. I haven’t even finished Tuesday’s work."),
                    Message(sender: User.jongyoun, text: "Same here. Can we fast-forward to the weekend?"),
                    Message(sender: User.junhyuk, text: "Haha, only if someone finds the remote."),
                    
                    Message(sender: User.me, text: "By the way, remember our trip to Sokcho last spring?"),
                    Message(sender: User.hyeonji, text: "Of course! That café by the beach was so relaxing."),
                    Message(sender: User.wonseob, text: "Was that the place with the huge window view?"),
                    Message(sender: User.jongyoun, text: "Yeah, and the drinks were overpriced but looked amazing."),
                    Message(sender: User.junhyuk, text: "Didn’t it rain the first day though?"),
                    Message(sender: User.me, text: "Yeah, but the sky cleared up just in time for those sunset shots."),
                    Message(sender: User.hyeonji, text: "I still love that photo we took on the rocks. The colors were unreal."),
                    Message(sender: User.jongyoun, text: "Didn’t we post a bunch of those here back then?")
                ],
                koreanMessages: [
                    Message(sender: User.me, text: "좋은 아침! 다들 오늘도 바쁘겠지?"),
                    Message(sender: User.hyeonji, text: "안녕! 이번 주는 왜 이렇게 길게 느껴지지..."),
                    Message(sender: User.wonseob, text: "진짜. 아직 화요일 일도 못 끝냈어."),
                    Message(sender: User.jongyoun, text: "맞아. 누가 주말로 빨리 감기 좀 해줬으면."),
                    Message(sender: User.junhyuk, text: "ㅋㅋ 리모컨 있으면 좀 줘봐."),

                    Message(sender: User.me, text: "근데 우리 작년 봄에 속초 갔던 거 기억나?"),
                    Message(sender: User.hyeonji, text: "그럼! 바닷가 근처 카페 진짜 좋았잖아."),
                    Message(sender: User.wonseob, text: "통유리로 바다 보이던 곳 말하는 거지?"),
                    Message(sender: User.jongyoun, text: "응응. 음료는 좀 비쌌는데 사진빨은 진짜 잘 받았어."),
                    Message(sender: User.junhyuk, text: "첫날엔 비 왔던 것 같은데?"),
                    Message(sender: User.me, text: "맞아, 근데 딱 해질 무렵에 날이 개서 사진 찍기 좋았어."),
                    Message(sender: User.hyeonji, text: "바위 위에서 찍은 그 사진 아직도 좋아해. 색감이 예술이었어."),
                    Message(sender: User.jongyoun, text: "그때 찍은 사진 여기다 한 번 올렸던 것 같은데?")
                ]
            ),
            ChatRoom(
                roomType: .archived,
                title: "번역",
                messages: [
                    Message(sender: User.me, text: "Good morning, everyone!"),
                    Message(sender: User.hyeonji, text: "Morning! Did you all sleep well?"),
                    Message(sender: User.wonseob, text: "I stayed up too late watching a movie."),
                    Message(sender: User.jongyoun, text: "Same here. What movie did you watch?"),
                    Message(sender: User.wonseob, text: "The new sci-fi one on Netflix. It was pretty good."),
                    Message(sender: User.junhyuk, text: "I started that too but fell asleep halfway."),
                    Message(sender: User.me, text: "You guys and your late-night habits."),
                    Message(sender: User.hyeonji, text: "I actually slept early for once."),
                    Message(sender: User.jongyoun, text: "That’s rare! What’s the occasion?"),
                    Message(sender: User.hyeonji, text: "Just super tired from yesterday’s meetings."),
                    Message(sender: User.junhyuk, text: "Speaking of which, do we have any today?"),
                    Message(sender: User.me, text: "Yeah, just the sync at 2 PM."),
                    Message(sender: User.wonseob, text: "Is it online or in person?"),
                    Message(sender: User.me, text: "Online. Link’s in the calendar invite."),
                    Message(sender: User.junhyuk, text: "Cool, thanks."),
                    Message(sender: User.hyeonji, text: "Also, don’t forget to submit your timesheets today."),
                    Message(sender: User.jongyoun, text: "Ugh, thanks for the reminder."),
                    Message(sender: User.me, text: "Let’s all do it right after lunch."),
                    Message(sender: User.wonseob, text: "Agreed. Then I won’t forget."),
                    Message(sender: User.junhyuk, text: "Sounds like a plan.")
                ],
                koreanMessages: nil
            ),
            ChatRoom(
                roomType: .archived,
                title: "감정분석",
                messages: [
                    Message(sender: User.me, text: "The release has been delayed. Again."),
                    Message(sender: User.junhyuk, text: "Of course it has. Why am I not surprised."),
                    Message(sender: User.wonseob, text: "I’m actually angry now. This is the third damn delay this month."),
                    Message(sender: User.junhyuk, text: "Every single time it’s the same excuse."),
                    Message(sender: User.wonseob, text: "This isn’t just frustrating. I’m really angry at how we’re being treated."),

                    Message(sender: User.jongyoun, text: "I was actually really looking forward to the release today..."),
                    Message(sender: User.jongyoun, text: "I told my family I’d finally be able to show them something."),
                    Message(sender: User.jongyoun, text: "Now I just feel... deflated."),

                    Message(sender: User.hyeonji, text: "Did anyone try that new matcha place near the office?"),
                    Message(sender: User.wonseob, text: "...Hyeonji? Are you even listening? We’re all angry here."),
                    Message(sender: User.hyeonji, text: "What? I got the soft cream latte, and it was amazing."),
                    Message(sender: User.junhyuk, text: "We’re talking about release delays, not desserts."),
                    Message(sender: User.hyeonji, text: "I mean... it helped me feel better, at least."),

                    Message(sender: User.wonseob, text: "That’s great. While you’re out having desserts, I’m stuck being angry at this mess."),
                    Message(sender: User.me, text: "Alright, let’s stay on track."),

                    Message(sender: User.jongyoun, text: "I guess we just wait. Again."),
                    Message(sender: User.junhyuk, text: "Waiting doesn’t fix the process."),
                    Message(sender: User.wonseob, text: "I’m angry because we’ve been completely ignored. Over and over again."),
                    Message(sender: User.me, text: "Let’s regroup tomorrow and plan around the new schedule.")
                ],
                koreanMessages: [
                    Message(sender: User.me, text: "릴리즈가 또 지연됐어."),
                    Message(sender: User.junhyuk, text: "그럴 줄 알았어. 이젠 놀랍지도 않아."),
                    Message(sender: User.wonseob, text: "이제 진짜 화난다. 이번 달에만 세 번째 지연이야."),
                    Message(sender: User.junhyuk, text: "매번 똑같은 핑계잖아."),
                    Message(sender: User.wonseob, text: "짜증을 넘어서 화가 난다. 우리가 무시당하는 기분이야."),

                    Message(sender: User.jongyoun, text: "나 오늘 릴리즈 정말 기대했는데..."),
                    Message(sender: User.jongyoun, text: "가족들한테도 오늘 보여줄 수 있다고 말했거든."),
                    Message(sender: User.jongyoun, text: "이젠 그냥... 맥이 빠지네."),

                    Message(sender: User.hyeonji, text: "회사 근처에 새로 생긴 말차 가게 가본 사람 있어?"),
                    Message(sender: User.wonseob, text: "...현지야? 지금 우리 다 화나있는데 그 얘기야?"),
                    Message(sender: User.hyeonji, text: "왜? 나 소프트크림 라떼 마셨는데 진짜 맛있었어."),
                    Message(sender: User.junhyuk, text: "지금은 릴리즈 얘기 중이잖아, 디저트가 아니고."),
                    Message(sender: User.hyeonji, text: "그냥… 기분 전환이 좀 되길래 말한 거였어."),

                    Message(sender: User.wonseob, text: "좋겠네. 디저트 먹을 여유는 있고, 난 이 상황에 진짜 화만 나."),
                    Message(sender: User.me, text: "일단 얘기 흐름 다시 잡자."),

                    Message(sender: User.jongyoun, text: "결국 또 기다려야겠지."),
                    Message(sender: User.junhyuk, text: "기다리는 것만으로는 해결 안 돼."),
                    Message(sender: User.wonseob, text: "내가 화나는 건, 우리가 계속 무시당하고 있다는 느낌이 들어서야."),
                    Message(sender: User.me, text: "내일 다시 정리해서 새로운 일정 잡자.")
                ]
            )
                    
        ]
    }
}
