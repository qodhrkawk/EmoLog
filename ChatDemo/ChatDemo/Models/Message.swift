import Foundation

enum MessageType {
    case text(String)
    case sticker(Sticker)
}

struct Message: Identifiable {
    let id = UUID()
    let sender: User
    let type: MessageType
    let date: Date
    
    var text: String {
        switch type {
        case .text(let text): return text
        case .sticker(let sticker): return "Sticker"
        }
    }
    
    init(sender: User, text: String, date: Date = Date()) {
        self.sender = sender
        self.type = .text(text)
        self.date = date
    }
    
    init(sender: User, sticker: Sticker, date: Date = Date()) {
        self.sender = sender
        self.type = .sticker(sticker)
        self.date = date
    }
}
