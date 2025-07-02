internal import SwiftUI
import Charts

struct HeaderView: View {
    let headerData: HeaderData

    var body: some View {
        VStack(spacing: 10) {
            Text("\(headerData.name)님의 감정 분석 리포트")
                .font(.title3)
                .fontWeight(.bold)

            Text("\(headerData.formattedDateString) 기준")
                .font(.footnote)
            Spacer()

            Text("당신의 메시지에서 발견된 감정 패턴을 분석했어요.")
                .font(.subheadline)
                .padding()
                .frame(
                    width: UIScreen.main.bounds.width - 64, height: 60
                )
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
