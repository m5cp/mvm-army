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
    @State private var selectedTab: AppTab = .home

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView()
                }
                .tag(AppTab.home)

                NavigationStack {
                    ProgressViewScreen()
                }
                .tag(AppTab.progress)

                NavigationStack {
                    ProfileView()
                }
                .tag(AppTab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.35, dampingFraction: 0.86), value: selectedTab)

            customTabBar
        }
        .background(MVMTheme.background.ignoresSafeArea())
    }



    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTab = tab
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
