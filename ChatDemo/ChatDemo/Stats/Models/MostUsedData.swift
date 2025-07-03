import Foundation

struct MostUsedData {
    let sticker: Sticker
    let words: [Word]
}

struct Word {
    let id = UUID()
    let text: String
    let count: Int
}
