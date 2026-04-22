import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var vm
    @AppStorage("onboardingComplete") private var onboardingComplete: Bool = false
    @State private var showSplash: Bool = true

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
            }
        }
        .animation(.easeInOut(duration: 0.35), value: onboardingComplete)
    }
}
