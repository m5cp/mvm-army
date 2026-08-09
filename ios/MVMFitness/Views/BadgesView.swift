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
    @AppStorage("seenEarnedBadgeKeysMigratedV2") private var seenKeysMigratedV2 = false
    @State private var newlyEarnedKeys: Set<String> = []
    @State private var shareCoin: Coin?

    enum BadgeGroup: String, CaseIterable {
        case start, consistency, streaks, milestones, honors

        var title: String {
            switch self {
            case .start:       return "Getting started"
            case .consistency: return "Consistency"
            case .streaks:     return "Streaks"
            case .milestones:  return "Milestones"
            case .honors:      return "Honors"
            }
        }
    }

    struct Coin: Identifiable {
        let key: String
        let art: BadgeArt
        let name: String
        let group: BadgeGroup
        let how: String
        let citation: String
        let status: String
        let earned: Bool
        var id: String { key }
    }

    var body: some View {
        // Built once per pass. `coins` runs all 32 earn rules — several of which
        // bucket every GPS record — so evaluating it per section would redo that
        // work seven times on every render.
        let allCoins = coins
        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Badges")
                    .font(.system(size: 20, weight: .bold))
                    .tracking(-0.4)
                    .foregroundStyle(MVMTheme.text)
                Spacer()
                Text("\(allCoins.filter(\.earned).count) OF \(allCoins.count) EARNED")
                    .font(MVMTheme.mono(10.5))
                    .kerning(1.4)
                    .foregroundStyle(MVMTheme.textFaint)
                    .lineLimit(1)
                    .fixedSize()
            }

            ForEach(BadgeGroup.allCases, id: \.self) { group in
                let groupCoins = allCoins.filter { $0.group == group }
                if !groupCoins.isEmpty {
                    sectionHeader(group, coins: groupCoins)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 11), count: 3), spacing: 11) {
                        ForEach(groupCoins) { coin in
                            Button {
                                if coin.earned { shareCoin = coin }
                            } label: {
                                BadgeCoin(art: coin.art, name: coin.name, how: coin.how,
                                          status: coin.status, earned: coin.earned,
                                          isNewlyEarned: newlyEarnedKeys.contains(coin.key))
                                    .contentShape(RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(PressScaleButtonStyle())
                            .disabled(!coin.earned)
                            .accessibilityHint(coin.earned ? "Share this badge" : "")
                        }
                    }
                }
            }
        }
        .onAppear { migrateSeenKeysIfNeeded(); markNewlyEarned(allCoins) }
        .onChange(of: allCoins.filter(\.earned).count) { _, _ in markNewlyEarned(allCoins) }
        .sensoryFeedback(.success, trigger: newlyEarnedKeys)
        .sheet(item: $shareCoin) { coin in
            BadgeShareSheet(coin: coin)
        }
    }

    @ViewBuilder
    private func sectionHeader(_ group: BadgeGroup, coins groupCoins: [Coin]) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(group.title.uppercased())
                .font(MVMTheme.mono(11, weight: .bold))
                .kerning(1.8)
                .foregroundStyle(MVMTheme.textMuted)
                .lineLimit(1)
                .fixedSize()
            Rectangle()
                .fill(MVMTheme.textFaint.opacity(0.25))
                .frame(height: 1)
            Text("\(groupCoins.filter(\.earned).count)/\(groupCoins.count)")
                .font(MVMTheme.mono(10.5))
                .foregroundStyle(MVMTheme.textFaint)
                .lineLimit(1)
                .fixedSize()
        }
        .padding(.top, 6)
    }

    /// Maps the pre-v2 badge keys onto the catalog ids. Without this the
    /// rename makes every already-earned badge look freshly earned, and the
    /// celebration replays for all of them at once.
    private static let legacyKeyMap: [String: String] = [
        "icon3d-timer": "first-test",
        "icon3d-run": "quick-starter",
        "icon3d-kettlebell": "functional",
        "icon3d-ruck": "ruck-ready",
        "icon3d-dumbbell": "sessions-20",
        "icon3d-plate": "perfect-week",
        "icon3d-laurel": "plan-finisher",
        "icon3d-trophy": "new-record",
        "icon3d-shaker": "streak-7",
        "icon3d-barbell": "score-25",
        "icon3d-pack": "plan-12",
        "firstShare": "first-share",
        "firstMile": "first-mile",
        "miles25": "miles-25",
        "miles100": "miles-100",
        "miles500": "miles-500",
        "month30": "month-30",
        "streak14": "streak-14",
        "streak30": "streak-30",
        "veteransDay": "veterans-day",
        "memorialDay": "memorial-day",
        "independenceDay": "independence-day",
        "armyBirthday": "army-birthday",
        "jointForce": "joint-force"
    ]

    private func migrateSeenKeysIfNeeded() {
        guard !seenKeysMigratedV2 else { return }
        let old = seenEarnedBadgesRaw.split(separator: ",").map(String.init)
        let migrated = Set(old.map { Self.legacyKeyMap[$0] ?? $0 })
        seenEarnedBadgesRaw = migrated.sorted().joined(separator: ",")
        seenKeysMigratedV2 = true
    }

    /// Diffs the current earned set against what's already been seen, flags any
    /// freshly-flipped badges for the one-time scale-up, then persists the union
    /// so the celebration never replays for the same badge.
    private func markNewlyEarned(_ allCoins: [Coin]) {
        let seen = Set(seenEarnedBadgesRaw.split(separator: ",").map(String.init))
        let currentlyEarned = Set(allCoins.filter(\.earned).map(\.key))
        let fresh = currentlyEarned.subtracting(seen)
        if !fresh.isEmpty {
            newlyEarnedKeys = fresh
            seenEarnedBadgesRaw = seen.union(currentlyEarned).sorted().joined(separator: ",")
        }
    }

    // MARK: - Coin definitions (earn rules read existing logged data only)

    private var coins: [Coin] {
        startCoins + consistencyCoins + streakCoins + milestoneCoins + honorCoins
    }

    private var startCoins: [Coin] {
        [
            Coin(key: "first-test", art: .png("badge-first-test"), name: "First Test Logged",
                 group: .start, how: "Log your first AFT",
                 citation: "Logged a baseline AFT. Everything after compares back to today.",
                 status: hasAnyScore ? firstScoreDateLabel : "LOCKED", earned: hasAnyScore),
            Coin(key: "quick-starter", art: .png("badge-quick-starter"), name: "Quick Starter",
                 group: .start, how: "Finish a Quick Start session",
                 citation: "Completed a first Quick Start session. Action beats intention.",
                 status: quickStartLogged ? "LOGGED" : "LOCKED", earned: quickStartLogged),
            Coin(key: "functional", art: .png("badge-functional"), name: "Functional Fitness",
                 group: .start, how: "Finish a functional workout",
                 citation: "Completed a first functional fitness workout.",
                 status: functionalLogged ? "LOGGED" : "LOCKED", earned: functionalLogged),
            Coin(key: "first-mile", art: .png("badge-first-mile"), name: "First Mile",
                 group: .start, how: "Track 1 mile with GPS",
                 citation: "First GPS-tracked mile in the books.",
                 status: totalGPSMiles >= 1 ? "TRACKED" : "LOCKED", earned: totalGPSMiles >= 1),
            Coin(key: "first-share", art: .png("badge-first-share"), name: "Spread The Word",
                 group: .start, how: "Share a score card",
                 citation: "Sent a score card to the squad. Standards are contagious.",
                 status: hasSharedOnce ? "SHARED" : "LOCKED", earned: hasSharedOnce),
            Coin(key: "ruck-ready", art: .png("badge-ruck-ready"), name: "Ruck Ready",
                 group: .start, how: "Log your first ruck",
                 citation: "Logged a first ruck. Weight on your back, miles underfoot.",
                 status: ruckLogged ? "LOGGED" : "LOCKED", earned: ruckLogged),

        ]
    }

    private var consistencyCoins: [Coin] {
        [
            Coin(key: "sessions-20", art: .png("badge-sessions-20"), name: "20 Sessions",
                 group: .consistency, how: "Log 20 sessions",
                 citation: "Twenty logged sessions. This is now a habit.",
                 status: twentySessions ? "\(vm.totalWorkoutsCompleted) LOGGED" : "LOCKED", earned: twentySessions),
            Coin(key: "perfect-week", art: .png("badge-perfect-week"), name: "Perfect Week",
                 group: .consistency, how: "Hit every scheduled session in a week",
                 citation: "Every scheduled session in a week, done.",
                 status: perfectWeek ? "ACTIVE" : "LOCKED", earned: perfectWeek),
            Coin(key: "plan-finisher", art: .png("badge-plan-finisher"), name: "Plan Finisher",
                 group: .consistency, how: "Complete any training plan",
                 citation: "Carried a full training plan to its last session.",
                 status: planFinished ? "ACTIVE" : "LOCKED", earned: planFinished),
            Coin(key: "new-record", art: .png("badge-new-record"), name: "New Record",
                 group: .consistency, how: "Beat a personal best",
                 citation: "Beat a personal best on record.",
                 status: newRecord ? "+\(scoreDelta ?? 0) PTS" : "LOCKED", earned: newRecord),
            Coin(key: "miles-25", art: .png("badge-miles-25"), name: "25-Mile Club",
                 group: .consistency, how: "Track 25 total miles",
                 citation: "Twenty-five tracked miles.",
                 status: mileStatus(25), earned: totalGPSMiles >= 25),
            Coin(key: "month-30", art: .png("badge-month-30"), name: "30-Mile Month",
                 group: .consistency, how: "30 miles inside one month",
                 citation: "Thirty miles inside a single month.",
                 status: bestMonthMiles >= 30 ? "\(Int(bestMonthMiles)) MI BEST" : "LOCKED", earned: bestMonthMiles >= 30),
            Coin(key: "early-bird", art: .png("badge-early-bird"), name: "Early Bird",
                 group: .consistency, how: "10 sessions before 0600",
                 citation: "Ten sessions before 0600. The 0500 club is earned, not joined.",
                 status: earlyBirdCount >= 10 ? "0500 CLUB" : "\(earlyBirdCount)/10", earned: earlyBirdCount >= 10),

        ]
    }

    private var streakCoins: [Coin] {
        [
            Coin(key: "streak-7", art: .png("badge-streak-7"), name: "7-Day Streak",
                 group: .streaks, how: "Train 7 days in a row",
                 citation: "Seven consecutive training days.",
                 status: streakStatus(7), earned: vm.streak >= 7),
            Coin(key: "streak-14", art: .png("badge-streak-14"), name: "14-Day Streak",
                 group: .streaks, how: "Train 14 days in a row",
                 citation: "Two unbroken weeks.",
                 status: streakStatus(14), earned: vm.streak >= 14),
            Coin(key: "streak-30", art: .png("badge-streak-30"), name: "30-Day Streak",
                 group: .streaks, how: "Train 30 days in a row",
                 citation: "Thirty consecutive training days.",
                 status: streakStatus(30), earned: vm.streak >= 30),
            Coin(key: "streak-60", art: .png("badge-streak-60"), name: "60-Day Streak",
                 group: .streaks, how: "Train 60 days in a row",
                 citation: "Sixty consecutive training days.",
                 status: streakStatus(60), earned: vm.streak >= 60),
            Coin(key: "streak-90", art: .png("badge-streak-90"), name: "90-Day Streak",
                 group: .streaks, how: "Train 90 days in a row",
                 citation: "Ninety consecutive training days.",
                 status: streakStatus(90), earned: vm.streak >= 90),
            Coin(key: "streak-180", art: .png("badge-streak-180"), name: "6-Month Streak",
                 group: .streaks, how: "Train 180 days in a row",
                 citation: "Half a year without a missed day.",
                 status: streakStatus(180), earned: vm.streak >= 180),
            Coin(key: "streak-365", art: .png("badge-streak-365"), name: "12-Month Streak",
                 group: .streaks, how: "Train 365 days in a row",
                 citation: "A full year. Every single day.",
                 status: streakStatus(365), earned: vm.streak >= 365),

        ]
    }

    private var milestoneCoins: [Coin] {
        [
            Coin(key: "score-25", art: .png("badge-score-25"), name: "+25 Total Score",
                 group: .milestones, how: "Improve your AFT total by 25",
                 citation: "Twenty-five points better than where you started.",
                 status: bigImprovement ? "+\(scoreDelta ?? 0)" : "LOCKED", earned: bigImprovement),
            Coin(key: "plan-12", art: .png("badge-plan-12"), name: "12-Week Plan",
                 group: .milestones, how: "Complete a 12-week plan",
                 citation: "Twelve weeks, start to finish.",
                 status: twelveWeekPlan ? "ACTIVE" : "LOCKED", earned: twelveWeekPlan),
            Coin(key: "miles-100", art: .png("badge-miles-100"), name: "100-Mile Club",
                 group: .milestones, how: "Track 100 total miles",
                 citation: "One hundred tracked miles.",
                 status: mileStatus(100), earned: totalGPSMiles >= 100),
            Coin(key: "miles-500", art: .png("badge-miles-500"), name: "500-Mile Club",
                 group: .milestones, how: "Track 500 total miles",
                 citation: "Five hundred miles. The long haul.",
                 status: mileStatus(500), earned: totalGPSMiles >= 500),
            Coin(key: "joint-force", art: .png("badge-joint-force"), name: "Joint Force",
                 group: .milestones, how: "Score a Navy, Air Force and Marine test",
                 citation: "Scored across all services.",
                 status: jointForce ? "ALL SERVICES" : "LOCKED", earned: jointForce),

        ]
    }

    private var honorCoins: [Coin] {
        [
            Coin(key: "army-birthday", art: .png("badge-army-birthday"), name: "Army Birthday",
                 group: .honors, how: "Train on 14 June",
                 citation: "Trained on the Army's birthday.",
                 status: armyBirthday ? "JUN 14" : "TRAIN JUN 14", earned: armyBirthday),
            Coin(key: "marines-birthday", art: .png("badge-marines-birthday"), name: "Marine Corps Birthday",
                 group: .honors, how: "Train on 10 November",
                 citation: "Trained on the Marine Corps birthday.",
                 status: marinesBirthday ? "NOV 10" : "TRAIN NOV 10", earned: marinesBirthday),
            Coin(key: "navy-birthday", art: .png("badge-navy-birthday"), name: "Navy Birthday",
                 group: .honors, how: "Train on 13 October",
                 citation: "Trained on the Navy's birthday.",
                 status: navyBirthday ? "OCT 13" : "TRAIN OCT 13", earned: navyBirthday),
            Coin(key: "af-birthday", art: .png("badge-af-birthday"), name: "Air Force Birthday",
                 group: .honors, how: "Train on 18 September",
                 citation: "Trained on the Air Force birthday.",
                 status: afBirthday ? "SEP 18" : "TRAIN SEP 18", earned: afBirthday),
            Coin(key: "veterans-day", art: .png("badge-veterans-day"), name: "Veterans Day",
                 group: .honors, how: "Train on 11 November",
                 citation: "Trained on Veterans Day.",
                 status: veteransDay ? "NOV 11" : "TRAIN NOV 11", earned: veteransDay),
            Coin(key: "memorial-day", art: .png("badge-memorial-day"), name: "Memorial Day",
                 group: .honors, how: "Train on Memorial Day",
                 citation: "Trained on Memorial Day.",
                 status: memorialDay ? "HONORED" : "TRAIN MEM DAY", earned: memorialDay),
            Coin(key: "independence-day", art: .png("badge-independence-day"), name: "Independence Day",
                 group: .honors, how: "Train on 4 July",
                 citation: "Trained on Independence Day.",
                 status: independenceDay ? "JUL 4" : "TRAIN JUL 4", earned: independenceDay)
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

    /// Count of logged activities that started before 0600. The old badge
    /// fired on the first one; the v2 catalog raises it to ten.
    private var earlyBirdCount: Int {
        allActivityDates.filter { Calendar.current.component(.hour, from: $0) < 6 }.count
    }

    private func streakStatus(_ days: Int) -> String {
        vm.streak >= days ? "ACTIVE" : "\(vm.streak)/\(days)"
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
    private var marinesBirthday: Bool { activity(onMonth: 11, day: 10) }
    private var navyBirthday: Bool { activity(onMonth: 10, day: 13) }
    private var afBirthday: Bool { activity(onMonth: 9, day: 18) }

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
