internal import SwiftUI

struct MostUsedDataView: View {
    let mostUsedData: MostUsedData

    var body: some View {
        VStack(alignment: .leading) {
            Text("가장 많이 사용한 단어 & 스티커")
                .modifier(TitleViewModifier())

            VStack {
                VStack {
                    Text(mostUsedData.word)
                        .font(.headline)
                        .foregroundColor(Color(red: 99/255, green: 102/255, blue: 241/255).opacity(1))
                        .padding(.horizontal, 32)

                    Text("\(mostUsedData.usedCount)회")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .cornerRadius(50)
                .background(
                    Capsule()
                        .fill(Color(red: 99/255, green: 102/255, blue: 241/255).opacity(0.1))
                )

                Image(systemName: mostUsedData.stickerImageName)
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .padding(.vertical)
            }
            .frame(maxWidth: .infinity)
        }
        .modifier(CardViewModifier())
    }
}

struct MostUsedDataView_Previews: PreviewProvider {
    static var previews: some View {

        let mostUsedData = MostUsedData(word: "좋아해", usedCount: 100, stickerImageName: "ㅇㅇㅇㅇ")
        ScrollView {
            MostUsedDataView(mostUsedData: mostUsedData)
        }
    }
}
