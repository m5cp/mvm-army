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
        subtitle: "Your data stays on your device. No accounts, no tracking, no surprises.",
        updated: "March 2026",
        sections: [
            LegalSection(icon: "wifi.slash", title: "Offline-First Design", body: "MVM Fitness works fully offline. The AFT Calculator, workout viewing, plan management, logging, progress tracking, share cards, and QR codes all function without an internet connection. Cloud sync, if available, is optional.", tint: MVMTheme.accent),
            LegalSection(icon: "iphone.and.arrow.forward", title: "Data Storage", body: "All data — workout plans, completed records, AFT scores, step history, and preferences — is stored locally on your device. Nothing is transmitted, uploaded, or shared with any external server or third party unless you explicitly choose to export or share content.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "person.badge.minus", title: "No Accounts Required", body: "No user accounts, login credentials, or personal identification needed. There is no registration process.", tint: MVMTheme.accent2),
            LegalSection(icon: "heart.text.square", title: "Apple Health (HealthKit)", body: "The App optionally integrates with Apple Health to read step count and active energy data, and save completed workout sessions. This requires your explicit permission. Health data is never sold, shared with third parties, used for advertising, or transferred outside the App.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "apps.iphone", title: "Device Features", body: "Apple Health — read steps/calories, save workouts (permission required)\nPedometer — count daily steps (stays on device)\nCamera — QR code scanning only\nCalendar — sync workouts when you enable it\nPhoto Library — save share cards/score images\nNotifications — optional daily reminders\n\nNo feature accesses data without your action or permission.", tint: MVMTheme.warning),
            LegalSection(icon: "square.and.arrow.up", title: "Exported Content", body: "When you export a DA Form 705 PDF, share a QR code, or add calendar events, content leaves the App through standard iOS sharing. The App does not control how shared content is used after export.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "hand.raised.slash", title: "No Tracking", body: "No analytics, advertising, or tracking frameworks. No third-party SDKs collect data. Data is never sold to third parties. Not affiliated with or endorsed by CrossFit, Inc.", tint: MVMTheme.accent),
            LegalSection(icon: "person.2.slash", title: "Children's Privacy", body: "The App is not directed at children under 13 and does not knowingly collect information from children.", tint: MVMTheme.tertiaryText),
            LegalSection(icon: "envelope", title: "Questions?", body: "Contact the developer through the App Store listing.", tint: MVMTheme.accent2)
        ]
    )

    static let termsPage = LegalPage(
        title: "Terms of Use",
        icon: "doc.text.fill",
        accent: MVMTheme.slateAccent,
        subtitle: "The ground rules for using MVM Fitness. Straightforward, no legalese maze.",
        updated: "March 2026",
        sections: [
            LegalSection(icon: "hand.thumbsup", title: "Agreement", body: "By downloading or using MVM Fitness, you agree to these Terms and Apple's Standard EULA:\nhttps://www.apple.com/legal/internet-services/itunes/dev/stdeula/\n\nNot affiliated with or endorsed by CrossFit, Inc. Workout names and formats are used for general fitness and educational purposes only.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "figure.run", title: "Fitness Disclaimer", body: "This is a fitness planning and accountability tool. It generates workout templates from publicly available exercise formats and user preferences. It does not provide personalized fitness prescriptions, medical advice, or clinical recommendations.", tint: MVMTheme.accent),
            LegalSection(icon: "cross.case", title: "Non-Medical", body: "The App does not diagnose, treat, cure, or prevent any medical condition. Nothing should be interpreted as medical guidance. Always consult a qualified medical professional before starting any exercise program.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "heart.text.square", title: "HealthKit Data", body: "If you grant Apple Health access, the App reads step count and active energy data, and saves completed workouts. This data is never sold, shared with advertisers, or used beyond displaying your fitness info within the App.", tint: MVMTheme.accent2),
            LegalSection(icon: "person.fill.checkmark", title: "Your Responsibility", body: "You are solely responsible for assessing your own physical readiness and using proper form. Stop immediately if you experience pain, dizziness, or other warning signs.", tint: MVMTheme.warning),
            LegalSection(icon: "shield.slash", title: "Limitation of Liability", body: "The App is provided \"as is\" without warranty. The developer is not liable for any injury, loss, or damage arising from use of the App or any workout performed using its information.", tint: MVMTheme.tertiaryText),
            LegalSection(icon: "lock.doc", title: "Intellectual Property", body: "All content, design, and code are the property of the developer. Workout formats are based on publicly available fitness standards.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "envelope", title: "Questions?", body: "Contact the developer through the App Store listing.", tint: MVMTheme.accent2)
        ]
    )

    static let disclaimerPage = LegalPage(
        title: "Disclaimer",
        icon: "exclamationmark.triangle.fill",
        accent: MVMTheme.warning,
        subtitle: "What this app is, what it isn't, and what you should know before you sweat.",
        updated: "March 2026",
        sections: [
            LegalSection(icon: "info.circle", title: "What This App Is", body: "MVM Fitness provides example workout structures, planning tools, and accountability tracking. It is not a personalized workout plan, not a prescription for exercise, and not a recommendation to begin a new exercise program. It is intended for organization, tracking, and administrative support only.", tint: MVMTheme.warning),
            LegalSection(icon: "list.clipboard", title: "Workout Content", body: "Workouts are examples based on stored templates, Army fitness test structures, H2F drill categories, and general fitness formats. They come from a library of predefined templates combined with user-selected preferences such as focus area, equipment, and duration.\n\nThe App does not evaluate your physical condition, medical history, or readiness to perform any exercise.", tint: MVMTheme.accent),
            LegalSection(icon: "flag.fill", title: "Memorial Workouts", body: "Memorial workouts are included to honor individuals who gave their lives in service to their country. These workouts carry the names and stories of fallen heroes so their sacrifice is never forgotten.\n\nInformation is based on publicly available sources and may be limited. If you identify an error, please contact us for correction.\n\nThis app is not affiliated with or endorsed by CrossFit, Inc. Workout names and formats are used for general fitness and educational purposes only.", tint: MVMTheme.heroAmber),
            LegalSection(icon: "cross.case", title: "Not Medical Advice", body: "The App does not provide medical advice, diagnose any condition, or recommend any treatment. Nothing should be interpreted as medical guidance.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "number", title: "AFT Score Calculator", body: "The AFT calculator and scoring tools are for estimation and planning purposes only. Scores may not exactly match official Army scoring due to rounding, table variations, or data entry. Official scores are determined by authorized Army personnel under testing conditions.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "doc.richtext", title: "DA Form 705 Export", body: "The DA Form 705 export generates a formatted document from user-entered data. It is an administrative convenience and does not constitute an official Army record. Verify all exported data for accuracy before use.", tint: MVMTheme.accent2),
            LegalSection(icon: "exclamationmark.shield", title: "General", body: "The developer makes no representations or warranties regarding the accuracy, completeness, or suitability of any content in the App. Use of the App is at your own risk.", tint: MVMTheme.tertiaryText)
        ]
    )

    static let risksPage = LegalPage(
        title: "Risks",
        icon: "bolt.heart.fill",
        accent: Color(hex: "#EF4444"),
        subtitle: "Physical training has inherent risks. Know them, respect them, train smart.",
        updated: "March 2026",
        sections: [
            LegalSection(icon: "stethoscope", title: "Consult a Professional", body: "Consult with a doctor or qualified medical professional before starting any workout or exercise program. MVM Fitness is an accountability tracker and planning tool only. It does not determine whether a workout is appropriate for any individual.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "exclamationmark.triangle", title: "Potential Risks", body: "Physical exercise may involve:\n\n• Muscle strains, sprains, and tears\n• Joint injuries\n• Overexertion and heat-related illness\n• Cardiovascular complications\n• Bone fractures or stress injuries\n• Aggravation of pre-existing conditions", tint: MVMTheme.warning),
            LegalSection(icon: "person.fill.checkmark", title: "Your Responsibility", body: "You are solely responsible for:\n\n• Assessing your fitness level and physical readiness\n• Using proper form and technique\n• Following warm-up and cooldown procedures\n• Staying within safe limits of exertion\n• Following medical and command guidance\n• Stopping immediately if experiencing pain or dizziness", tint: MVMTheme.accent),
            LegalSection(icon: "cross.case", title: "Not a Substitute", body: "The App is not a substitute for professional medical advice, military medical screening, or guidance from qualified fitness professionals. Always prioritize your health and safety over any workout plan or training goal.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "checkmark.circle", title: "Acknowledgment", body: "By using MVM Fitness, you acknowledge that you understand these risks and accept full responsibility for your participation in any physical activity guided by or tracked within the App.", tint: MVMTheme.accent2)
        ]
    )

    static let accessibilityPage = LegalPage(
        title: "Accessibility",
        icon: "accessibility",
        accent: MVMTheme.accent2,
        subtitle: "Built for everyone. We want every soldier to have full access to this tool.",
        updated: "March 2026",
        sections: [
            LegalSection(icon: "speaker.wave.3", title: "VoiceOver", body: "All interactive controls, buttons, and navigation elements include accessibility labels and hints so VoiceOver users can navigate the App effectively.", tint: MVMTheme.accent),
            LegalSection(icon: "textformat.size", title: "Dynamic Type", body: "The App supports Dynamic Type. Text scales according to your preferred text size set in iOS Settings, ensuring readability at all sizes.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "moon.fill", title: "Dark Mode", body: "The App uses a dark-first design with high-contrast text. Both light and dark color schemes are supported and respect your system appearance setting.", tint: MVMTheme.accent2),
            LegalSection(icon: "hand.tap", title: "Touch Targets", body: "All interactive elements meet the minimum 44x44 point touch target size recommended by Apple Human Interface Guidelines.", tint: MVMTheme.warning),
            LegalSection(icon: "arrow.left.arrow.right", title: "Reduce Motion", body: "The App respects the Reduce Motion accessibility setting where applicable to minimize animations.", tint: MVMTheme.tertiaryText),
            LegalSection(icon: "circle.lefthalf.filled", title: "Color Contrast", body: "Text and interactive elements maintain sufficient contrast ratios against their backgrounds in both light and dark modes.", tint: MVMTheme.accent),
            LegalSection(icon: "envelope", title: "Feedback", body: "Encounter an accessibility barrier? Contact the developer through the App Store listing. We welcome feedback to improve accessibility.", tint: MVMTheme.accent2)
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
