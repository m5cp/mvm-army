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
        .accessibilityElement(children: .combine)
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
        case "EULA": return eulaPage
        default: return disclaimerPage
        }
    }

    static let privacyPage = LegalPage(
        title: "Privacy Policy",
        icon: "lock.shield.fill",
        accent: MVMTheme.accent,
        subtitle: "Your data stays on your device. No tracking, no accounts, no data sharing.",
        updated: "April 2026",
        sections: [
            LegalSection(icon: "externaldrive.fill", title: "Data Collection", body: "MVM Fitness is a fitness tracking and accountability tool. All user data — including workout logs, AFT scores, step counts, plans, and preferences — is stored locally on your device. No personal data is collected, transmitted, sold, or shared. The app functions fully offline.", tint: MVMTheme.accent),
            LegalSection(icon: "chart.bar.fill", title: "Data Usage", body: "Your data is used solely to display your fitness activity, visualize progress, and track workouts you choose to log. Every workout record, AFT score, step count, and preference stays on your device. Nothing is sent to external servers, analytics platforms, or third parties.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "person.badge.minus", title: "No Account Required", body: "MVM Fitness does not require registration, email, password, or any personally identifiable information. You use the app anonymously on your own device.", tint: MVMTheme.accent2),
            LegalSection(icon: "heart.text.square", title: "Apple Health Integration", body: "If you choose to grant Apple Health access, MVM Fitness reads the following data types for display and tracking purposes only:\n\n• Step count\n• Active energy burned (calories)\n• Walking + running distance\n• Cycling distance\n• Workout sessions by activity type\n\nYour health data is read locally, displayed within the app, and never transmitted, stored externally, sold, or shared with any third party.\n\nIf you decline Apple Health access, the app still functions — steps are tracked via your device's built-in pedometer. You simply won't see additional activity data like calories or cycling distance.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "cart", title: "Third-Party Services", body: "If in-app purchases are available, subscription handling is managed through RevenueCat, which processes transactions via Apple's App Store infrastructure. RevenueCat does not receive your fitness data, health data, or any personally identifiable information from MVM Fitness. No other third-party analytics, advertising, or tracking SDKs are included in this app.", tint: MVMTheme.accent2),
            LegalSection(icon: "apps.iphone", title: "Permissions & Access", body: "MVM Fitness may request the following device permissions:\n\n• Apple Health — read steps, calories, distance, and workout sessions (user-granted)\n• Pedometer — step count via built-in motion sensor (no permission required, stays on device)\n• Camera — QR code scanning only\n• Calendar — sync workout schedule if you enable it\n• Photo Library — save share cards and score images\n• Notifications — optional daily training reminder\n• Siri & Shortcuts — voice commands and Spotlight suggestions for quick access to scores and workouts\n• Home Screen Widgets — display today's workout and AFT score at a glance\n• Live Activities — show active workout progress on the Lock Screen and Dynamic Island\n\nAll permissions are requested only when needed. No permission is required to use the core app.", tint: MVMTheme.warning),
            LegalSection(icon: "lock.shield", title: "Data Security", body: "All data is stored securely on-device using iOS data protection. No data is transmitted to external servers. Widget data is shared between the app and its extensions via a secure App Group container on your device. When you share content — such as exporting a scorecard, sharing a QR code, or syncing to your calendar — that content leaves through standard iOS sharing mechanisms under your control.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "hand.raised.slash", title: "No Tracking", body: "MVM Fitness contains no analytics SDKs, no advertising frameworks, no user tracking, and no telemetry. Your usage data is not monitored, recorded, or transmitted.", tint: MVMTheme.accent),
            LegalSection(icon: "apple.intelligence", title: "Apple Intelligence (On-Device AI)", body: "MVM Fitness includes optional AI-powered features using Apple Intelligence, which runs entirely on your device via Apple's Foundation Models framework.\n\nHow it works:\n• AI insights analyze your workout history, AFT scores, and training patterns to generate personalized progress analysis, weekly summaries, and coaching tips.\n• All AI processing happens locally on your iPhone using Apple's on-device language model. No data is sent to any server, cloud service, or third party.\n• Your fitness data never leaves your device for AI processing.\n\nDevice requirements:\n• Apple Intelligence features require iPhone 15 Pro or later running iOS 26 or newer, with Apple Intelligence enabled in Settings.\n• On devices that do not meet these requirements, AI features are simply not shown. The app functions fully without them.\n\nApple Intelligence is governed by Apple's own privacy policies. MVM Fitness does not control or modify Apple's on-device AI model.", tint: Color(hex: "#6366F1")),
            LegalSection(icon: "person.2.slash", title: "Children", body: "MVM Fitness is not designed for or directed at children under 13. We do not knowingly collect information from minors.", tint: MVMTheme.tertiaryText),
            LegalSection(icon: "envelope", title: "Contact", body: "For privacy-related questions or concerns, contact us through the App Store listing or via email.\n\nMVM Fitness is not affiliated with, endorsed by, or sponsored by the U.S. Department of Defense, the Department of the Army, or any government agency.", tint: MVMTheme.accent2)
        ]
    )

    static let termsPage = LegalPage(
        title: "Terms of Use",
        icon: "doc.text.fill",
        accent: MVMTheme.slateAccent,
        subtitle: "Clear terms for using MVM Fitness. Plain language, no ambiguity.",
        updated: "April 2026",
        sections: [
            LegalSection(icon: "hand.thumbsup", title: "Apple Standard EULA", body: "By downloading or using MVM Fitness, you agree to these Terms of Use and Apple's Standard End User License Agreement (EULA):\nhttps://www.apple.com/legal/internet-services/itunes/dev/stdeula/\n\nThis EULA governs your use of the app as distributed through the Apple App Store.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "figure.run", title: "What This App Is", body: "MVM Fitness is a fitness tracking and accountability tool. It allows you to:\n\n• Log and track workouts you perform\n• Calculate estimated AFT scores\n• Build workout plans from template libraries\n• View activity data from Apple Health\n• Track daily steps and training streaks\n• Use Siri Shortcuts to check scores and start workouts by voice\n• View today's workout and AFT score via Home Screen and Lock Screen widgets\n• Track active workout progress via Live Activities on the Lock Screen and Dynamic Island\n• Use on-device Apple Intelligence for AI-powered progress insights, weekly summaries, and coaching tips (on supported devices)\n\nYou choose your own exercises, routines, and training schedule. The app does not prescribe, recommend, or coach any specific exercise program.", tint: MVMTheme.accent),
            LegalSection(icon: "xmark.shield", title: "What This App Is Not", body: "MVM Fitness is not a personal trainer, coach, medical advisor, or fitness instructor. It does not evaluate your physical readiness, diagnose conditions, or provide individualized exercise prescriptions. All workout content consists of templates based on publicly available fitness formats — not personalized guidance.\n\nAI-generated insights are general observations based on your training data, not medical or professional fitness advice. Always consult qualified professionals for health and training decisions.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "number", title: "Accuracy", body: "AFT scores and calculations are estimates for personal tracking and planning purposes only. Actual scores may differ due to rounding, table variations, or official testing conditions. Users are responsible for verifying results through authorized testing channels.", tint: MVMTheme.warning),
            LegalSection(icon: "heart.text.square", title: "Health Data", body: "If you grant Apple Health access, MVM Fitness reads your activity data for display within the app. This data is never sold, shared, or transmitted externally. Your health data stays on your device at all times.", tint: MVMTheme.accent2),
            LegalSection(icon: "person.fill.checkmark", title: "User Responsibility", body: "You are solely responsible for:\n\n• Knowing your physical capabilities and limitations\n• Using proper exercise form and technique\n• Stopping activity if you experience pain, dizziness, or discomfort\n• Consulting a qualified medical professional before starting any exercise program\n• Ensuring exercises you select are appropriate for your fitness level\n\nMVM Fitness provides tools — your safety decisions are your own.", tint: MVMTheme.accent),
            LegalSection(icon: "shield.slash", title: "Limitation of Liability", body: "The developer is not responsible for any injuries, damages, health outcomes, or losses resulting from use of this app. MVM Fitness is provided \"as is\" without warranties of any kind, express or implied. All workout content is based on publicly available fitness standards and is provided for informational and tracking purposes only.", tint: MVMTheme.tertiaryText),
            LegalSection(icon: "exclamationmark.triangle", title: "Misuse", body: "You agree not to use MVM Fitness for any purpose that is unlawful, harmful, or inconsistent with its intended use as a personal fitness tracking tool. The developer reserves the right to update these terms at any time.", tint: MVMTheme.warning),
            LegalSection(icon: "apple.intelligence", title: "Apple Intelligence Features", body: "MVM Fitness includes optional AI-powered features using Apple Intelligence (iOS 26+, iPhone 15 Pro or later). These features provide training insights, weekly summaries, and coaching tips generated on-device.\n\nBy using these features, you acknowledge that:\n\n• AI-generated content is for informational purposes only and is not a substitute for professional fitness or medical advice\n• The on-device AI model may produce inaccurate, incomplete, or generic responses\n• All AI processing occurs locally on your device — no data is transmitted externally\n• AI features are optional and the app functions fully without them\n• Apple Intelligence availability depends on your device model, iOS version, and Settings configuration", tint: Color(hex: "#6366F1")),
            LegalSection(icon: "lock.doc", title: "Intellectual Property", body: "All content, design, code, and branding within MVM Fitness belong to the developer. Workout templates are based on publicly available fitness standards and exercise formats.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "building.columns", title: "Independence Disclaimer", body: "MVM Fitness is not affiliated with, endorsed by, or sponsored by the U.S. Department of Defense, the Department of the Army, or any government agency. All fitness standards referenced are based on publicly available information.", tint: MVMTheme.accent2),
            LegalSection(icon: "envelope", title: "Contact", body: "Questions about these terms? Reach out through the App Store listing or via email.", tint: MVMTheme.accent2)
        ]
    )

    static let disclaimerPage = LegalPage(
        title: "Disclaimer",
        icon: "exclamationmark.triangle.fill",
        accent: MVMTheme.warning,
        subtitle: "Important information about what this app does and does not do.",
        updated: "April 2026",
        sections: [
            LegalSection(icon: "info.circle", title: "Purpose of This App", body: "MVM Fitness is a fitness tracking and accountability tool. It provides workout templates, an AFT score calculator, activity tracking, and planning features. The app is designed to help you log, organize, and visualize your own training — not to coach, instruct, or prescribe exercises.", tint: MVMTheme.warning),
            LegalSection(icon: "list.clipboard", title: "Workout Content", body: "Workouts in this app are templates based on publicly available exercise formats and fitness standards. They are organized by category, equipment, and duration for your convenience.\n\nThe app does not assess your physical condition, injury history, or readiness for any exercise. Selecting and performing any workout is entirely your decision and responsibility.", tint: MVMTheme.accent),
            LegalSection(icon: "cross.case", title: "No Medical Advice", body: "MVM Fitness does not provide medical advice, diagnosis, or treatment. Nothing in this app should be interpreted as a substitute for professional medical guidance. Always consult a qualified healthcare provider before beginning any exercise program or if you have concerns about your health.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "figure.run", title: "No Coaching or Instruction", body: "This app does not provide personal training, coaching, exercise instruction, or individualized fitness recommendations. It is a self-directed tool — you build your own workouts, choose your own exercises, and manage your own training schedule.\n\nAI-generated insights and coaching tips (available on supported devices with Apple Intelligence) are general observations based on your logged data. They are not professional fitness advice and should not be treated as such.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "flag.fill", title: "Content Origin", body: "All workouts use original naming and are based on publicly available exercise formats and fitness standards. Workout structures are designed for general fitness tracking purposes.\n\nThis app is not affiliated with, endorsed by, or sponsored by the U.S. Department of Defense, the Department of the Army, or any government agency.", tint: MVMTheme.accent),
            LegalSection(icon: "number", title: "AFT Score Estimates", body: "The AFT calculator provides estimates for personal tracking and planning. Actual scores may differ due to rounding, table variations, or official testing conditions. Official scores come from authorized Army personnel under real testing conditions.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "doc.richtext", title: "Exported Documents", body: "Exported score reports and share cards are formatted documents built from your input. They are not official military records and are for personal reference only.", tint: MVMTheme.accent2),
            LegalSection(icon: "apple.intelligence", title: "Apple Intelligence Disclaimer", body: "AI-powered features in MVM Fitness use Apple's on-device Foundation Models framework. These features are optional and require iPhone 15 Pro or later with iOS 26 and Apple Intelligence enabled in Settings.\n\nAI-generated insights, summaries, and coaching tips are based on your locally stored training data and produced by Apple's on-device language model. This content:\n\n• May be inaccurate, incomplete, or generic\n• Is not a substitute for professional fitness, medical, or coaching advice\n• Is processed entirely on your device — no data leaves your phone\n• Should be used as supplementary information only, not as the basis for training or health decisions\n\nThe developer does not control Apple's AI model and makes no guarantees about the quality or accuracy of AI-generated content.", tint: Color(hex: "#6366F1")),
            LegalSection(icon: "exclamationmark.shield", title: "No Warranties", body: "MVM Fitness is provided \"as is\" without guarantees of accuracy, completeness, or suitability for any specific purpose. Use the app at your own risk and exercise your own judgment at all times.", tint: MVMTheme.tertiaryText)
        ]
    )

    static let risksPage = LegalPage(
        title: "Risks",
        icon: "bolt.heart.fill",
        accent: Color(hex: "#EF4444"),
        subtitle: "Physical activity carries inherent risks. Read this before training.",
        updated: "April 2026",
        sections: [
            LegalSection(icon: "stethoscope", title: "Consult a Professional", body: "Before beginning any exercise program, consult a qualified medical professional. MVM Fitness is a tracking tool — it does not evaluate your physical readiness, medical history, or health status. That assessment should come from your healthcare provider.", tint: Color(hex: "#EF4444")),
            LegalSection(icon: "exclamationmark.triangle", title: "Inherent Risks of Exercise", body: "Physical training carries real risks, including but not limited to:\n\n• Muscle strains, sprains, and tears\n• Joint and bone injuries\n• Overexertion and heat-related illness\n• Cardiovascular complications\n• Stress fractures\n• Aggravation of pre-existing conditions\n\nThese risks exist regardless of fitness level or experience.", tint: MVMTheme.warning),
            LegalSection(icon: "person.fill.checkmark", title: "Assumption of Risk", body: "By using MVM Fitness to track, log, or plan physical activity, you acknowledge that:\n\n• Physical exercise involves inherent risk of injury\n• You participate voluntarily in any activity you choose to perform\n• You are responsible for knowing your physical capabilities and limitations\n• You will use proper form and technique\n• You will stop immediately if you experience pain, dizziness, or discomfort\n• You will follow medical guidance from qualified professionals\n\nMVM Fitness is not responsible for any injury, illness, or adverse outcome resulting from physical activity tracked or planned using this app.", tint: MVMTheme.accent),
            LegalSection(icon: "cross.case", title: "Not a Substitute", body: "This app does not replace a doctor, physical therapist, athletic trainer, or any qualified professional. Always prioritize your health and safety over any training goal or workout plan.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "checkmark.circle", title: "Acknowledgment", body: "By using MVM Fitness, you acknowledge that you have read and understand this risk disclosure, that you accept full responsibility for your participation in any physical activity, and that you use this app at your own risk.", tint: MVMTheme.accent2)
        ]
    )

    static let accessibilityPage = LegalPage(
        title: "Accessibility",
        icon: "accessibility",
        accent: MVMTheme.accent2,
        subtitle: "MVM Fitness is built for everyone. Accessibility is a priority, not an afterthought.",
        updated: "April 2026",
        sections: [
            LegalSection(icon: "speaker.wave.3", title: "VoiceOver Support", body: "All interactive elements — buttons, cards, controls, screens, widgets, and Siri Shortcuts — include VoiceOver accessibility labels and hints. The app is designed to be fully navigable using VoiceOver. Siri Shortcuts provide voice-driven access to key features like checking your AFT score or starting today's workout.", tint: MVMTheme.accent),
            LegalSection(icon: "textformat.size", title: "Dynamic Type", body: "MVM Fitness supports Dynamic Type. Increase your preferred text size in iOS Settings and the app scales text throughout to match your preference.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "moon.fill", title: "Dark Mode", body: "The app is built dark-first with high-contrast text for comfortable use in any lighting condition. The interface respects your system appearance settings.", tint: MVMTheme.accent2),
            LegalSection(icon: "hand.tap", title: "Touch Targets", body: "All interactive elements meet Apple's minimum 44×44 point touch target requirement for comfortable and accurate interaction.", tint: MVMTheme.warning),
            LegalSection(icon: "arrow.left.arrow.right", title: "Reduce Motion", body: "When Reduce Motion is enabled in iOS Settings, the app reduces animations and transitions for a more comfortable experience.", tint: MVMTheme.tertiaryText),
            LegalSection(icon: "circle.lefthalf.filled", title: "Color Contrast", body: "Text and interactive elements maintain sufficient contrast ratios against their backgrounds, meeting accessibility standards for readability.", tint: MVMTheme.accent),
            LegalSection(icon: "ipad.and.iphone", title: "Device Support", body: "MVM Fitness is optimized for both iPhone and iPad with responsive layouts that adapt cleanly to different screen sizes and orientations. Home Screen widgets are available in multiple sizes, and Lock Screen widgets provide at-a-glance information. Live Activities display workout progress on the Lock Screen and Dynamic Island.", tint: MVMTheme.slateAccent),
            LegalSection(icon: "apple.intelligence", title: "Apple Intelligence Features", body: "MVM Fitness includes optional AI-powered features using Apple Intelligence. These features require specific hardware and software:\n\n• iPhone 15 Pro, iPhone 15 Pro Max, or any later iPhone model\n• iOS 26 or newer\n• Apple Intelligence must be enabled in Settings > Apple Intelligence & Siri\n\nOn supported devices, AI features provide on-device progress analysis, weekly training summaries, and coaching tips. All AI processing happens locally on your device.\n\nIf your device does not meet these requirements, AI features are not displayed and the app functions fully without them. No functionality is lost — AI insights are a supplementary feature.", tint: Color(hex: "#6366F1")),
            LegalSection(icon: "envelope", title: "Feedback", body: "If you encounter an accessibility barrier, please let us know through the App Store listing. We take accessibility feedback seriously and work to address it.", tint: MVMTheme.accent2)
        ]
    )

    static let eulaPage = LegalPage(
        title: "EULA",
        icon: "doc.badge.gearshape",
        accent: MVMTheme.slateAccent,
        subtitle: "End User License Agreement — governed by Apple's Standard EULA.",
        updated: "April 2026",
        sections: [
            LegalSection(icon: "apple.logo", title: "Apple Standard EULA", body: "MVM Fitness is licensed under Apple's Standard End User License Agreement (EULA) for apps distributed through the Apple App Store.\n\nYou can review the full EULA here:\nhttps://www.apple.com/legal/internet-services/itunes/dev/stdeula/", tint: MVMTheme.slateAccent),
            LegalSection(icon: "doc.text", title: "License Grant", body: "Subject to the terms of the Apple Standard EULA, you are granted a limited, non-exclusive, non-transferable license to use MVM Fitness on any Apple-branded device that you own or control, as permitted by the Usage Rules set forth in the Apple Media Services Terms and Conditions.", tint: MVMTheme.accent),
            LegalSection(icon: "xmark.circle", title: "Restrictions", body: "You may not:\n\n• Reverse-engineer, decompile, or disassemble the app\n• Redistribute, sublicense, or rent the app\n• Use the app for any unlawful purpose\n• Remove or alter any proprietary notices", tint: MVMTheme.warning),
            LegalSection(icon: "shield.checkered", title: "Disclaimer of Warranties", body: "MVM Fitness is provided \"as is\" and \"as available\" without warranties of any kind. The developer does not warrant that the app will be error-free, uninterrupted, or suitable for any particular purpose.", tint: MVMTheme.tertiaryText),
            LegalSection(icon: "building.columns", title: "Governing Terms", body: "This license is governed by the terms of the Apple Standard EULA. In the event of any conflict between these terms and the Apple Standard EULA, the Apple Standard EULA prevails.", tint: MVMTheme.accent2)
        ]
    )
}

enum LegalContent {
    static let privacyPolicy = ""
    static let termsOfUse = ""
    static let disclaimer = ""
    static let accessibilityStatement = ""
    static let risks = ""
    static let eula = ""
}
