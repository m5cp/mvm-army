import SwiftUI

nonisolated struct LegalSection: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let body: String
    let tint: Color
}

struct LegalDetailView: View {
    let title: String
    let icon: String
    let accentColor: Color
    let subtitle: String
    let lastUpdated: String
    let sections: [LegalSection]

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerCard
                        .padding(.bottom, 24)

                    VStack(spacing: 16) {
                        ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                            sectionCard(section, index: index)
                        }
                    }

                    footerBadge
                        .padding(.top, 28)
                        .padding(.bottom, 60)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .adaptiveContainer()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var headerCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 64, height: 64)

                Image(systemName: icon)
                    .font(.title.weight(.bold))
                    .foregroundStyle(accentColor)
                    .symbolEffect(.pulse, options: .repeating.speed(0.5))
            }

            Text(subtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.caption2.weight(.semibold))
                Text(lastUpdated)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(MVMTheme.tertiaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(MVMTheme.cardSoft)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(MVMTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(accentColor.opacity(0.15))
        }
    }

    private func sectionCard(_ section: LegalSection, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: section.icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(section.tint)
                    .frame(width: 32, height: 32)
                    .background(section.tint.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                Text(section.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer()

                Text("\(index + 1)")
                    .font(.caption2.weight(.heavy).monospacedDigit())
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .frame(width: 22, height: 22)
                    .background(MVMTheme.cardSoft)
                    .clipShape(Circle())
            }

            Text(section.body)
                .font(.caption)
                .foregroundStyle(MVMTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding(16)
        .background(MVMTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(MVMTheme.border)
        }
    }

    private var footerBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.shield.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.accent)
            Text("MVM FITNESS")
                .font(.caption2.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(MVMTheme.cardSoft)
        .clipShape(Capsule())
    }
}

struct LegalTextView: View {
    let title: String
    let content: String

    var body: some View {
        let page = LegalPages.page(for: title)
        LegalDetailView(
            title: page.title,
            icon: page.icon,
            accentColor: page.accent,
            subtitle: page.subtitle,
            lastUpdated: page.updated,
            sections: page.sections
        )
    }
}

nonisolated struct LegalPage {
    let title: String
    let icon: String
    let accent: Color
    let subtitle: String
    let updated: String
    let sections: [LegalSection]
}

enum LegalPages {
    static func page(for title: String) -> LegalPage {
        switch title {
        case "Privacy Policy": return privacyPage
        case "Terms of Use": return termsPage
        case "Disclaimer": return disclaimerPage
        case "Risks": return risksPage
        case "Accessibility": return accessibilityPage
        default: return disclaimerPage
        }
    }

