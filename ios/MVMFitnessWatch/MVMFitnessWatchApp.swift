import SwiftUI

@main
struct MVMFitnessWatchApp: App {
    @State private var viewModel = WatchViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                .task {
                    // Activate the phone link first so the first refresh has
                    // real data rather than the empty App Group defaults.
                    WatchConnectivityManager.shared.activate()
                    viewModel.refresh()
                }
        }
    }
}
