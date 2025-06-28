import FoundationModels

@Generable(description: "A keyword extracted from conversation.")
enum Keyword: String {
    case money
    case photo
    case map
    case sticker
//    case chatHistory
    case congratulations
    case none
}

