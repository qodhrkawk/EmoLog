internal import SwiftUI

struct CardViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(24)
            .frame(width: UIScreen.main.bounds.width - 32)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.15), radius: 7, x: 0, y: 3)
    }
}

struct TitleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .bold))
            .padding(8)
    }
}
