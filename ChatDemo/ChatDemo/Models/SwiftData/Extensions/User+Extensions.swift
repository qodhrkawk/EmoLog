extension User {
    func toEntity() -> UserEntity {
        UserEntity(name: self.name, birthday: self.birthDay, imageName: self.imageName)
    }

    static func fromEntity(_ entity: UserEntity) -> User {
        User(name: entity.name, birthDay: entity.birthday, imageName: entity.imageName)
    }
}
