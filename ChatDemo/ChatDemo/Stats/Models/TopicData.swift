internal import SwiftUI

struct TopicData {
    let category: Category
    let percentage: Int
    let imageName: String
//    let color: Color
}

extension Category {
    func color() -> Color {
        switch self {
        case .work:
            return Color(red: 243/255, green: 232/255, blue: 255/255)
        case .food:
            return Color(red: 220/255, green: 252/255, blue: 231/255)
        case .study:
            return Color(red: 254/255, green: 249/255, blue: 195/255)
        case .hobby:
            return Color(red: 252/255, green: 231/255, blue: 243/255)
        case .health:
            return Color(red: 204/255, green: 251/255, blue: 241/255)
        case .trip:
            return Color(red: 224/255, green: 231/255, blue: 255/255)
        case .event:
            return Color(red: 255/255, green: 237/255, blue: 213/255)
        case .shopping:
            return Color(red: 255/255, green: 228/255, blue: 230/255)
        case .love:
            return Color(red: 254/255, green: 226/255, blue: 226/255)
        case .money:
            return Color(red: 209/255, green: 250/255, blue: 229/255)
        case .employment:
            return Color(red: 207/255, green: 250/255, blue: 254/255)
        case .daily:
            return Color(red: 239/255, green: 246/255, blue: 255/255)
        }
    }
}
