import SwiftUI

nonisolated enum AppTab: Int, CaseIterable, Sendable {
    case home = 0
    case score = 1
    case train = 2
    case trend = 3
    case you = 4

    var title: String {
        switch self {
        case .home: return "Home"
        case .score: return "Score"
        case .train: return "Train"
        case .trend: return "Trend"
        case .you: return "You"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .score: return "list.clipboard.fill"
        case .train: return "figure.strengthtraining.functional"
        case .trend: return "chart.bar.fill"
        case .you: return "person.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var selectedTab: AppTab = .home
    @State private var homePath = NavigationPath()
    @State private var scorePath = NavigationPath()
    @State private var trainPath = NavigationPath()
    @State private var trendPath = NavigationPath()
    @State private var youPath = NavigationPath()

    var body: some View {
        ZStack {
            NavigationStack(path: $homePath) {
                HomeView()
            }
            .opacity(selectedTab == .home ? 1 : 0)
            .zIndex(selectedTab == .home ? 1 : 0)

            NavigationStack(path: $scorePath) {
                AFTCalculatorView()
            }
            .opacity(selectedTab == .score ? 1 : 0)
            .zIndex(selectedTab == .score ? 1 : 0)

            NavigationStack(path: $trainPath) {
                PlanView()
            }
            .opacity(selectedTab == .train ? 1 : 0)
            .zIndex(selectedTab == .train ? 1 : 0)

            NavigationStack(path: $trendPath) {
                ProgressViewScreen()
            }
            .opacity(selectedTab == .trend ? 1 : 0)
            .zIndex(selectedTab == .trend ? 1 : 0)

            NavigationStack(path: $youPath) {
                ProfileView()
            }
            .opacity(selectedTab == .you ? 1 : 0)
            .zIndex(selectedTab == .you ? 1 : 0)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
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
                        case .score: scorePath = NavigationPath()
                        case .train: trainPath = NavigationPath()
                        case .trend: trendPath = NavigationPath()
                        case .you: youPath = NavigationPath()
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
                    .foregroundStyle(selectedTab == tab ? MVMTheme.amber : MVMTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selectedTab == tab ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .sensoryFeedback(.impact(weight: .light), trigger: selectedTab)
        .background {
            if #available(iOS 26.0, *) {
                Capsule()
                    .fill(.clear)
                    .glassEffect(.regular, in: Capsule())
            } else {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule().stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                    }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}
