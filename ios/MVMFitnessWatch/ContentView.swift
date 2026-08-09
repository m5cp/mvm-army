import SwiftUI

struct ContentView: View {
    @Environment(WatchViewModel.self) private var viewModel
    @Environment(\.scenePhase) private var scenePhase
    private var link = WatchConnectivityManager.shared

    var body: some View {
        TabView {
            WatchHomeView()
            NavigationStack {
                WatchWorkoutView()
            }
            WatchStatsView()
            WatchWorkoutTimerView()
            WatchAFTView()
        }
        .tabViewStyle(.verticalPage)
        .onAppear { viewModel.refresh() }
        // Data only refreshed once at launch, so anything that changed on the
        // phone afterwards never appeared. Re-read on every foreground and
        // whenever a fresh snapshot lands over Watch Connectivity.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.refresh() }
        }
        .onChange(of: link.revision) { _, _ in viewModel.refresh() }
    }
}
