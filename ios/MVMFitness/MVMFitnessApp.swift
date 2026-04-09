import SwiftUI
import AppIntents
import RevenueCat

@main
struct MVMFitnessApp: App {
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = AppViewModel()
    @State private var store = StoreViewModel()

    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif
        MVMFitnessShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(viewModel)
                .environment(store)
                .preferredColorScheme(AppearanceMode(rawValue: appearanceModeRaw)?.colorScheme)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        viewModel.pedometer.refreshTodaySteps()
                        Task {
                            try? await Task.sleep(for: .milliseconds(300))
                            viewModel.syncTodaySteps()
                        }
                        viewModel.syncWidgetData()
                    }
                }
        }
    }
}
