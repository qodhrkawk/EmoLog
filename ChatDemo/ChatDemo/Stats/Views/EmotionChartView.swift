internal import SwiftUI
import Charts

struct EmotionChartView: View {
    let title: String
    let profileImageName: String
    let emotionDatas: [EmotionData]

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                Image(profileImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .background(Color.pink)
                    .clipShape(Circle())
                Text(title)
                    .modifier(TitleViewModifier())
            }
            .padding(.bottom)

            Chart {
                ForEach(emotionDatas, id: \.id) { emotion in
                    BarMark(
                        x: .value("Date", emotion.dateString),
                        y: .value("Percentage", emotion.percentage)
                    )
                    .foregroundStyle(emotion.emotion.color())
                    .annotation(position: .overlay) {
                        Text(emotion.percentage.formatted() + "%")
                            .font(.system(size: 8))
                    }
                }
            }
            .animation(.easeIn, value: emotionDatas)
            .chartYScale(domain: [0, 100])
            .chartForegroundStyleScale([
                Emotion.happy.rawValue: .yellow,
                Emotion.sad.rawValue: .blue,
                Emotion.angry.rawValue: .red,
                Emotion.fear.rawValue: .purple,
                Emotion.surprise.rawValue: .orange,
                Emotion.love.rawValue: .pink
            ])
            .frame(height: 230)
            .padding(.horizontal)
            .padding(.bottom)
            .padding()
        }
        .modifier(CardViewModifier())
    }
}

struct EmotionChartView_Previews: PreviewProvider {
    static var previews: some View {
        let emotionDatas = [
            EmotionData(dateString: "6/18", percentage: 70, emotion: .happy),
            EmotionData(dateString: "6/18", percentage: 30, emotion: .sad),
            EmotionData(dateString: "6/19", percentage: 75, emotion: .angry),
            EmotionData(dateString: "6/20", percentage: 60, emotion: .fear),
            EmotionData(dateString: "6/20", percentage: 20, emotion: .love),
            EmotionData(dateString: "6/21", percentage: 85, emotion: .surprise),
            EmotionData(dateString: "6/21", percentage: 15, emotion: .love),
            EmotionData(dateString: "6/22", percentage: 90, emotion: .angry),
            EmotionData(dateString: "6/23", percentage: 75, emotion: .happy),
            EmotionData(dateString: "6/24", percentage: 80, emotion: .happy)
        ]
        ScrollView {
            EmotionChartView(
                title: "나의 감정변화",
                profileImageName: "profileImageName",
                emotionDatas: emotionDatas
            )
        }
    }
}
