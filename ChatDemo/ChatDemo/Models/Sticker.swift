import SwiftUI

enum Sticker: String, CaseIterable {
    case thumbsUp
    case party
    case angry
    case crying
    case laugh
    case love
    case happy
    case surprised
    case sad

    var image: Image {
        Image(systemName: "star.fill")
    }
    
    var description: String {
        rawValue
    }
}
