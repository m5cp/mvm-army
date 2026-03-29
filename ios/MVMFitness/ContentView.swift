import SwiftUI

struct RootView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete: Bool = false
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        if onboardingComplete {
            MainTabView()
                .background(MVMTheme.background.ignoresSafeArea())
        } else {
            OnboardingView()
        }
    }
}
