import Foundation

struct User: Identifiable, Hashable {
    let name: String
    let birthDay: Date?
    
    var id: String { name }

    init(name: String, birthDay: Date? = nil) {
        self.name = name
        self.birthDay = birthDay
    }
}

extension User {
    static let me = User(name: "Me", birthDay: dateFromString("1996-01-10"))
    static let junhyuk = User(name: "Junhyuk", birthDay: dateFromString("1991-05-01"))
    static let hyeonji = User(name: "Hyeonji", birthDay: dateFromString("1993-08-01"))
    static let jongyoun = User(name: "Jongyoun", birthDay: dateFromString("1989-03-12"))
    static let wonseob = User(name: "Wonseob", birthDay: dateFromString("1991-01-15"))
    static let bot = User(name: "Bot")
    
    static let friends = [junhyuk, hyeonji, jongyoun, wonseob]
    static let allUsers = [me] + friends + [bot]
    
    static func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX") // 항상 고정된 포맷을 쓰고 싶을 때
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // 필요에 따라 조정

        return formatter.date(from: dateString)
    }
}