    static let privacyPage = LegalPage(
        title: "Privacy Policy",
        icon: "lock.shield.fill",
        accent: MVMTheme.accent,
        subtitle: "Your data is locked down tighter than a wall locker during inspection. Zero tracking, zero accounts, zero nonsense.",
        updated: "March 2026",
        sections: [
            LegalSection(icon: "wifi.slash", title: "Goes Where You Go", body: "No Wi-Fi? No problem. MVM Fitness runs fully offline — the AFT Calculator, workouts, plans, logs, progress, share cards, and QR codes all work without a single bar of signal. Think of it as your battle buddy that never needs a hotspot.", tint: MVMTheme.accent),
            LegalSection(icon: "iphone.and.arrow.forward", title: "Your Phone, Your Vault", body: "Every workout plan, completed session, AFT score, step count, and preference lives right here on your device. Nothing gets shipped to a server, sold to a data broker, or whispered to a third party. Unless you hit share — then that's on you, soldier.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "person.badge.minus", title: "No Sign-Up, No BS", body: "No email, no password, no username, no registration form. Just open the app and get to work. We don't need to know who you are to help you get stronger.", tint: MVMTheme.accent2),
            LegalSection(icon: "heart.text.square", title: "Apple Health", body: "If you choose to connect Apple Health, we'll read your steps, calories, cycling, elliptical, running/walking distance, and other activity data, and save your workout sessions. That's it. Your health data never leaves the app, never gets sold, and never ends up in an ad. Pinky promise (the legally binding kind).\n\nIf you decline Apple Health access, the app still works — your daily steps will still be tracked using your device's built-in pedometer (no Apple Health needed). You just won't see the extra activity data like cycling or calories.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "apps.iphone", title: "What We Access & Why", body: "• Apple Health — steps, calories, cycling, elliptical, running/walking, and other activities (you grant permission)\n• Pedometer — daily step count via your device's motion sensor (always available, no permission needed, stays on device)\n• Camera — QR scanning only (not selfies, we promise)\n• Calendar — sync workouts if you enable it\n• Photo Library — save share cards & score images\n• Notifications — your daily PT reminder\n\nEvery feature asks first. The pedometer is the one exception — it uses your device's built-in motion sensor and doesn't require any permission. All other features ask before accessing anything.", tint: MVMTheme.warning),
            LegalSection(icon: "square.and.arrow.up", title: "When You Share", body: "Export a DA Form 705, share a QR code, or drop a workout on your calendar — that content leaves through standard iOS sharing. Once it's out there, it's out there. We can't chase down your group chat.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "hand.raised.slash", title: "Zero Trackers", body: "No analytics. No ad SDKs. No sneaky third-party code watching you. Your workout data doesn't secretly fund someone's startup. We built this clean.", tint: MVMTheme.accent),
            LegalSection(icon: "person.2.slash", title: "Kids & This App", body: "MVM Fitness isn't built for anyone under 13, and we don't knowingly collect info from minors. If your kid wants to do burpees, they can — but this app is for the grown-ups.", tint: MVMTheme.tertiaryText),
            LegalSection(icon: "envelope", title: "Got Questions?", body: "Hit us up through the App Store listing. We actually read those.", tint: MVMTheme.accent2)
        ]
    )

    static let termsPage = LegalPage(
        title: "Terms of Use",
        icon: "doc.text.fill",
        accent: MVMTheme.slateAccent,
        subtitle: "The ground rules — plain English, no lawyer decoder ring required.",
        updated: "March 2026",
        sections: [
            LegalSection(icon: "hand.thumbsup", title: "The Handshake", body: "By downloading or using MVM Fitness, you're agreeing to these terms and Apple's Standard EULA:\nhttps://www.apple.com/legal/internet-services/itunes/dev/stdeula/\n\nQuick note: We're not affiliated with or endorsed by CrossFit, Inc. Workout names are used for general fitness and educational purposes only.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "figure.run", title: "What We Built", body: "MVM Fitness is a planning and accountability tool — not a personal trainer in your pocket. We generate workout templates from publicly available exercise formats and your preferences. We don't prescribe exercises, give medical advice, or claim to know your body better than you do.", tint: MVMTheme.accent),
            LegalSection(icon: "cross.case", title: "We're Not Doctors", body: "This app doesn't diagnose, treat, cure, or prevent anything. If something hurts, stop. If you're unsure, ask your doc. We make workout cards, not medical recommendations.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "heart.text.square", title: "Health Data", body: "Grant us Apple Health access and we'll read your steps, calories, and save your workouts. That data stays in the app — never sold, never advertised against, never used for anything sketchy.", tint: MVMTheme.accent2),
            LegalSection(icon: "person.fill.checkmark", title: "You Own Your Reps", body: "You're responsible for knowing your limits, using proper form, and stopping when something feels wrong. Pain, dizziness, seeing stars? Drop the weight, take a knee, and listen to your body.", tint: MVMTheme.warning),
            LegalSection(icon: "shield.slash", title: "The Fine Print", body: "The app is provided \"as is\" — no warranties, no guarantees. We're not liable for injuries, losses, or that one time you tried to PR your deadlift at 0500 on three hours of sleep.", tint: MVMTheme.tertiaryText),
            LegalSection(icon: "lock.doc", title: "Our Work", body: "All content, design, and code belong to the developer. Workout formats are based on publicly available fitness standards. Built with love, caffeine, and an unreasonable number of burpees.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "envelope", title: "Talk to Us", body: "Questions, concerns, or just want to say hooah? Reach out through the App Store listing.", tint: MVMTheme.accent2)
        ]
    )

    static let disclaimerPage = LegalPage(
        title: "Disclaimer",
        icon: "exclamationmark.triangle.fill",
        accent: MVMTheme.warning,
        subtitle: "Real talk about what this app does, what it doesn't, and why you should still see your doc.",
        updated: "March 2026",
        sections: [
            LegalSection(icon: "info.circle", title: "What You're Getting", body: "MVM Fitness gives you workout templates, planning tools, and a way to hold yourself accountable. That's it. It's not a personal trainer, not a prescription, and not a green light to start a new exercise program without checking with your doc first. Think of it as your organized battle buddy — not your medic.", tint: MVMTheme.warning),
            LegalSection(icon: "list.clipboard", title: "About the Workouts", body: "Every workout comes from a library of templates — Army fitness structures, H2F drill categories, general fitness formats, and your selected preferences like focus area, equipment, and duration.\n\nWe don't know your injury history, your 1RM, or that one knee that clicks when it rains. The app doesn't evaluate your physical condition or readiness. That part's on you.", tint: MVMTheme.accent),
            LegalSection(icon: "flag.fill", title: "Honoring the Fallen", body: "Memorial workouts carry the names and stories of those who made the ultimate sacrifice. We include them so their legacy lives on through every rep, every round, and every drop of sweat.\n\nThese stories are sourced from publicly available information and may be limited. If you spot an error or have additional details, please reach out — getting it right matters.\n\nThis app is not affiliated with or endorsed by CrossFit, Inc. Workout names and formats are used for general fitness and educational purposes only.", tint: MVMTheme.heroAmber),
            LegalSection(icon: "cross.case", title: "Not Your Doctor", body: "MVM Fitness doesn't diagnose, treat, cure, or prevent anything. Nothing here is medical advice — not even a little bit. When in doubt, talk to an actual human with a medical degree.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "number", title: "AFT Scores", body: "The calculator gives you estimates for planning purposes. Your actual score may differ due to rounding, table variations, or that extra rep the grader may or may not have counted. Official scores come from authorized Army personnel under real testing conditions.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "doc.richtext", title: "DA Form 705", body: "The exported 705 is a formatted convenience document built from your input — not an official Army record. Double-check everything before you hand it to anyone with rank.", tint: MVMTheme.accent2),
            LegalSection(icon: "exclamationmark.shield", title: "Bottom Line", body: "We built this app with care, but we make no guarantees about perfect accuracy or suitability for your specific situation. Use it at your own risk — and use your head while you're at it.", tint: MVMTheme.tertiaryText)
        ]
    )

    static let risksPage = LegalPage(
        title: "Risks",
        icon: "bolt.heart.fill",
        accent: Color(hex: "#EF4444"),
        subtitle: "PT makes you stronger — but it can also break you if you're not smart about it. Read this.",
        updated: "March 2026",
        sections: [
            LegalSection(icon: "stethoscope", title: "Doc First, Reps Second", body: "Before you start any new workout or exercise program, talk to a doctor or qualified medical professional. MVM Fitness is a planning and tracking tool — it doesn't know if you tore your ACL last year or if your blood pressure runs high. That's between you and your provider.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "exclamationmark.triangle", title: "The Real Talk", body: "Physical training comes with real risks, including:\n\n• Muscle strains, sprains, and tears\n• Joint and bone injuries\n• Overexertion and heat-related illness\n• Cardiovascular complications\n• Stress fractures\n• Aggravation of existing conditions\n\nThis isn't meant to scare you — it's meant to make you train smart.", tint: MVMTheme.warning),
            LegalSection(icon: "person.fill.checkmark", title: "Your Lane", body: "You're the one in charge of:\n\n• Knowing your fitness level and limits\n• Using proper form (ego lifting doesn't count)\n• Warming up and cooling down\n• Staying within safe exertion levels\n• Following medical and command guidance\n• Stopping immediately if something feels wrong\n\nNo app can replace your own judgment.", tint: MVMTheme.accent),
            LegalSection(icon: "cross.case", title: "Not a Replacement", body: "MVM Fitness doesn't replace your doctor, your unit medic, your physical therapist, or your NCO telling you to hydrate. Always prioritize your health and safety over any workout plan or PR goal.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "checkmark.circle", title: "Roger That", body: "By using this app, you're acknowledging that you understand the risks of physical training and accept full responsibility for your participation in any activity guided by or tracked within MVM Fitness. Train hard, train smart, stay in the fight.", tint: MVMTheme.accent2)
        ]
    )

    static let accessibilityPage = LegalPage(
        title: "Accessibility",
        icon: "accessibility",
        accent: MVMTheme.accent2,
        subtitle: "Every soldier deserves full access to their tools. We built this for everyone — no exceptions.",
        updated: "March 2026",
        sections: [
            LegalSection(icon: "speaker.wave.3", title: "VoiceOver Ready", body: "Every button, control, and screen has been labeled for VoiceOver. If you navigate by ear, we've got your six. Accessibility labels and hints are baked in throughout the entire app.", tint: MVMTheme.accent),
            LegalSection(icon: "textformat.size", title: "Your Font, Your Size", body: "Crank up that text size in iOS Settings and MVM Fitness scales right with you. Dynamic Type support means you can read everything comfortably — no squinting at tiny numbers during your AFT.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "moon.fill", title: "Dark Mode Native", body: "Built dark-first with high-contrast text because staring at a bright screen at 0430 is nobody's idea of a good time. Light mode is supported too — we respect your system setting.", tint: MVMTheme.accent2),
            LegalSection(icon: "hand.tap", title: "Big Tap Targets", body: "Every button meets Apple's 44x44pt minimum — because tapping a tiny button with sweaty hands after a set of deadlifts is a UX nightmare we refused to ship.", tint: MVMTheme.warning),
            LegalSection(icon: "arrow.left.arrow.right", title: "Reduce Motion", body: "If you've turned on Reduce Motion in iOS Settings, we tone down the animations. Smooth experience without the extra visual noise.", tint: MVMTheme.tertiaryText),
            LegalSection(icon: "circle.lefthalf.filled", title: "Contrast That Pops", body: "Text and interactive elements maintain strong contrast ratios in both light and dark modes. If you can see it, you can use it — that's the standard.", tint: MVMTheme.accent),
            LegalSection(icon: "envelope", title: "Found a Barrier?", body: "If something isn't working for you, tell us. Reach out through the App Store listing — we take accessibility feedback seriously and will work to fix it.", tint: MVMTheme.accent2)
        ]
    )
}

enum LegalContent {
    static let privacyPolicy = ""
    static let termsOfUse = ""
    static let disclaimer = ""
    static let accessibilityStatement = ""
    static let risks = ""
}
