import Foundation

struct User: Identifiable, Hashable {
    let name: String
    let birthDay: Date?
    let imageName: String?

    var id: String { name }
    

    init(name: String, birthDay: Date? = nil, imageName: String? = nil) {
        self.name = name
        self.birthDay = birthDay
        self.imageName = imageName
    }
}

extension User {
    static let me = User(name: "Me", birthDay: dateFromString("1996-01-10"))
    static let junhyuk = User(name: "Junhyuk", birthDay: dateFromString("1991-05-01"))
    static let hyeonji = User(name: "Hyeonji", birthDay: dateFromString("1993-08-01"))
    static let jongyoun = User(name: "Jongyoun", birthDay: dateFromString("1989-03-12"))
    static let wonseob = User(name: "Wonseob", birthDay: dateFromString("1991-01-15"))
    static let bot = User(name: "Bot")
    
    static let cony = User(name: "Cony", imageName: "cony_profile")
    
    static let friends = [junhyuk, hyeonji, jongyoun, wonseob, cony]
    static let allUsers = [me] + friends + [bot]
}


