import SwiftUI

struct ConversationTipView: View {
    let conversationTipData: ConversationTipData

    var body: some View {
        VStack(alignment: .leading) {
            Text("대화 조언")
                .font(.headline)
                .padding()

            tipView(
                title: conversationTipData.mainTip.title,
                description: conversationTipData.mainTip.description,
                icon: conversationTipData.mainTip.icon,
                color: .purple
            )

            ForEach(conversationTipData.additionalTips, id: \.title) { tip in
                tipView(
                    title: tip.title,
                    description: tip.description,
                    icon: tip.icon,
                    color: .blue
                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .modifier(CardViewModifier())
        
    }

    func tipView(
        title: String,
        description: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.black)
                .frame(width: 5, height: 5)
                .padding()
                .background(Color.white)
                .cornerRadius(15)

            Text(title)
                .font(.headline)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .modifier(TipOptionModifier(color: color))
    }
}

struct TipOptionModifier: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(15)
    }
}

struct ConversationTipView_Previews: PreviewProvider {
    static var previews: some View {
        let tipData = ConversationTipData(
            mainTip: ConversationTip(
                title: "맞춤 대화 팁",
                description: "서지연님과의 대화에서 긍정적인 피드백이 많이 오갔네요. 이런 대화 패턴을 유지하면서, 더 깊이 있는 대화를 나눠보는 건 어떨까요?",
                icon: "lightbulb.fill"),
            additionalTips: [
                ConversationTip(
                    title: "공감 표현하기",
                    description: "상대방의 감정에 적극적으로 반응해보세요",
                    icon: "bubble.left"
                ),
                ConversationTip(
                    title: "질문하기",
                    description: "열린 질문으로 대화를열린 질문으로 대화를열린 질문으로 대화를열린 질문으로 대화를",
                    icon: "bubble.left.and.bubble.right"
                )
            ]
        )
        ScrollView {
            ConversationTipView(conversationTipData: tipData)
        }
    }
}
