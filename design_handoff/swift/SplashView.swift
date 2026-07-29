import SwiftUI
import AVKit

/// Cold-launch only — never on foregrounding. Muted looping golden-hour runner
/// clip (assets/splash-runner-loop.mp4; transcode H.265 ≤3MB before bundling),
/// radial scrim, summit-M glyph + wordmark. Auto-dismisses after ~3.5s or first tap.
struct SplashView: View {
    @Binding var isPresented: Bool
    private let player: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "splash-runner-loop", withExtension: "mp4")
        else { return AVPlayer() }
        let p = AVPlayer(url: url)
        p.isMuted = true
        p.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: p.currentItem, queue: .main) { _ in
            p.seek(to: .zero); p.play()
        }
        return p
    }()

    var body: some View {
        ZStack {
            VideoPlayer(player: player).disabled(true).ignoresSafeArea()
                .onAppear { player.play() }
            RadialGradient(stops: [
                .init(color: MVMTheme.screen.opacity(0.12), location: 0),
                .init(color: MVMTheme.screen.opacity(0.78), location: 0.74),
                .init(color: MVMTheme.screen.opacity(0.96), location: 1)],
                center: .init(x: 0.5, y: 0.4), startRadius: 0, endRadius: 500)
                .ignoresSafeArea()
            VStack(spacing: 14) {
                Spacer()
                Image("mvm-glyph-summit-m")   // brand glyph asset (not an SF Symbol; brand mark is exempt)
                    .resizable().scaledToFit().frame(width: 64)
                Text("MVM FIT")
                    .font(.system(size: 15, weight: .bold)).kerning(1.7)
                    .foregroundStyle(MVMTheme.text)
                Text("Me vs Me.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(MVMTheme.textMuted)
                Spacer().frame(height: 90)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { dismiss() }
        .task {
            try? await Task.sleep(for: .seconds(3.5))
            dismiss()
        }
    }
    private func dismiss() {
        player.pause()
        withAnimation(.easeOut(duration: 0.4)) { isPresented = false }
    }
}

// App entry: show splash once per cold launch.
// @main struct MVMApp: App {
//     @State private var showSplash = true
//     var body: some Scene {
//         WindowGroup {
//             ZStack { MainTabView(); if showSplash { SplashView(isPresented: $showSplash) } }
//         }
//     }
// }
