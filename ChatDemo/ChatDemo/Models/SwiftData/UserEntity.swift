import Foundation
import SwiftData

@Model
final class UserEntity {
    @Attribute(.unique)
    var name: String
    var birthday: Date?
    var imageName: String?

    init(name: String, birthday: Date? = nil, imageName: String? = nil) {
        self.name = name
        self.birthday = birthday
        self.imageName = imageName
    }
}

extension UserEntity {
    func toModel() -> User {
        User(name: self.name, birthDay: self.birthday, imageName: self.imageName)
    }
}
