import Foundation
import SwiftData

@Model
final class UserEntity {
    @Attribute(.unique)
    var name: String
    var birthday: Date?

    init(name: String, birthday: Date? = nil) {
        self.name = name
        self.birthday = birthday
    }
}

extension UserEntity {
    func toModel() -> User {
        User(name: self.name, birthDay: self.birthday)
    }
}
