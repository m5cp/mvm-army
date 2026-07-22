import SwiftUI

struct ContentView: View {
    @Environment(WatchViewModel.self) private var viewModel

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
        .onAppear {
            viewModel.refresh()
        }
    }
}
