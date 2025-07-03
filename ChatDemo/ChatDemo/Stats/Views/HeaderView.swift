internal import SwiftUI
import Charts

struct HeaderView: View {
    let headerData: HeaderData

    var body: some View {
        VStack(spacing: 10) {
            Image("emolog_logo")
            Text("\(headerData.name)'s emotion analysis report")
                .font(.title3)
                .fontWeight(.bold)

            Text("Based on \(headerData.formattedDateString)")
                .font(.footnote)
            Spacer()

            Text("We analyzed the emotion patterns found in your messages.")
                .font(.system(size: 14))
                .padding()
                .fixedSize(horizontal: false, vertical: true) // ✅ 추가
                .multilineTextAlignment(.center) // ✅ 가운데 정렬
                .background(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color(red: 99/255, green: 102/255, blue: 241/255).opacity(0.1),
                                Color(red: 244/255, green: 114/255, blue: 182/255).opacity(0.1)
                            ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
        }
        .padding()
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let headerData = HeaderData(
            name: "홍길동",
            formattedDateString: "2023년 10월 1일",
        )
        ScrollView {
            HeaderView(headerData: headerData)
        }
    }

}
