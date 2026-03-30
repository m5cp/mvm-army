import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            MainTabView()
                .background(MVMTheme.background.ignoresSafeArea())

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
