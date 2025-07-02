internal import SwiftUI

struct ConversationTopicView: View {
    let topicDatas: [TopicData]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Topics")
                .modifier(TitleViewModifier())

            let columns = [
                GridItem(.flexible(), spacing: -5),
                GridItem(.flexible())
            ]

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(topicDatas, id: \.category) { topic in
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: topic.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(16)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(topic.category.rawValue)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(topic.percentage)%")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(16)
                    .frame(width: 140, height: 140)
                    .background(topic.category.color())
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }
            }
            .padding(.vertical, 8)
        }
        .modifier(CardViewModifier())
    }
}

struct ConversationTopicView_Previews: PreviewProvider {
    static var previews: some View {
        let topicDatas = [
            TopicData(category: .employment, percentage: 32, imageName: "imagename"),
            TopicData(category: .event, percentage: 32, imageName: "imagename"),
            TopicData(category: .food, percentage: 32, imageName: "imagename"),
            TopicData(category: .health, percentage: 32, imageName: "imagename"),
            TopicData(category: .love, percentage: 32, imageName: "imagename"),
            TopicData(category: .daily, percentage: 32, imageName: "imagename")
        ]
        ScrollView {
            ConversationTopicView(topicDatas: topicDatas)
        }
    }
}
