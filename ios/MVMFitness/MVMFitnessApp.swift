import SwiftUI
import AppIntents

@main
struct MVMFitnessApp: App {
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    @AppStorage("hasRequestedHealthKit") private var hasRequestedHealthKit: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = AppViewModel()

    init() {
        MVMAppShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(viewModel)
                .preferredColorScheme(AppearanceMode(rawValue: appearanceModeRaw)?.colorScheme)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        viewModel.pedometer.refreshTodaySteps()
                        Task {
                            try? await Task.sleep(for: .milliseconds(300))
                            viewModel.syncTodaySteps()
                        }
                        if hasRequestedHealthKit {
                            Task {
                                await viewModel.healthKit.refreshAll()
                            }
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .workoutLoggedViaSiri)) { _ in
                    viewModel.loadLocalData()
                }
        }
    }
}
