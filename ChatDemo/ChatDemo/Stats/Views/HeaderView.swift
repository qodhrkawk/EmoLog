import SwiftUI
import Charts

struct HeaderView: View {
    let headerData: HeaderData

    var body: some View {
        VStack(spacing: 10) {
            Text("리포트")
                .font(.title)
                .fontWeight(.bold)
            Spacer()

            Text("\(headerData.name)님의 감정 분석 리포트")
                .font(.headline)

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
                                Color.purple.opacity(0.1),
                                Color.pink.opacity(0.1)
                            ]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(10)
        }
        .padding()
    }
}
