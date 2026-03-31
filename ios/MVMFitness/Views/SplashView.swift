import SwiftUI

struct SplashView: View {
    @State private var iconScale: Double = 0.3
    @State private var iconOpacity: Double = 0
    @State private var iconRotation: Double = -30
    @State private var ringScale: Double = 0.5
    @State private var ringOpacity: Double = 0
    @State private var ring2Scale: Double = 0.4
    @State private var ring2Opacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: Double = 20
    @State private var subtitleOpacity: Double = 0
    @State private var shimmerPhase: Double = -200
    @State private var particlesVisible: Bool = false
    @State private var pulseScale: Double = 1.0

    var onFinished: () -> Void

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            backgroundParticles

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [MVMTheme.accent.opacity(0.3), MVMTheme.accent2.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(ring2Scale)
                        .opacity(ring2Opacity)

                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [MVMTheme.accent.opacity(0.5), MVMTheme.accent2.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: 130, height: 130)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [MVMTheme.accent.opacity(0.15), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)
                        .opacity(ringOpacity * 0.6)

                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .shadow(color: MVMTheme.accent.opacity(0.5), radius: 20, y: 5)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .rotationEffect(.degrees(iconRotation))
                }

                VStack(spacing: 8) {
                    Text("MVM FITNESS")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .tracking(4)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay {
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.4), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .offset(x: shimmerPhase)
                            .mask {
                                Text("MVM FITNESS")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .tracking(4)
                            }
                        }
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)

                    Text("MILITARY GRADE TRAINING")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(MVMTheme.secondaryText)
                        .opacity(subtitleOpacity)
                }

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            runAnimation()
        }
    }

    private var backgroundParticles: some View {
        Canvas { context, size in
            guard particlesVisible else { return }
            let positions: [(x: Double, y: Double, r: Double)] = [
                (0.15, 0.2, 2), (0.85, 0.15, 1.5), (0.3, 0.7, 2.5),
                (0.7, 0.8, 1.8), (0.5, 0.35, 1.2), (0.9, 0.5, 2),
                (0.1, 0.55, 1.8), (0.6, 0.15, 1.5), (0.4, 0.85, 2),
                (0.8, 0.4, 1.3), (0.2, 0.9, 1.6), (0.95, 0.7, 1.4),
            ]
            for p in positions {
                let point = CGPoint(x: p.x * size.width, y: p.y * size.height)
                let rect = CGRect(x: point.x - p.r, y: point.y - p.r, width: p.r * 2, height: p.r * 2)
                context.fill(Circle().path(in: rect), with: .color(MVMTheme.accent.opacity(0.25)))
            }
        }
        .opacity(particlesVisible ? 1 : 0)
        .animation(.easeIn(duration: 1.0), value: particlesVisible)
    }

    private func runAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
            iconScale = 1.0
            iconOpacity = 1.0
            iconRotation = 0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.55)) {
            ring2Scale = 1.0
            ring2Opacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            titleOpacity = 1.0
            titleOffset = 0
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.9)) {
            subtitleOpacity = 1.0
        }

        withAnimation(.easeInOut(duration: 0.8).delay(1.0)) {
            shimmerPhase = 400
        }

        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.6)) {
            pulseScale = 1.15
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            particlesVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            onFinished()
        }
    }
}
