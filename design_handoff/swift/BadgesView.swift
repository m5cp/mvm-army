import SwiftUI

/// 15a — 3×3 milestone coin grid on the You tab, below Profile.
/// Coins are static PNGs (icon3d-*) — reward art, never UI chrome.
/// Earn rules read the same event tags the trainer uses; streaks count
/// logged sessions, improvement coins compare against the last recorded test.
struct BadgesView: View {
    struct Badge: Identifiable {
        let id = UUID()
        let asset, name, status: String
        let earned: Bool
    }
    let badges: [Badge] = [
        .init(asset: "icon3d-timer",      name: "First test logged", status: "JUL 12",  earned: true),
        .init(asset: "icon3d-kettlebell", name: "Plan finisher",     status: "JUL 24",  earned: true),
        .init(asset: "icon3d-dumbbell",   name: "20 sessions",       status: "JUL 26",  earned: true),
        .init(asset: "icon3d-shaker",     name: "7-day streak",      status: "ACTIVE",  earned: true),
        .init(asset: "icon3d-laurel",     name: "Perfect week",      status: "LOCKED",  earned: false),
        .init(asset: "icon3d-trophy",     name: "New record",        status: "LOCKED",  earned: false),
        .init(asset: "icon3d-pack",       name: "Ruck ready",        status: "LOCKED",  earned: false),
        .init(asset: "icon3d-barbell",    name: "+25 total score",   status: "LOCKED",  earned: false),
        .init(asset: "icon3d-ruck",       name: "12-week plan",      status: "LOCKED",  earned: false),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Badges").font(.system(size: 20, weight: .bold)).tracking(-0.4)
                    .foregroundStyle(MVMTheme.text)
                Spacer()
                Text("\(badges.filter(\.earned).count) OF \(badges.count) EARNED")
                    .font(MVMTheme.mono(10.5)).kerning(1.4)
                    .foregroundStyle(MVMTheme.textFaint)
                    .lineLimit(1).fixedSize()
            }
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 11), count: 3), spacing: 11) {
                ForEach(badges) { b in
                    BadgeCoin(asset: b.asset, name: b.name, status: b.status, earned: b.earned)
                }
            }
        }
        .padding(22)
        .background(MVMTheme.screen)
    }
}
