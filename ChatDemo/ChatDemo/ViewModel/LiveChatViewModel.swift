import Combine
import Foundation
import FoundationModels

// MARK: - ViewModel
class LiveChatViewModel: ObservableObject, ChatViewModel {
    @Published var messages: [Message]
    @Published var inputText: String = ""
    private let session: LanguageModelSession
    
    var isStreamingEnabled: Bool = false
    var isKorean: Bool = false
    
    init(messages: [Message]) {
        self.messages = messages
        session = LanguageModelSession(
            tools: [
                GetTodayTool(),
                GetFriendsTool(),
                GetBirthDayTool()
            ],
            instructions:
            """
            You are a chat bot in chat app.
            Based on given tools, you need to provide proper information for user.
            Use tools as much as possible.
            
            """
        )
    }
    
    func prewarm() {
        session.prewarm()
    }

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newMessage = Message(sender: User.me, text: inputText)
        messages.append(newMessage)
        inputText = ""
        
        Task {
            do {
                if isStreamingEnabled == false {
                    let response = try await session.respond(to: newMessage.text)
                    let botMessage = response.content
                    let newMessage = Message(sender: User.bot, text: botMessage)
                    messages.append(newMessage)
                }
                else {
                    let botMessage = Message(sender: User.bot, text: "")
                    messages.append(botMessage)
                    let botMessageIndex = messages.count - 1

                    // 2. Stream 시작
                    let stream = session.streamResponse(to: newMessage.text)
                    for try await partial in stream {
                        // 3. partial은 누적된 값이므로 바로 반영 가능
                        await MainActor.run {
                            messages[botMessageIndex] = Message(sender: User.bot, text: partial)
                        }
                    }
                }
            }
            catch {
                let newMessage = Message(sender: User.bot, text: error.localizedDescription)
                messages.append(newMessage)
            }
        }

    }
    
    func anlayze(type: ChatAnalysis) { }
    
    func birthday() {
        Task {
            do {
                let botMessage = Message(sender: User.bot, text: "")
                messages.append(botMessage)
                let botMessageIndex = messages.count - 1

                // 2. Stream 시작
                let stream = session.streamResponse(generating: GeneratedUser.self) {
                    """
                    Whose birthday is coming up next among my friends?
                    Use all of tools you can use.
                    """
                }
                for try await partial in stream {
                    // 3. partial은 누적된 값이므로 바로 반영 가능
                    let generatedUser = partial
                    await MainActor.run {
                        messages[botMessageIndex] = Message(
                            sender: User.bot,
                            text: "The birthday of \(generatedUser.name ?? "Unknown") is coming up next!, which is \(generatedUser.birthday)"
                        )
                    }
                }
            }
            catch {
                
            }
        }
    }
}

struct GetTodayTool: Tool {
    let description = "Get today's date by this tool"

    @Generable
    struct Arguments {}
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        let date = currentDateString()
        print("YJKIM GetTodayTool is Called: \(date)")
        return ToolOutput(date)
    }
    
    func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
}

@Generable
struct GeneratedUser {
    @Guide(description: "A name of user")
    let name: String?
    @Guide(description: "Birthday of user")
    let birthday: String?
}

extension User {
    func toGeneratedUser() -> GeneratedUser {
        var birthdayString: String?
        if let birthDay {
            birthdayString = stringFromDate(birthDay)
        }
        return GeneratedUser(name: name, birthday: birthdayString)
    }
}

struct GetFriendsTool: Tool {
    let description = "Get friends' name by this tool. The friend's names will be separated by comma."
    
    @Generable
    struct Arguments {
        
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        let friends = User.friends
        let friendString = User.friends.map { $0.name }.joined(separator: ",")
        print("YJKIM GetFriendsTool Called: \(friendString)")
        
        return ToolOutput(friendString)
    }
}

struct GetBirthDayTool: Tool {
    let description = "Get birthday information from this tool. The input is a name. The output is a birthday."
    

    @Generable
    struct Arguments {
        @Guide(description: "A friend's name")
        let userName: String
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        let friends = User.friends
        guard let birthDay = friends.first(where: { $0.name == arguments.userName })?.birthDay else {
            print("YJKIM Fail to load: \(arguments.userName)")
            return ToolOutput("Fail to load")
        }
        
        let birthDayString = stringFromDate(birthDay)
        
        print("YJKIM GetBirthDayTool is Called: \(arguments.userName) :  \(birthDayString)")
        return ToolOutput(birthDayString)
    }
}

func stringFromDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: date)
}
