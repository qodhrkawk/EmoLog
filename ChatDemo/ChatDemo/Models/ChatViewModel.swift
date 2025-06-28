import Combine

protocol ChatViewModel: AnyObject, ObservableObject {
    var messages: [Message] { get }
    var inputText: String { get set }
    var isStreamingEnabled: Bool { get set }
    var isKorean: Bool { get set }

    func sendMessage()
    func prewarm()
    func anlayze(type: ChatAnalysis)
}
