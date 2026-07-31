import SwiftUI

/// Shared visibility state for the floating tab bar. Root scroll views report
/// scroll direction via `hidesTabBarOnScroll()`; the bar slides away when the
/// user scrolls down (reading/working) and returns the moment they scroll up,
/// so the bar never covers content at the bottom of a screen.
@Observable
@MainActor
final class TabBarState {
    var isHidden: Bool = false

    func setHidden(_ hidden: Bool) {
        guard isHidden != hidden else { return }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            isHidden = hidden
        }
    }
}

/// Attach to a tab-root ScrollView: hides the tab bar while scrolling down,
/// shows it again on any upward scroll or when near the top.
struct HidesTabBarOnScroll: ViewModifier {
    @Environment(TabBarState.self) private var tabBarState: TabBarState?

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y + geo.contentInsets.top
            } action: { oldY, newY in
                guard let tabBarState else { return }
                if newY <= 24 {
                    tabBarState.setHidden(false)
                } else if newY > oldY + 3 {
                    tabBarState.setHidden(true)
                } else if newY < oldY - 3 {
                    tabBarState.setHidden(false)
                }
            }
    }
}

extension View {
    func hidesTabBarOnScroll() -> some View {
        modifier(HidesTabBarOnScroll())
    }
}

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

    var accessibilityHint: String {
        switch self {
        case .home: return "Today's overview and quick actions"
        case .score: return "Log and calculate your AFT score"
        case .train: return "Workout plans and quick start"
        case .trend: return "Progress charts and history"
        case .you: return "Profile and settings"
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
    /// True on-screen size of the floating tab bar (including its own
    /// padding and its gap from the bottom edge), measured live so every
    /// tab reserves exactly enough space — never a guessed constant.
    @State private var tabBarReservedHeight: CGFloat = 96
    @State private var tabBarState = TabBarState()

    /// Extra clearance above the measured bar height so the last row of
    /// content always sits fully above the floating capsule (its shadow and
    /// glass blur extend past the measured frame).
    private let tabBarClearance: CGFloat = 12

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
            Color.clear.frame(height: tabBarReservedHeight + tabBarClearance)
        }
        .overlay(alignment: .bottom) {
            customTabBar
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { newHeight in
                    tabBarReservedHeight = newHeight
                }
                .offset(y: tabBarState.isHidden ? tabBarReservedHeight + 60 : 0)
                .opacity(tabBarState.isHidden ? 0 : 1)
                .allowsHitTesting(!tabBarState.isHidden)
                .accessibilityHidden(tabBarState.isHidden)
        }
        .environment(tabBarState)
        .background(MVMTheme.background.ignoresSafeArea())
        .instantRecapOverlay(recap: Binding(
            get: { vm.activeRecap },
            set: { vm.activeRecap = $0 }
        ))
        .milestoneOverlay()
        .onChange(of: vm.requestedTab) { _, newTab in
            guard let newTab else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = newTab
            }
            vm.requestedTab = nil
        }
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
                .accessibilityHint(tab.accessibilityHint)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
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
