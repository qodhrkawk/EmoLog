import Foundation

struct Message: Identifiable {
    let id = UUID()
    let sender: User
    let text: String
}
