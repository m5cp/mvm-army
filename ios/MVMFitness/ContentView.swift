import SwiftUI

struct RootView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete: Bool = false
    @Environment(AppViewModel.self) private var vm
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            if onboardingComplete {
                MainTabView()
                    .background(MVMTheme.background.ignoresSafeArea())
            } else {
                OnboardingView()
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
    }
}
