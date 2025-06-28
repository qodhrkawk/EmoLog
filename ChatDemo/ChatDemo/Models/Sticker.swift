import SwiftUI

enum Sticker: String, CaseIterable {
    case thumbsUp
    case party
    case angry
    case crying
    case laugh

    var image: Image {
        Image(systemName: "star.fill")
    }
}
