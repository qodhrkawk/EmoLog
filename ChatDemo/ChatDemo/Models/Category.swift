import Foundation
import FoundationModels

@Generable(description: "Conversation's main category")
struct ConversationCategory {
    @Guide(description: "The identified category")
    let category: Category
    @Guide(
        description: """
        The percentage of confidence score from 10 to 100.
        Use the full range as needed: low scores (10~40) indicate weak signals, mid scores (41~70) are moderate, and high scores (71~100) are strong.
        """,
        .range(10...100)
    )
    let confidence: Int
}

@Generable(description: "A category of conversation.")
enum Category: String {
//    case work
//    case food
//    case study
//    case hobby
//    case health
//    case trip
//    case event
//    case shopping
//    case love
//    case money
//    case employment
//    case daily
    case photo
    case sticker
    case shop
    case vote
    case money
    case map
}

@Generable(description: "Conversation's main keyword")
struct ConversationKeyword {
    @Guide(description: "The identified keyword")
    let keyword: Keyword

    @Guide(
        description: """
        The percentage of confidence score from 10 to 100.
        """,
        .range(10...100)
    )
    let confidence: Int
}

@Generable(description: "A keyword of conversation.")
enum Keyword: String, Equatable, Identifiable {
    case photo
    case sticker
    case congrats
    case vote
    case money
    case map
    case font

    var id: String { rawValue }
}

extension Keyword {
//    var toInternal: InternalKeyword {
//        switch self {
//        case .photo:
//                .photo
//        case .sticker:
//                .sticker
//        case .shop:
//                .shop
//        case .vote:
//                .vote
//        case .money:
//                .money
//        case .map:
//                .map
//        }
//    }
//    
    var popupTitle: String {
        switch self {
        case .photo:
            return "Need to check album?"
        case .sticker:
            return "Check out sticker you like!"
        case .congrats:
            return "Send a gift to friend!"
        case .vote:
            return "Need to vote?"
        case .money:
            return "Need to send money?"
        case .map:
            return "Check out map!"
        case .font:
            return "Interested in new font?"
        }
    }

    var popupDescription: String {
        switch self {
        case .photo:
            return "Check the photos in album!"
        case .sticker:
            return "Visit Sticker shop and find your favorite sticker!"
        case .congrats:
            return "Visit Gift shop and send a gift to friend!"
        case .vote:
            return "Make a vote with friends!"
        case .money:
            return "Send money with LINE PAY!"
        case .map:
            return "Check out map!"
        case .font:
            return "Check out new fonts in font page"
        }
    }

    var proceedButtonTitle: String {
        switch self {
        case .photo: return "Album"
        case .sticker: return "Sticker Shop"
        case .congrats: return "Gift Shop"
        case .vote: return "Make vote"
        case .money: return "LINE PAY"
        case .map: return "MAP"
        case .font: return "Font Settings"
        }
    }
    
    var url: URL? {
        switch self {
        case .font: return URL(string: "lineb://nv/settings/premiumFont")
        case .photo: return URL(string: "lineb://moa/albums/photo")
        case .sticker: return URL(string: "lineb://nv/stickerShop/mySticker")
        default: return URL(string: "lineb://nv/settings/premiumFont")
        }
    }
}

enum InternalKeyword: Equatable {
    case photo
    case sticker
    case shop
    case vote
    case money
    case map
    
    
}


extension Category {
    var imageName: String {
        "category_\(rawValue)"
    }
}
