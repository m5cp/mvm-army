import SwiftUI
import UIKit

/// 15a — milestone coin grid, hung off the You tab below Profile.
/// PNG coins are static reward art (never navigation/chrome); badges without
/// dedicated art render as SF-Symbol coins in the same style.
///
/// Earn rules read ONLY already-logged app data (no new storage, no new scoring
/// math): saved AFT/service-test results, completed workout records, Quick
/// Start GPS sessions, the active weekly plan, and the existing streak/session
/// counters on AppViewModel. Tapping an EARNED badge opens a share card —
/// locked badges are inert.
struct BadgesView: View {
    @Environment(AppViewModel.self) private var vm
    @AppStorage("planWeeks") private var planWeeks = 4
    @AppStorage("hasSharedOnce") private var hasSharedOnce = false
    /// Comma-separated keys of badges the user has already seen earned,
    /// so the scale-up celebration only plays once, the first time a badge flips.
    @AppStorage("seenEarnedBadgeAssets") private var seenEarnedBadgesRaw = ""
    @State private var newlyEarnedKeys: Set<String> = []
    @State private var shareCoin: Coin?

    struct Coin: Identifiable {
        let key: String
        let art: BadgeArt
        let name: String
        let status: String
        let earned: Bool
        var id: String { key }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Badges")
                    .font(.system(size: 20, weight: .bold))
                    .tracking(-0.4)
                    .foregroundStyle(MVMTheme.text)
                Spacer()
                Text("\(earnedCount) OF \(coins.count) EARNED")
                    .font(MVMTheme.mono(10.5))
                    .kerning(1.4)
                    .foregroundStyle(MVMTheme.textFaint)
                    .lineLimit(1)
                    .fixedSize()
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 11), count: 3), spacing: 11) {
                ForEach(coins) { coin in
                    Button {
                        if coin.earned { shareCoin = coin }
                    } label: {
                        BadgeCoin(art: coin.art, name: coin.name, status: coin.status, earned: coin.earned,
                                  isNewlyEarned: newlyEarnedKeys.contains(coin.key))
                            .contentShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    .disabled(!coin.earned)
                    .accessibilityHint(coin.earned ? "Share this badge" : "")
                }
            }
        }
        .onAppear { markNewlyEarned() }
        .onChange(of: earnedCount) { _, _ in markNewlyEarned() }
        .sensoryFeedback(.success, trigger: newlyEarnedKeys)
        .sheet(item: $shareCoin) { coin in
            BadgeShareSheet(coin: coin)
        }
    }

    /// Diffs the current earned set against what's already been seen, flags any
    /// freshly-flipped badges for the one-time scale-up, then persists the union
    /// so the celebration never replays for the same badge.
    private func markNewlyEarned() {
        let seen = Set(seenEarnedBadgesRaw.split(separator: ",").map(String.init))
        let currentlyEarned = Set(coins.filter(\.earned).map(\.key))
        let fresh = currentlyEarned.subtracting(seen)
        if !fresh.isEmpty {
            newlyEarnedKeys = fresh
            seenEarnedBadgesRaw = seen.union(currentlyEarned).sorted().joined(separator: ",")
        }
    }

    private var earnedCount: Int {
        coins.filter(\.earned).count
    }

    // MARK: - Coin definitions (earn rules read existing logged data only)

    private var coins: [Coin] {
        [
            // ── Original coin-art badges ──────────────────────────────────
            Coin(key: "icon3d-timer", art: .png("icon3d-timer"), name: "First test logged",
                 status: hasAnyScore ? firstScoreDateLabel : "LOCKED", earned: hasAnyScore),
            Coin(key: "icon3d-laurel", art: .png("icon3d-laurel"), name: "Plan finisher",
                 status: planFinished ? "ACTIVE" : "LOCKED", earned: planFinished),
            Coin(key: "icon3d-dumbbell", art: .png("icon3d-dumbbell"), name: "20 sessions",
                 status: twentySessions ? "\(vm.totalWorkoutsCompleted) LOGGED" : "LOCKED", earned: twentySessions),
            Coin(key: "icon3d-shaker", art: .png("icon3d-shaker"), name: "7-day streak",
                 status: weekStreak ? "ACTIVE" : "LOCKED", earned: weekStreak),
            Coin(key: "icon3d-plate", art: .png("icon3d-plate"), name: "Perfect week",
                 status: perfectWeek ? "ACTIVE" : "LOCKED", earned: perfectWeek),
            Coin(key: "icon3d-trophy", art: .png("icon3d-trophy"), name: "New record",
                 status: newRecord ? "+\(scoreDelta ?? 0) PTS" : "LOCKED", earned: newRecord),
            Coin(key: "icon3d-ruck", art: .png("icon3d-ruck"), name: "Ruck ready",
                 status: ruckLogged ? "LOGGED" : "LOCKED", earned: ruckLogged),
            Coin(key: "icon3d-barbell", art: .png("icon3d-barbell"), name: "+25 total score",
                 status: bigImprovement ? "+\(scoreDelta ?? 0)" : "LOCKED", earned: bigImprovement),
            Coin(key: "icon3d-pack", art: .png("icon3d-pack"), name: "12-week plan",
                 status: twelveWeekPlan ? "ACTIVE" : "LOCKED", earned: twelveWeekPlan),
            Coin(key: "icon3d-kettlebell", art: .png("icon3d-kettlebell"), name: "FunctionFitness",
                 status: functionalLogged ? "LOGGED" : "LOCKED", earned: functionalLogged),
            Coin(key: "icon3d-run", art: .png("icon3d-run"), name: "Quick starter",
                 status: quickStartLogged ? "LOGGED" : "LOCKED", earned: quickStartLogged),

            // ── Starters ──────────────────────────────────────────────────
            Coin(key: "firstShare", art: .symbol("square.and.arrow.up.circle.fill"), name: "Spread the word",
                 status: hasSharedOnce ? "SHARED" : "LOCKED", earned: hasSharedOnce),
            Coin(key: "earlyBird", art: .symbol("sunrise.fill"), name: "Early bird",
                 status: earlyBird ? "0500 CLUB" : "LOCKED", earned: earlyBird),
            Coin(key: "firstMile", art: .symbol("figure.run.circle.fill"), name: "First mile",
                 status: totalGPSMiles >= 1 ? "TRACKED" : "LOCKED", earned: totalGPSMiles >= 1),

            // ── Distance (long-haul) ──────────────────────────────────────
            Coin(key: "miles25", art: .symbol("road.lanes"), name: "25-mile club",
                 status: mileStatus(25), earned: totalGPSMiles >= 25),
            Coin(key: "miles100", art: .symbol("flag.checkered"), name: "100-mile club",
                 status: mileStatus(100), earned: totalGPSMiles >= 100),
            Coin(key: "miles500", art: .symbol("crown.fill"), name: "500-mile club",
                 status: mileStatus(500), earned: totalGPSMiles >= 500),
            Coin(key: "month30", art: .symbol("calendar.circle.fill"), name: "30-mile month",
                 status: bestMonthMiles >= 30 ? "\(Int(bestMonthMiles)) MI BEST" : "LOCKED", earned: bestMonthMiles >= 30),

            // ── Consistency ───────────────────────────────────────────────
            Coin(key: "streak14", art: .symbol("flame.fill"), name: "14-day streak",
                 status: vm.streak >= 14 ? "ACTIVE" : "LOCKED", earned: vm.streak >= 14),
            Coin(key: "streak30", art: .symbol("flame.circle.fill"), name: "30-day streak",
                 status: vm.streak >= 30 ? "ACTIVE" : "LOCKED", earned: vm.streak >= 30),

            // ── Holiday awards (limited-edition style: train on the day) ──
            Coin(key: "veteransDay", art: .symbol("star.circle.fill"), name: "Veterans Day",
                 status: veteransDay ? "NOV 11" : "TRAIN NOV 11", earned: veteransDay),
            Coin(key: "memorialDay", art: .symbol("medal.fill"), name: "Memorial Day",
                 status: memorialDay ? "HONORED" : "TRAIN MEM DAY", earned: memorialDay),
            Coin(key: "independenceDay", art: .symbol("sparkles"), name: "Independence Day",
                 status: independenceDay ? "JUL 4" : "TRAIN JUL 4", earned: independenceDay),
            Coin(key: "armyBirthday", art: .symbol("birthday.cake.fill"), name: "Army Birthday",
                 status: armyBirthday ? "JUN 14" : "TRAIN JUN 14", earned: armyBirthday),

            // ── Cross-service ─────────────────────────────────────────────
            Coin(key: "jointForce", art: .symbol("globe.americas.fill"), name: "Joint force",
                 status: jointForce ? "ALL SERVICES" : "LOCKED", earned: jointForce)
        ]
    }

    // MARK: - Rules

    private var hasAnyScore: Bool { !vm.aftScores.isEmpty }

    private var firstScoreDateLabel: String {
        guard let first = vm.aftScores.last else { return "LOCKED" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: first.date).uppercased()
    }

    private var planFinished: Bool {
        guard let plan = vm.currentPlan, plan.totalWorkoutDays > 0 else { return false }
        return plan.completedCount >= plan.totalWorkoutDays
    }

    private var twentySessions: Bool { vm.totalWorkoutsCompleted >= 20 }

    private var weekStreak: Bool { vm.streak >= 7 }

    private var perfectWeek: Bool {
        vm.weeklyTotalDays > 0 && vm.workoutsThisWeek >= vm.weeklyTotalDays
    }

    private var scoreDelta: Int? { vm.aftScoreDifference }

    private var newRecord: Bool { (scoreDelta ?? -1) > 0 }

    private var bigImprovement: Bool { (scoreDelta ?? 0) >= 25 }

    /// Event-tag coverage stand-in: any completed session logged a ruck/loaded-carry
    /// cardio activity (structured data already on WorkoutExercise).
    private var ruckLogged: Bool {
        vm.completedRecords.contains { record in
            record.exercises.contains { $0.cardioType == .ruck }
        }
    }

    private var twelveWeekPlan: Bool {
        vm.currentPlan != nil && planWeeks >= 12
    }

    private var functionalLogged: Bool {
        vm.completedRecords.contains { $0.source == .wod }
    }

    private var quickStartLogged: Bool {
        !vm.quickStartRecords.isEmpty
    }

    // MARK: - GPS distance rules

    private var totalGPSMiles: Double {
        vm.quickStartRecords.reduce(0) { $0 + $1.distanceMiles }
    }

    private func mileStatus(_ target: Int) -> String {
        totalGPSMiles >= Double(target) ? "\(Int(totalGPSMiles)) MI" : "\(Int(totalGPSMiles))/\(target) MI"
    }

    /// Best single calendar month of GPS mileage.
    private var bestMonthMiles: Double {
        let cal = Calendar.current
        var buckets: [String: Double] = [:]
        for record in vm.quickStartRecords {
            let comps = cal.dateComponents([.year, .month], from: record.startDate)
            let key = "\(comps.year ?? 0)-\(comps.month ?? 0)"
            buckets[key, default: 0] += record.distanceMiles
        }
        return buckets.values.max() ?? 0
    }

    // MARK: - Time-of-day + holiday rules

    /// Every dated activity the app has logged.
    private var allActivityDates: [Date] {
        vm.completedRecords.map(\.date)
            + vm.quickStartRecords.map(\.startDate)
            + vm.aftScores.map(\.date)
            + vm.serviceTestRecords.map(\.date)
    }

    private var earlyBird: Bool {
        allActivityDates.contains { Calendar.current.component(.hour, from: $0) < 6 }
    }

    private func activity(onMonth month: Int, day: Int) -> Bool {
        let cal = Calendar.current
        return allActivityDates.contains {
            let c = cal.dateComponents([.month, .day], from: $0)
            return c.month == month && c.day == day
        }
    }

    private var veteransDay: Bool { activity(onMonth: 11, day: 11) }
    private var independenceDay: Bool { activity(onMonth: 7, day: 4) }
    private var armyBirthday: Bool { activity(onMonth: 6, day: 14) }

    /// Memorial Day = last Monday of May (varies by year).
    private var memorialDay: Bool {
        let cal = Calendar.current
        return allActivityDates.contains { date in
            let c = cal.dateComponents([.month, .day, .weekday], from: date)
            // A Monday in the last 7 days of May is always the last Monday.
            return c.month == 5 && c.weekday == 2 && (c.day ?? 0) >= 25
        }
    }

    private var jointForce: Bool {
        let branches = Set(vm.serviceTestRecords.map(\.branch))
        return branches.contains(.navy)
            && branches.contains(.airForce)
            && (branches.contains(.marinePFT) || branches.contains(.marineCFT))
    }
}

