import SwiftUI
import AVKit

/// Cold-launch splash — never replays on foregrounding (RootView only creates
/// this once per process lifetime). Muted, looping Golden Hour runner clip
/// with a radial scrim, summit-M glyph, and wordmark. Auto-dismisses after
/// ~3.5s or on first tap. Falls back instantly to a static screen if the
/// bundled video can't load — launch is never blocked.
struct SplashView: View {
    var onFinished: () -> Void

    @State private var player: AVPlayer?
    @State private var videoFailed = false
    @State private var didFinish = false
    @State private var endObserver: NSObjectProtocol?
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            MVMTheme.screen.ignoresSafeArea()

            if let player, !videoFailed {
                VideoPlayer(player: player)
                    .disabled(true)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            RadialGradient(
                stops: [
                    .init(color: MVMTheme.screen.opacity(0.12), location: 0),
                    .init(color: MVMTheme.screen.opacity(0.78), location: 0.74),
                    .init(color: MVMTheme.screen.opacity(0.96), location: 1)
                ],
                center: .init(x: 0.5, y: 0.4),
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer()
                Image("mvm-glyph-summit-m")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64)
                Text("MVM FIT")
                    .font(.system(size: 15, weight: .bold))
                    .kerning(1.7)
                    .foregroundStyle(MVMTheme.text)
                Text("Me vs Me.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(MVMTheme.textMuted)
                Spacer().frame(height: 90)
            }
        }
        .opacity(opacity)
        .contentShape(Rectangle())
        .onTapGesture { finish() }
        .onAppear { setUpPlayer() }
        .onDisappear { tearDownPlayer() }
        .task {
            try? await Task.sleep(for: .seconds(3.5))
            finish()
        }
    }

    private func setUpPlayer() {
        guard player == nil, !videoFailed else { return }
        guard let url = Bundle.main.url(forResource: "splash-runner-loop", withExtension: "mp4") else {
            videoFailed = true
            return
        }
        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.isMuted = true
        newPlayer.actionAtItemEnd = .none
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }
        player = newPlayer
        newPlayer.play()
    }

    private func tearDownPlayer() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil
        player?.pause()
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        tearDownPlayer()
        withAnimation(.easeOut(duration: 0.5)) {
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onFinished()
        }
    }
}
