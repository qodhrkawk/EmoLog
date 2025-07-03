import Foundation

protocol Message: Identifiable {
    var id: UUID { get }
    var sender: User { get }
    var date: Date { get }
}

struct TextMessage: Message {
    let id: UUID
    let sender: User
    let text: String
    let date: Date
    
    init(id: UUID = UUID(), sender: User, text: String, date: Date = Date()) {
        self.id = id
        self.sender = sender
        self.text = text
        self.date = date
    }
}

struct StickerMessage: Message {
    let id: UUID
    let sender: User
    let sticker: Sticker
    let date: Date
    
    init(id: UUID = UUID(), sender: User, sticker: Sticker, date: Date = Date()) {
        self.id = id
        self.sender = sender
        self.sticker = sticker
        self.date = date
    }
}

struct ReportMessage: Message {
    let id: UUID
    let date: Date
    let sender: User
    let stats: Stats
    
    init(id: UUID = UUID(), sender: User, stats: Stats, date: Date = Date()) {
        self.id = id
        self.sender = sender
        self.stats = stats
        self.date = date
    }
}
