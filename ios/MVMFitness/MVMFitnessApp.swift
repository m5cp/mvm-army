import SwiftUI
import AppIntents
import RevenueCat

@main
struct MVMFitnessApp: App {
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
        AnalyticsService.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(viewModel)
                .environment(store)
                .preferredColorScheme(.dark)
                .task {
                    DataStore.purgeDeviceOnlyKeysFromCloud()
                    PhoneConnectivityManager.shared.activate()
                    // Without this the phone received a pace edit from the watch
                    // and discarded it, so the link was one-directional.
                    PhoneConnectivityManager.shared.onTargetPaceChanged = { _ in
                        viewModel.syncWidgetData()
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        // Re-check the access grant here as well as at launch,
                        // so a code that lapsed while the app was backgrounded
                        // does not stay unlocked until the next cold start.
                        ComplimentaryAccessService.shared.refresh()
                        viewModel.pedometer.refreshTodaySteps()
                        Task {
                            try? await Task.sleep(for: .milliseconds(300))
                            viewModel.syncTodaySteps()
                        }
                        viewModel.syncWidgetData()
                    }
                    if newPhase == .background {
                        // Persistence writes are asynchronous so they stay off
                        // the main thread; block briefly here so a swipe-kill
                        // right after a workout cannot lose it.
                        viewModel.persistAll()
                        DataStore.flush()
                    }
                }
        }
    }
}
