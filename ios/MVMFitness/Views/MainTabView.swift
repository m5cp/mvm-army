import SwiftUI

nonisolated enum AppTab: Int, CaseIterable, Sendable {
    case home = 0
    case progress = 1
    case profile = 2

    var title: String {
        switch self {
        case .home: return "Home"
        case .progress: return "Progress"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var selectedTab: AppTab = .home
    @State private var homePath = NavigationPath()
    @State private var progressPath = NavigationPath()
    @State private var profilePath = NavigationPath()

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                NavigationStack(path: $homePath) {
                    HomeView()
                }
                .opacity(selectedTab == .home ? 1 : 0)
                .zIndex(selectedTab == .home ? 1 : 0)

                NavigationStack(path: $progressPath) {
                    ProgressViewScreen()
                }
                .opacity(selectedTab == .progress ? 1 : 0)
                .zIndex(selectedTab == .progress ? 1 : 0)

                NavigationStack(path: $profilePath) {
                    ProfileView()
                }
                .opacity(selectedTab == .profile ? 1 : 0)
                .zIndex(selectedTab == .profile ? 1 : 0)
            }

            customTabBar
        }
        .background(MVMTheme.background.ignoresSafeArea())
        .instantRecapOverlay(recap: Binding(
            get: { vm.activeRecap },
            set: { vm.activeRecap = $0 }
        ))
        .milestoneOverlay()
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Button {
                    if selectedTab == tab {
                        switch tab {
                        case .home: homePath = NavigationPath()
                        case .progress: progressPath = NavigationPath()
                        case .profile: profilePath = NavigationPath()
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTab = tab
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: selectedTab == tab ? .bold : .regular))
                            .symbolEffect(.bounce, value: selectedTab == tab)
                        Text(tab.title)
                            .font(.caption2.weight(selectedTab == tab ? .bold : .medium))
                    }
                    .foregroundStyle(selectedTab == tab ? MVMTheme.accent : MVMTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 20)
        .background {
            MVMTheme.background
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(MVMTheme.border)
                        .frame(height: 0.5)
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }
}