// MARK: - Badge share sheet

/// Renders an earned badge as a shareable card in the golden-hour format.
private struct BadgeShareSheet: View {
    let coin: BadgesView.Coin
    @Environment(\.dismiss) private var dismiss
    @State private var renderedImage: UIImage?

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    if let image = renderedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                            .padding(.horizontal, 40)
                    } else {
                        ProgressView().tint(.white)
                    }

                    Button {
                        if let image = renderedImage {
                            let caption = "Badge earned: \(coin.name)\nMVM Fitness — Me vs Me.\n\(AppLinks.appStoreURLString)"
                            let activityVC = UIActivityViewController(activityItems: [image, caption], applicationActivities: nil)
                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                  let rootVC = windowScene.windows.first?.rootViewController else { return }
                            var presenter = rootVC
                            while let presented = presenter.presentedViewController {
                                presenter = presented
                            }
                            if let popover = activityVC.popoverPresentationController {
                                popover.sourceView = presenter.view
                                popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
                                popover.permittedArrowDirections = []
                            }
                            presenter.present(activityVC, animated: true)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Badge")
                        }
                        .font(.headline)
                        .foregroundStyle(MVMTheme.onAmber)
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .background(MVMTheme.amberButtonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .contentShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    .disabled(renderedImage == nil)
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Badge Earned")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .task {
                renderedImage = BadgeCardRenderer.render(coin: coin)
            }
        }
        .presentationDetents([.large])
    }
}

