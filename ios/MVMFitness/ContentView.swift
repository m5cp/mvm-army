import SwiftUI

struct RootView: View {
    var body: some View {
        MainTabView()
            .background(MVMTheme.background.ignoresSafeArea())
            .onAppear {
                UserDefaults.standard.set(true, forKey: "onboardingComplete")
            }
    }
}
