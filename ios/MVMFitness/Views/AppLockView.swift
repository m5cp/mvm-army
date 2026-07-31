import SwiftUI

/// Full-screen biometric gate shown on cold launch and on returning from the
/// background when App Lock is enabled. Mirrors SplashView's mark/wordmark
/// treatment so the transition into the locked state feels intentional
/// rather than jarring.
struct AppLockView: View {
    let lockService: AppLockService
    var onUnlocked: () -> Void

    @State private var isAuthenticating = false

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                Image("mvm-glyph-summit-m")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56)

                VStack(spacing: 6) {
                    Text("MVM FIT LOCKED")
                        .font(.system(size: 14, weight: .bold))
                        .kerning(1.6)
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Use \(lockService.biometryLabel) to continue")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                if let error = lockService.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(MVMTheme.danger)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 4)
                }

                Spacer()

                Button {
                    attemptUnlock()
                } label: {
                    HStack(spacing: 10) {
                        if isAuthenticating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: biometryIcon)
                        }
                        Text(isAuthenticating ? "Authenticating…" : "Unlock")
                    }
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.heroGradient)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(isAuthenticating)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("App locked. \(lockService.lastError ?? "Use \(lockService.biometryLabel) to continue.")")
        .onAppear { attemptUnlock() }
    }

    private var biometryIcon: String {
        switch lockService.biometryLabel {
        case "Face ID": return "faceid"
        case "Touch ID": return "touchid"
        case "Optic ID": return "opticid"
        default: return "lock.fill"
        }
    }

    private func attemptUnlock() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        Task {
            let success = await lockService.authenticate()
            isAuthenticating = false
            if success {
                onUnlocked()
            }
        }
    }
}
