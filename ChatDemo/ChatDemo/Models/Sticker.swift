internal import SwiftUI
import FoundationModels

@Generable
enum Sticker: String, CaseIterable {
    case amazing
    case angry
    case fear
    case frustrated
    case joy
    case love
    case sad
    case shock
}

extension Sticker {
    var image: Image {
        Image(self.imageName)
    }
    
    var description: String {
        rawValue
    }
    
    var imageName: String {
        rawValue
    }
    
//    var emotion: Emotion {
//        switch self {
//            
//        }
//    }
}
