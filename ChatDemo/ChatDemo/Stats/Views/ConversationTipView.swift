internal import SwiftUI

struct ConversationTipView: View {
    let conversationTipData: ConversationTipData

    var body: some View {
        VStack(alignment: .leading) {
            Text("대화 조언")
                .modifier(TitleViewModifier())

            tipView(
                title: conversationTipData.title,
                description: conversationTipData.description,
                icon: conversationTipData.icon,
                color: Color(red: 99/255, green: 102/255, blue: 241/255, opacity: 0.05)
            )
        }
        .padding(.bottom)
        .modifier(CardViewModifier())
    }

    func tipView(
        title: String,
        description: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 99/255, green: 102/255, blue: 241/255, opacity: 1))
                .frame(width: 5, height: 5)
                .padding()
                .cornerRadius(20)
                .background(
                    Circle()
                        .fill(Color(red: 99/255, green: 102/255, blue: 241/255, opacity: 0.1))
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14))

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 75/255, green: 85/255, blue: 99/255, opacity: 1))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .modifier(TipOptionModifier(color: color))
    }
}

struct TipOptionModifier: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(color)
            .cornerRadius(15)
    }
}

struct ConversationTipView_Previews: PreviewProvider {
    static var previews: some View {
        let tipData = ConversationTipData(
            title: "맞춤 대화 팁",
            description: "서지연님과의 대화에서 긍정적인 피드백이 많이 오갔네요. 이런 대화 패턴을 유지하면서, 더 깊이 있는 대화를 나눠보는 건 어떨까요?",
            icon: "lightbulb.fill"
        )
        ScrollView {
            ConversationTipView(conversationTipData: tipData)
        }
    }
}
