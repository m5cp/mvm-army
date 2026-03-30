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
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    HStack(spacing: 0) {
                        NavigationStack {
                            HomeView()
                        }
                        .frame(width: geo.size.width)

                        NavigationStack {
                            ProgressViewScreen()
                        }
                        .frame(width: geo.size.width)

                        NavigationStack {
                            ProfileView()
                        }
                        .frame(width: geo.size.width)
                    }
                    .offset(x: -CGFloat(selectedTab.rawValue) * geo.size.width + dragOffset)
                    .animation(.spring(response: 0.35, dampingFraction: 0.86), value: selectedTab)

                    HStack(spacing: 0) {
                        edgeSwipeArea(geo: geo, edge: .leading)
                        Spacer()
                        edgeSwipeArea(geo: geo, edge: .trailing)
                    }
                }
            }

            customTabBar
        }
        .background(MVMTheme.background.ignoresSafeArea())
    }

    private enum SwipeEdge {
        case leading, trailing
    }

    private func edgeSwipeArea(geo: GeometryProxy, edge: SwipeEdge) -> some View {
        Color.clear
            .frame(width: 28)
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 15)
                    .onChanged { value in
                        let horizontal = abs(value.translation.width)
                        let vertical = abs(value.translation.height)
                        if horizontal > vertical * 1.2 {
                            isDragging = true
                            dragOffset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        let threshold: CGFloat = geo.size.width * 0.15
                        let velocity = value.predictedEndTranslation.width
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                            if (value.translation.width < -threshold || velocity < -200),
                               let next = AppTab(rawValue: selectedTab.rawValue + 1) {
                                selectedTab = next
                            } else if (value.translation.width > threshold || velocity > 200),
                                      let prev = AppTab(rawValue: selectedTab.rawValue - 1) {
                                selectedTab = prev
                            }
                            dragOffset = 0
                            isDragging = false
                        }
                    }
            )
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
