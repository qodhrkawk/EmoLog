import Foundation

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: date)
}

func formattedMonthDay(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M/d" // 한 자리 월/일도 허용
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: date)
}
