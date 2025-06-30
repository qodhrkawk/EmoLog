import SwiftUI

struct MostUsedDataView: View {
    let mostUsedData: MostUsedData

    var body: some View {
        VStack(alignment: .leading) {
            Text("가장 많이 사용한 단어 & 스티커")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            Rectangle()
                .fill(Color.pink.opacity(0.3))
                .frame(height: 180)
                .cornerRadius(15)
                .padding()

            VStack {
                VStack {
                    Text(mostUsedData.word)
                        .font(.headline)

                    Text("\(mostUsedData.usedCount)회")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(20)

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
