internal import SwiftUI
import Combine

struct ChatView: View {
    @ObservedObject private var viewModel: ChatViewModel
    @StateObject private var keyboard = KeyboardObserver()
    @FocusState private var isTextFieldFocused: Bool
    @State private var showSettings = false
    @State private var showAnalysisOptions = false
    @State private var isStickerPanelVisible = false
    @State private var isMenuPanelVisible = false
    @State private var showStatsView = false
    @State private var showKeywordPopup = false
    
    @State private var reportStats: Stats?

    init(viewModel: ChatViewModel) {
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
                                    ChatBubble(message: message) { stats in
                                        self.reportStats = stats
                                        showStatsView = true
                                    }
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
                    .onTapGesture {
                        isStickerPanelVisible = false
                        isTextFieldFocused = false
                        isMenuPanelVisible = false
                    }
                }
                .onAppear {
                    scrollProxy.scrollTo("Bottom", anchor: .bottom)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        scrollProxy.scrollTo("Bottom", anchor: .bottom)
                    }
                }
                .onReceive(keyboard.$keyboardHeight.debounce(for: 0.2, scheduler: RunLoop.main)) { _ in
                    scrollProxy.scrollTo("Bottom", anchor: .bottom)
                }
                .onChange(of: viewModel.messages.last?.date) { _ in
                    scrollProxy.scrollTo("Bottom", anchor: .bottom)
                }
                .onChange(of: isStickerPanelVisible) { _ in
                    scrollProxy.scrollTo("Bottom", anchor: .bottom)
                }
                .onTapGesture {
                    isStickerPanelVisible = false
                    isTextFieldFocused = false
                    isMenuPanelVisible = false
                }
            }
            .background(Color.background)

            Divider()
            
            HStack(spacing: 8) {
                Button {
                    if isMenuPanelVisible == false {
                        hideKeyboard()
                        isStickerPanelVisible = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            isMenuPanelVisible.toggle()
                        }
                    }
                    else {
                        isMenuPanelVisible.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            isTextFieldFocused = true
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }

                HStack {
                    TextField("메시지를 입력하세요", text: $viewModel.inputText)
                        .focused($isTextFieldFocused)
                        .padding(.vertical, 8)

                    Button {
                        if isStickerPanelVisible == false {
                            hideKeyboard()
                            isMenuPanelVisible = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                isStickerPanelVisible.toggle()
                            }
                        }
                        else {
                            isStickerPanelVisible.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                isTextFieldFocused = true
                            }
                        }
                    } label: {
                        Image(systemName: isStickerPanelVisible ? "keyboard" : "face.smiling")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                            .padding(6) // 탭 영역 확보
                            .background(Color.clear) // 배경 없을 경우
                            .contentShape(Rectangle()) // 정확한 탭 영역 지정
                    }
                }
                .padding(.horizontal, 12)
                .background(Color(white: 0.95))
                .cornerRadius(20)

                if !viewModel.inputText.isEmpty {
                    Button {
                        viewModel.sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 78/255, green: 115/255, blue: 255/255))
                            .rotationEffect(.degrees(45))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
            
            if isStickerPanelVisible {
                StickerPanelView(onSelect: { sticker in
                    viewModel.sendSticker(sticker)
                })
                .transition(.identity)
            }
            if isMenuPanelVisible {
                menuPanel
            }
        }
        .animation(nil, value: keyboard.keyboardHeight)
        .animation(nil, value: isMenuPanelVisible)
        .animation(nil, value: showStatsView)
        .animation(nil, value: isTextFieldFocused)
        .animation(nil, value: isStickerPanelVisible)
        .background(Color(UIColor.systemBackground))
        .onAppear {
            viewModel.prewarm()
        }
        .onChange(of: viewModel.extractedKeyword) { keyword in
            handleKeywordChange(keyword)
        }
