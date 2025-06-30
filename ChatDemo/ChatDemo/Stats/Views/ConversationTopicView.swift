import SwiftUI

struct ConversationTopicView: View {
    let topicDatas: [TopicData]

    var body: some View {
        return VStack(alignment: .leading) {
            Text("대화 주제")
                .font(.headline)
                .padding()

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 20
            ) {
                ForEach(topicDatas, id: \.title) { topic in
                    VStack {
                        Image(systemName: topic.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 30)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)


                        VStack {
                            Text(topic.title)
                                .font(.headline)

                            Text("\(topic.percentage)%")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                    }
                    .padding()
                    .background(topic.color.opacity(0.08))
                    .cornerRadius(15)
                }
            }
            .padding()
        }
        .modifier(CardViewModifier())
    }
}

