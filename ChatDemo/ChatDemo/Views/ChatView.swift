import SwiftUI
import Combine

struct ChatView<ViewModel: ChatViewModel & ObservableObject>: View {
    @ObservedObject private var viewModel: ViewModel
    @StateObject private var keyboard = KeyboardObserver()
    @FocusState private var isTextFieldFocused: Bool
    @State private var showSettings = false
    @State private var showAnalysisOptions = false
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                        }
                        Spacer()
                        Color.clear
                            .frame(height: 1)
                            .id("Bottom")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        scrollProxy.scrollTo("Bottom", anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.messages.last?.text.count) { _ in
                    withAnimation {
                        scrollProxy.scrollTo("Bottom", anchor: .bottom)
                    }
                }
                .onChange(of: keyboard.keyboardHeight) { _ in
                    withAnimation {
                        scrollProxy.scrollTo("Bottom", anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack {
                Button(action: {
                    showAnalysisOptions = true
                }) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 24))
                }
                TextField("메시지를 입력하세요", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextFieldFocused)
                if !viewModel.inputText.isEmpty {
                    Button("전송") {
                        viewModel.sendMessage()
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
        }
        .background(Color.background)
        .onAppear {
            viewModel.prewarm()
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            VStack(spacing: 12) {
                Text("Settings")
                    .font(.title2)
                    .bold()
                Toggle("Enable Streaming Response", isOn: $viewModel.isStreamingEnabled)
                    .padding()
                if let _ = viewModel as? ArchivedChatViewModel {
                    Toggle("Convert to Korean", isOn: $viewModel.isKorean)
                        .padding()
                }

                Spacer()
            }
            .padding()
            .presentationDetents([.height(200)])
        }
        .sheet(isPresented: $showAnalysisOptions) {
            if let viewModel = viewModel as? ArchivedChatViewModel {
                VStack(spacing: 16) {
                    Text("Choose Analysis")
                        .font(.headline)
                    
                    ForEach(ChatAnalysis.allCases) { analysis in
                        Button(analysis.label) {
                            showAnalysisOptions = false
                            viewModel.anlayze(type: analysis)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button("Cancel") {
                        showAnalysisOptions = false
                    }
                    .foregroundColor(.red)
                }
                .padding()
                .presentationDetents([.height(400)])
            }
            else if let viewModel = viewModel as? LiveChatViewModel {
                VStack(spacing: 16) {
                    Text("Choose Analysis")
                        .font(.headline)
                    
                    Button("Get birthday") {
                        showAnalysisOptions = false
                        viewModel.birthday()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button("Cancel") {
                        showAnalysisOptions = false
                    }
                    .foregroundColor(.red)
                }
                .padding()
                .presentationDetents([.height(200)])
            }
        }
    }
}



// MARK: - Color Extension
extension Color {
    static let background = Color(red: 140/255, green: 171/255, blue: 217/255)
    static let messageGreen = Color(red: 109/255, green: 230 / 255, blue: 124 / 255)
}
