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
                        ForEach(groupedMessages(), id: \.date) { group in
                            Section(
                                header:
                                    Text(formattedDate(group.date))
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.black.opacity(0.4))
                                        )
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 8)
                            ) {
                                ForEach(group.messages, id: \.id) { message in
                                    ChatBubble(message: message)
                                }
                            }
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
                .onChange(of: viewModel.messages.last?.date) { _ in
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
                Button {
                    showAnalysisOptions = true
                } label: {
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
            settingsSheet
        }
        .sheet(isPresented: $showAnalysisOptions) {
            analysisSheet
        }
    }

    // MARK: - Helpers

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }

    private func groupedMessages() -> [(date: Date, messages: [any Message])] {
        let grouped = Dictionary(grouping: viewModel.messages) { message in
            Calendar.current.startOfDay(for: message.date)
        }
        return grouped
            .map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
    }

    @ViewBuilder
    private var settingsSheet: some View {
        VStack(spacing: 12) {
            Text("Settings")
                .font(.title2)
                .bold()

            Toggle("Enable Streaming Response", isOn: $viewModel.isStreamingEnabled)
                .padding()

            Spacer()
        }
        .padding()
        .presentationDetents([.height(200)])
    }

    @ViewBuilder
    private var analysisSheet: some View {
        VStack(spacing: 16) {
            Text("Choose Analysis")
                .font(.headline)
            Button("Make Report") {
                showAnalysisOptions = false
                viewModel.makeReport()
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
        .presentationDetents([.height(400)])
    }
}

// MARK: - Color Extension

extension Color {
    static let background = Color(red: 140/255, green: 171/255, blue: 217/255)
    static let messageGreen = Color(red: 109/255, green: 230/255, blue: 124/255)
}
