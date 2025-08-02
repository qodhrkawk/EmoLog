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
    static let me = User(name: "Me", birthDay: dateFromString("1996-01-10"), imageName: "my_profile")
    static let junhyuk = User(name: "Junhyuk", birthDay: dateFromString("1991-05-01"))
    static let hyeonji = User(name: "Hyeonji", birthDay: dateFromString("1993-08-01"))
    static let jongyoun = User(name: "Jongyoun", birthDay: dateFromString("1989-03-12"))
    static let wonseob = User(name: "Wonseob", birthDay: dateFromString("1991-01-15"))
    static let bot = User(name: "Bot")
    static let akihiro = User(name: "akihiro")
    static let myName = "Brown"
    
    static let sampleUsers = [userA, userB, userC, userD, userE, userF, userG, userH, userI, userJ, userK]
    static let userA = User(name: "UserA", birthDay: dateFromString("1991-05-01"))
    static let userB = User(name: "UserB", birthDay: dateFromString("1991-05-01"))
    static let userC = User(name: "UserC", birthDay: dateFromString("1991-05-01"))
    static let userD = User(name: "UserD", birthDay: dateFromString("1991-05-01"))
    static let userE = User(name: "UserE", birthDay: dateFromString("1991-05-01"))
    static let userF = User(name: "UserF", birthDay: dateFromString("1991-05-01"))
    static let userG = User(name: "UserG", birthDay: dateFromString("1991-05-01"))
    static let userH = User(name: "UserH", birthDay: dateFromString("1991-05-01"))
    static let userI = User(name: "UserI", birthDay: dateFromString("1991-05-01"))
    static let userJ = User(name: "UserJ", birthDay: dateFromString("1991-05-01"))
    static let userK = User(name: "UserK", birthDay: dateFromString("1991-05-01"))

    static let cony = User(name: "Cony", imageName: "cony_profile")
    
    static let friends = [junhyuk, hyeonji, jongyoun, wonseob, cony]
    static let allUsers = [me] + friends + [bot]
}