//        .onChange(of: viewModel.someInt, perform: handleKeywordChange)
//        .onTapGesture {
//            isTextFieldFocused = false
//        }
        .onChange(of: isTextFieldFocused) {
            isStickerPanelVisible = false
            isMenuPanelVisible = false
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
        .sheet(isPresented: $showStatsView) {
            statsSheet
        }
        .sheet(isPresented: $showSettings) {
            settingsSheet
        }
        .alert("\(viewModel.extractedKeyword?.popupTitle ?? "")", isPresented: $showKeywordPopup) {
            Button("Cancel", role: .cancel) {
                print("삭제 선택")
            }
            Button("\(viewModel.extractedKeyword?.proceedButtonTitle ?? "ㅇㅇ")", role: .confirm) {
                if let url = viewModel.extractedKeyword?.url {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("\(viewModel.extractedKeyword?.popupDescription ?? "ㅇㅇ")").font(.title)
        }
//        .overlay {
//            if showKeywordPopup, let keyword = viewModel.extractedKeyword {
//                VStack(spacing: 20) {
//                    Text(keyword.popupDescription)
//                        .font(.title2)
//                        .multilineTextAlignment(.center) // ✅ 가운데 정렬 가능
//                        .padding()
//
//                    HStack {
//                        Button("Cancel") {
//                            showKeywordPopup = false
//                        }
//                        Spacer()
//                        Button(keyword.proceedButtonTitle) {
//                            // Do something
//                            showKeywordPopup = false
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .padding()
//                .frame(maxWidth: 300)
//                .background(Color.white)
//                .cornerRadius(16)
//                .shadow(radius: 20)
//            }
//        }
    }
    
    var menuPanel: some View {
        MenuPanelView(
            onReportTap: handleReportTap,
            onSummaryTap: handleSummaryTap,
            onEmotionTap: handleEmotionTap,
            onKeywordTap: handleKeywordTap,
            onTranslateTap: handleTranslateTap
        )
    }

    private func handleReportTap() {
        showStatsView = true
        isMenuPanelVisible = false
    }

    private func handleSummaryTap() {
        isMenuPanelVisible = false
        viewModel.summarize()
    }

    private func handleEmotionTap() {
        isMenuPanelVisible = false
        viewModel.sentimentAnalysis()
    }

    private func handleKeywordTap() {
        isMenuPanelVisible = false
        viewModel.extractKeywords()
    }
    
    private func handleTranslateTap() {
        isMenuPanelVisible = false
//        viewModel.translate()
        viewModel.checkSpam()
    }

    private func groupedMessages() -> [(date: Date, messages: [any Message])] {
        let grouped = Dictionary(grouping: viewModel.messages) { message in
            Calendar.current.startOfDay(for: message.date)
        }
        return grouped
            .map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
    }
    
    private func handleKeywordChange(_ keyword: Keyword?) {
        if keyword != nil {
            showKeywordPopup = true
        }
    }
    
    @ViewBuilder
    private var statsSheet: some View {
        let statsViewModel = StatsViewModel(chatRoom: viewModel.chatRoom, stats: reportStats)
        StatsView(
            viewModel: statsViewModel,
            chatViewModel: viewModel,
            onShare: { stats in
                showStatsView = false
                viewModel.sendReport(stats)
            }
        )
    }

    @ViewBuilder
    private var settingsSheet: some View {
        VStack(spacing: 12) {
            Text("Settings")
                .font(.title2)
                .bold()

            Toggle("Enable Streaming Response", isOn: $viewModel.isStreamingEnabled)
                .padding()
            
            Button("Remove custom conversations") {
                viewModel.removeCustomMessages()
            }

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
                reportStats = nil
                showStatsView = true
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

struct StickerPanelView: View {
    let stickers = Sticker.allCases
    let onSelect: (Sticker) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(stickers, id: \.self) { sticker in
                Button {
                    onSelect(sticker)
                } label: {
                    sticker.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                        .padding(4)
                        .background(Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(Color(white: 0.95))
    }
}

struct MenuPanelView: View {
    let onReportTap: () -> Void
    let onSummaryTap: () -> Void
    let onEmotionTap: () -> Void
    let onKeywordTap: () -> Void
    let onTranslateTap: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0, alignment: .top), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            MenuButton(imageName: "report", isSystemImage: false, title: "Report", action: onReportTap)
            MenuButton(imageName: "doc.text.magnifyingglass", isSystemImage: true, title: "Summary", action: onSummaryTap)
            MenuButton(imageName: "face.smiling", isSystemImage: true, title: "Emotion", action: onEmotionTap)
            MenuButton(imageName: "tag", isSystemImage: true, title: "Keyword", action: onKeywordTap)
            MenuButton(imageName: "globe", isSystemImage: true, title: "Translate", action: onTranslateTap)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct MenuButton: View {
    let imageName: String
    let isSystemImage: Bool
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Group {
                    if isSystemImage {
                        Image(systemName: imageName)
                            .resizable()
                    } else {
                        Image(imageName)
                            .resizable()
                    }
                }
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(.black)

                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 72, height: 72)
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct KeywordPopup: View {
    let title: String
    let cancelTitle: String
    let confirmTitle: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 16) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    Button(action: onCancel) {
                        Text(cancelTitle)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }

                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .padding(.horizontal, 32)
            .shadow(radius: 10)
            .transition(.scale)
        }
    }
}
