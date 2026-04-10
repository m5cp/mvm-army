import SwiftUI

struct MilestoneCelebrationView: View {
    let milestone: Milestone
    let onDismiss: () -> Void
    let onShare: () -> Void
    let onUpgrade: (() -> Void)?

    @State private var iconScale: CGFloat = 0.3
    @State private var contentOpacity: Double = 0
    @State private var ringRotation: Double = 0
    @State private var particleOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(MVMTheme.accent.opacity(0.2), lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(ringRotation))

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [MVMTheme.accent.opacity(0.25), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .opacity(particleOpacity)

                    Image(systemName: milestone.icon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(MVMTheme.accent)
                        .scaleEffect(iconScale)
                }

                VStack(spacing: 10) {
                    Text(milestone.title)
                        .font(.title.weight(.heavy))
                        .foregroundStyle(.white)

                    Text(milestone.message)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .opacity(contentOpacity)

                VStack(spacing: 10) {
                    Button {
                        let text = milestone.shareText
                        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootVC = windowScene.windows.first?.rootViewController else { return }
                        var presenter = rootVC
                        while let presented = presenter.presentedViewController {
                            presenter = presented
                        }
                        if let popover = activityVC.popoverPresentationController {
                            popover.sourceView = presenter.view
                            popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
                            popover.permittedArrowDirections = []
                        }
                        presenter.present(activityVC, animated: true)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.subheadline.weight(.bold))
                            Text("Share Achievement")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(height: 52)
                        .frame(maxWidth: .infinity)
                        .background(MVMTheme.heroGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PressScaleButtonStyle())

                    if let onUpgrade, milestone.suggestUpgrade {
                        Button {
                            onUpgrade()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "crown.fill")
                                    .font(.subheadline.weight(.bold))
                                Text("Unlock Pro")
                                    .font(.headline.weight(.bold))
                            }
                            .foregroundStyle(MVMTheme.heroAmber)
                            .frame(height: 52)
                            .frame(maxWidth: .infinity)
                            .background(MVMTheme.heroAmber.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(MVMTheme.heroAmber.opacity(0.3))
                            }
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }

                    Button {
                        onDismiss()
                    } label: {
                        Text("Continue")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
                .opacity(contentOpacity)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                contentOpacity = 1.0
                particleOpacity = 1.0
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }
        .sensoryFeedback(.success, trigger: iconScale)
    }
}

struct MilestoneOverlayModifier: ViewModifier {
    @Environment(AppViewModel.self) private var vm
    @Environment(StoreViewModel.self) private var store

    @State private var showUpgrade: Bool = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if let milestone = vm.activeMilestone {
                    MilestoneCelebrationView(
                        milestone: milestone,
                        onDismiss: { vm.dismissMilestone() },
                        onShare: {},
                        onUpgrade: store.isPremium ? nil : {
                            vm.dismissMilestone()
                            showUpgrade = true
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .zIndex(100)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.activeMilestone != nil)
            .sheet(isPresented: $showUpgrade) {
                UpgradeView()
            }
    }
}

extension View {
    func milestoneOverlay() -> some View {
        modifier(MilestoneOverlayModifier())
    }
}
