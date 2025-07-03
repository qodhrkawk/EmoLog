internal import SwiftUI

struct MostUsedDataView: View {
    let mostUsedData: MostUsedData
    private let wordColors: [(text: Color, background: Color)] = [
        (
            Color(red: 99/255, green: 102/255, blue: 241/255),
            Color(red: 99/255, green: 102/255, blue: 241/255).opacity(0.1)
        ),
        (
            Color(red: 244/255, green: 114/255, blue: 182/255, opacity: 1),
            Color(red: 244/255, green: 114/255, blue: 182/255, opacity: 0.1)
        ),
        (
            Color(red: 202/255, green: 138/255, blue: 4/255, opacity: 1),
            Color(red: 254/255, green: 249/255, blue: 195/255, opacity: 1)
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("The most used sticker and words")
                .modifier(TitleViewModifier())
            VStack(spacing: 15) {
                Text("Sticker")
                    .bold()

                Image(mostUsedData.sticker.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                HStack(spacing: 0) {
                    Text("I often use stickers that represent '")
                        .modifier(TextViewModifier())
                    Text(mostUsedData.sticker.rawValue).bold()
                        .modifier(TextViewModifier())
                    Text("'")
                        .modifier(TextViewModifier())
                }
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 12) {
                Text("Word")
                    .bold()

                ForEach(Array(zip(mostUsedData.words, wordColors)), id: \.0.id) { word, color in
                    wordCapsuleView(
                        word: word.text,
                        usedWordCount: word.count,
                        textColor: color.text,
                        backgroundColor: color.background
                    )
                }
            }
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity)
        }
        .modifier(CardViewModifier())
    }

    private func wordCapsuleView(
        word: String,
        usedWordCount: Int,
        textColor: Color,
        backgroundColor: Color
    ) -> some View {
        VStack {
            Text(word)
                .font(.headline)
                .foregroundColor(textColor)
                .padding(.horizontal, 64)

            Text("\(usedWordCount) times")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .cornerRadius(50)
        .background(
            Capsule()
                .fill(backgroundColor)
                .frame(width: 200, height: 70)
        )
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
            sticker: Sticker.angry,
            words: [
                Word(text: "아 진짜??ㅋ", count: 127),
                Word(text: "진짜 너무 웃겨", count: 100),
                Word(text: "ㅋㅋㅋㅋㅋㅋ", count: 80),
            ]
        )
        ScrollView {
            MostUsedDataView(mostUsedData: mostUsedData)
        }
    }
}
