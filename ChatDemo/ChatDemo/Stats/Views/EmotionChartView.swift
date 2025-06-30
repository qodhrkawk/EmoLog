import SwiftUI
import Charts

struct EmotionChartView: View {
    let title: String
    let emotionDatas: [EmotionData]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding()
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
            .chartForegroundStyleScale([
                Emotion.joy.rawValue: .yellow,
                Emotion.sadness.rawValue: .blue,
                Emotion.anger.rawValue: .red,
                Emotion.fear.rawValue: .purple,
                Emotion.surprise.rawValue: .orange,
                Emotion.love.rawValue: .pink
            ])
            .frame(height: 230)
            .padding(.horizontal)
        }
        .modifier(CardViewModifier())
    }
}
