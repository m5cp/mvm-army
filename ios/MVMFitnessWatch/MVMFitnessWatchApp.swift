import SwiftUI

@main
struct MVMFitnessWatchApp: App {
    @State private var viewModel = WatchViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                .task {
                    await viewModel.requestHealthAccess()
                    viewModel.refresh()
                }
        }
    }
}
