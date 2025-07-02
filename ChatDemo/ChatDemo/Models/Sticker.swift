import SwiftUI

enum Sticker: String, CaseIterable {
    case amazing
    case angry
    case fear
    case frustrated
    case joy
    case love
    case sad
    case shock

    var image: Image {
        Image(self.rawValue)
    }
    
    var description: String {
        rawValue
    }
}
