import SwiftUI

/// Five tabs — Apple's limit, no overflow. Amber selected tint.
/// SF Symbols only; weights match adjacent text.
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            ScoreSheetView()
                .tabItem { Label("Score", systemImage: "list.clipboard.fill") }
            TrainView()
                .tabItem { Label("Train", systemImage: "figure.strengthtraining.functional") }
            TrendView()
                .tabItem { Label("Trend", systemImage: "chart.bar.fill") }
            ProfileView()
                .tabItem { Label("You", systemImage: "person.fill") }
        }
        .tint(MVMTheme.amber)
        .preferredColorScheme(.dark)
    }
}

/// Trend is unchanged by this redesign apart from theme tokens.
struct TrendView: View {
    var body: some View { MVMTheme.screen.ignoresSafeArea() }
}
