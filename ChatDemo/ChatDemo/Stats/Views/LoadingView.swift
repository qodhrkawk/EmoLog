internal import SwiftUI

struct LoadingView: View {
    @State private var currentIndex = 0
    @State private var timer: Timer?

    let images = ["inprogress1", "inprogress2", "inprogress3"]

    var body: some View {
        VStack(spacing: 30) {
            Text("Emotion analysis in progress")
                .font(.headline)
            Image(images[currentIndex])
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .transition(.opacity)
                .animation(.easeInOut, value: currentIndex)
        }
        .padding()
        .onAppear {
            startImageRotation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startImageRotation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            currentIndex = (currentIndex + 1) % images.count
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