@MainActor
private enum BadgeCardRenderer {
    static func render(coin: BadgesView.Coin) -> UIImage? {
        let width: CGFloat = 1080
        let height: CGFloat = 1080

        let amber = UIColor(red: 0.910, green: 0.639, blue: 0.239, alpha: 1.0)
        let amberLight = UIColor(red: 0.949, green: 0.702, blue: 0.345, alpha: 1.0)
        let cream = UIColor(red: 0.949, green: 0.929, blue: 0.894, alpha: 1.0)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)

        return renderer.image { ctx in
            let context = ctx.cgContext

            // Dark base + amber radial glow behind the coin.
            context.setFillColor(UIColor(red: 0.043, green: 0.035, blue: 0.031, alpha: 1.0).cgColor)
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))

            let glow = [
                amber.withAlphaComponent(0.30).cgColor,
                amber.withAlphaComponent(0.05).cgColor,
                UIColor.clear.cgColor
            ] as CFArray
            if let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: glow, locations: [0, 0.6, 1]) {
                context.drawRadialGradient(g,
                                           startCenter: CGPoint(x: width / 2, y: 430),
                                           startRadius: 0,
                                           endCenter: CGPoint(x: width / 2, y: 430),
                                           endRadius: 480, options: [])
            }

            // Header
            let headerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 26, weight: .heavy),
                .foregroundColor: cream, .kern: 4.0
            ]
            let header = NSAttributedString(string: "MVM FITNESS", attributes: headerAttrs)
            let headerSize = header.size()
            header.draw(at: CGPoint(x: (width - headerSize.width) / 2, y: 70))

            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 18, weight: .bold),
                .foregroundColor: amber, .kern: 3.0
            ]
            let sub = NSAttributedString(string: "BADGE EARNED", attributes: subAttrs)
            let subSize = sub.size()
            sub.draw(at: CGPoint(x: (width - subSize.width) / 2, y: 112))

            // Coin art — PNG asset or SF Symbol, drawn inside an amber ring.
            let coinRect = CGRect(x: width / 2 - 180, y: 250, width: 360, height: 360)
            context.setStrokeColor(amber.cgColor)
            context.setLineWidth(6)
            context.strokeEllipse(in: coinRect.insetBy(dx: -14, dy: -14))

            switch coin.art {
            case .png(let asset):
                if let image = UIImage(named: asset) {
                    context.saveGState()
                    context.addEllipse(in: coinRect)
                    context.clip()
                    image.draw(in: coinRect.insetBy(dx: -50, dy: -50))
                    context.restoreGState()
                }
            case .symbol(let symbolName):
                context.setFillColor(UIColor(red: 0.047, green: 0.035, blue: 0.031, alpha: 1.0).cgColor)
                context.fillEllipse(in: coinRect)
                let config = UIImage.SymbolConfiguration(pointSize: 170, weight: .semibold)
                if let symbol = UIImage(systemName: symbolName, withConfiguration: config)?
                    .withTintColor(amberLight, renderingMode: .alwaysOriginal) {
                    let symbolSize = symbol.size
                    symbol.draw(at: CGPoint(x: coinRect.midX - symbolSize.width / 2, y: coinRect.midY - symbolSize.height / 2))
                }
            }

            // Badge name + status
            let nameAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 54, weight: .bold),
                .foregroundColor: cream
            ]
            let name = NSAttributedString(string: coin.name, attributes: nameAttrs)
            let nameSize = name.size()
            name.draw(at: CGPoint(x: (width - nameSize.width) / 2, y: 700))

            let statusAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 22, weight: .bold),
                .foregroundColor: amber, .kern: 2.0
            ]
            let status = NSAttributedString(string: coin.status, attributes: statusAttrs)
            let statusSize = status.size()
            status.draw(at: CGPoint(x: (width - statusSize.width) / 2, y: 775))

            // Footer
            let footY = height - 120
            let mottoAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .heavy),
                .foregroundColor: cream.withAlphaComponent(0.9)
            ]
            NSAttributedString(string: "Me vs Me.", attributes: mottoAttrs)
                .draw(at: CGPoint(x: 60, y: footY))

            ShareCardCGHelpers.drawAppQRFooter(context: context, width: width, footerTopY: footY - 16)
        }
    }
}
