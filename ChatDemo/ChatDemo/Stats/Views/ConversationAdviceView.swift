internal import SwiftUI

struct ConversationAdviceView: View {
    let adviceData: ConversationAdviceData

    var body: some View {
        VStack(alignment: .leading) {
            Text("Advice")
                .modifier(TitleViewModifier())

            Image("tip")
                .resizable()
                .scaledToFit()
            tipView(
                title: adviceData.title,
                description: adviceData.description,
                color: Color(red: 99/255, green: 102/255, blue: 241/255, opacity: 0.05)
            )
            .padding(.vertical, 8)
        }
        .modifier(CardViewModifier())
    }

    func tipView(
        title: String,
        description: String,
        color: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image("bulb")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(Color(red: 99/255, green: 102/255, blue: 241/255, opacity: 1))
                .cornerRadius(20)
                .background(
                    Circle()
                        .fill(Color(red: 99/255, green: 102/255, blue: 241/255, opacity: 0.1))
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14))

                Text(description.toAttributedString())
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

struct ConversationAdviceView_Previews: PreviewProvider {
    static var previews: some View {
        let adviceData = ConversationAdviceData(
            title: "맞춤 대화 팁",
            description: "서지연님과의 대화에서 긍정적인 피드백이 많이 오갔네요. 이런 대화 패턴을 유지하면서, 더 깊이 있는 대화를 나눠보는 건 어떨까요?"
        )
        ScrollView {
            ConversationAdviceView(adviceData: adviceData)
        }
    }
}

extension String {
    func toAttributedString() -> AttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        let nsAttributedStr = NSAttributedString(
            string: self,
            attributes: [
                .paragraphStyle: paragraphStyle
            ])
        let attrStr = AttributedString(nsAttributedStr)
        return attrStr
    }
}
