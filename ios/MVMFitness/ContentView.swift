import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("onboardingComplete") private var onboardingComplete: Bool = false
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false
    @State private var showSplash: Bool = true
    @State private var lockService = AppLockService()

    var body: some View {
        ZStack {
            if onboardingComplete {
                MainTabView()
                    .background(MVMTheme.background.ignoresSafeArea())
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .background(MVMTheme.background.ignoresSafeArea())
                    .transition(.opacity)
            }

            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            } else if appLockEnabled && !lockService.isUnlocked {
                AppLockView(lockService: lockService) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        // isUnlocked is already set by the service; this just
                        // triggers the view to re-render past the guard above.
                    }
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: onboardingComplete)
        .animation(.easeInOut(duration: 0.35), value: lockService.isUnlocked)
        .onAppear {
            if !appLockEnabled {
                lockService.unlockWithoutPrompt()
            }
        }
        .onChange(of: appLockEnabled) { _, enabled in
            if !enabled {
                lockService.unlockWithoutPrompt()
            } else {
                lockService.lock()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            guard appLockEnabled else { return }
            if newPhase == .background {
                lockService.lock()
            }
        }
    }
}
