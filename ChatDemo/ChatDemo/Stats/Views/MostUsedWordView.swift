internal import SwiftUI

struct MostUsedDataView: View {
    let mostUsedData: MostUsedData

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("The most used word and sticker")
                .modifier(TitleViewModifier())

            VStack(spacing: 15) {
                Text("Sticker")
                    .bold()

                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                HStack(spacing: 0) {
                    Text("I often use stickers that represent '")
                        .modifier(TextViewModifier())
                    Text(mostUsedData.stickerEmotion.rawValue).bold()
                        .modifier(TextViewModifier())
                    Text("'")
                        .modifier(TextViewModifier())
                }
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 15) {
                Text("Word")
                    .bold()
                VStack {
                    Text(mostUsedData.word)
                        .font(.headline)
                        .foregroundColor(Color(red: 99/255, green: 102/255, blue: 241/255).opacity(1))
                        .padding(.horizontal, 32)

                    Text("\(mostUsedData.usedWordCount) times")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .cornerRadius(50)
                .background(
                    Capsule()
                        .fill(Color(red: 99/255, green: 102/255, blue: 241/255).opacity(0.1))
                )

                HStack(spacing: 0) {
                    Text("I often use words that represent '")
                        .modifier(TextViewModifier())
                    Text(mostUsedData.wordEmotion.rawValue).bold()
                        .modifier(TextViewModifier())
                    Text("'")
                        .modifier(TextViewModifier())
                }
            }
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity)
        }
        .modifier(CardViewModifier())
    }
}

struct TextViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14))
            .foregroundStyle(Color(red: 75/255, green: 85/255, blue: 99/255, opacity: 1))
    }
}

struct MostUsedDataView_Previews: PreviewProvider {
    static var previews: some View {
        let mostUsedData = MostUsedData(
            word: "Like",
            wordEmotion: .angry,
            usedWordCount: 127,
            stickerEmotion: .fear,
            stickerImageName: "fear"
        )
        ScrollView {
            MostUsedDataView(mostUsedData: mostUsedData)
        }
    }
}
