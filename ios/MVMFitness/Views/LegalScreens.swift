import SwiftUI

struct LegalTextView: View {
    let title: String
    let content: String

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(20)
                    .padding(.bottom, 40)
                    .adaptiveContainer()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

enum LegalContent {
    static let privacyPolicy = """
Privacy Policy

Last updated: March 2026

MVM Fitness ("the App") is designed to help users organize, track, and plan fitness training. Your privacy matters, and this policy explains how the App handles your information.

Data Storage
All data — including workout plans, completed records, AFT scores, step history, and user preferences — is stored locally on your device. The App does not transmit, upload, or share your data with any external server, database, or third party unless you explicitly choose to export or share content.

No Accounts Required
The App does not require user accounts, login credentials, or personal identification to function. There is no registration process.

Apple Health (HealthKit)
The App integrates with Apple Health to read step count and active energy data, and to save completed workout sessions. This integration is optional and requires your explicit permission. Health data accessed through HealthKit is used solely to display your fitness activity within the App. Health data is never sold, shared with third parties, used for advertising, or transferred outside the App. Health data remains on your device and under your control at all times.

Device Features
The App may access certain device features to provide its functionality:
• Apple Health — Used to read steps and active calories, and to save workout sessions. Requires your explicit permission.
• Pedometer / Motion Data — Used to count your daily steps and display step totals on the home screen and progress charts. This data remains on your device.
• Camera — Used only for QR code scanning to import shared PT plans. Camera access is requested only when you initiate a scan.
• Calendar — Used only when you choose to sync workouts to your iOS Calendar. Calendar access is requested only when you enable sync. You control this via an on/off toggle.
• Photo Library — Used only when you choose to save share cards or score images. Access is requested at time of save.
• Notifications — Used only for optional daily training reminders that you configure.

No feature accesses data without your action or permission.

Exported and Shared Content
When you export a DA Form 705 PDF, share a QR code, or add events to your calendar, the content leaves the App through standard iOS sharing mechanisms. The App does not control how shared content is used after export.

Third-Party Services
The App does not use analytics, advertising, or tracking frameworks. No third-party SDKs collect data from the App.

Children's Privacy
The App is not directed at children under 13 and does not knowingly collect information from children.

Changes to This Policy
This policy may be updated from time to time. Continued use of the App constitutes acceptance of the current policy.

Contact
If you have questions about this policy, contact the developer through the App Store listing.
"""

    static let termsOfUse = """
Terms of Use

Last updated: March 2026

By downloading, installing, or using MVM Fitness ("the App"), you agree to these Terms of Use and Apple's standard Licensed Application End User License Agreement (EULA) available at:

https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

Fitness Disclaimer
The App is a fitness planning and accountability tool. It generates workout templates based on publicly available exercise formats and user preferences. It does not provide personalized fitness prescriptions, medical advice, or clinical recommendations.

Non-Medical Disclaimer
The App does not diagnose, treat, cure, or prevent any medical condition. Nothing in the App should be interpreted as medical guidance. Always consult a qualified medical professional before starting any exercise program.

HealthKit Data
If you grant Apple Health access, the App reads step count and active energy data to display your activity, and saves completed workout sessions to Apple Health. This data is never sold, shared with advertisers, or used for purposes beyond displaying your fitness information within the App.

User Responsibility
You are solely responsible for assessing your own physical readiness and using proper form during all exercises. Stop immediately if you experience pain, dizziness, or other warning signs.

Limitation of Liability
The App is provided "as is" without warranty of any kind, express or implied. The developer is not liable for any injury, loss, or damage arising from the use of the App or any workout performed using information from the App.

Intellectual Property
All content, design, and code within the App are the property of the developer. Workout formats are based on publicly available fitness standards.

Termination
The developer reserves the right to modify, update, or discontinue the App at any time without prior notice.

Contact
If you have questions about these terms, contact the developer through the App Store listing.
"""

    static let disclaimer = """
Disclaimer

MVM Fitness provides example workout structures, planning tools, and accountability tracking for fitness workflows. It is not a personalized workout plan, not a prescription for exercise, and not a recommendation to begin a new exercise program. It is intended for organization, tracking, and administrative support only.

Workout Content
Workouts displayed in the App are examples based on stored templates, Army fitness test structures, H2F drill categories, and general fitness formats. They are generated from a library of predefined templates combined with user-selected preferences such as focus area, equipment, and duration.

The App does not evaluate your physical condition, medical history, or readiness to perform any exercise.

Not Medical Advice
The App does not provide medical advice, diagnose any condition, or recommend any treatment. Nothing in the App should be interpreted as medical guidance.

AFT Score Calculator
The AFT calculator and scoring tools are provided for estimation and planning purposes only. Scores may not exactly match official Army scoring due to rounding, table variations, or data entry. Official scores are determined by authorized Army personnel under testing conditions.

DA Form 705 Export
The DA Form 705 export feature generates a formatted document based on user-entered data. It is provided as an administrative convenience and does not constitute an official Army record. Verify all exported data for accuracy before use.

General
The developer makes no representations or warranties regarding the accuracy, completeness, or suitability of any content in the App. Use of the App is at your own risk.
"""

    static let accessibilityStatement = """
Accessibility Statement

Last updated: March 2026

MVM Fitness is committed to providing an accessible experience for all users.

Supported Accessibility Features

VoiceOver
All interactive controls, buttons, and navigation elements include accessibility labels and hints so VoiceOver users can navigate the App effectively.

Dynamic Type
The App supports Dynamic Type. Text scales according to your preferred text size set in iOS Settings, ensuring readability at all sizes.

Dark Mode
The App uses a dark-first design with high-contrast text. Both light and dark color schemes are supported and respect your system appearance setting.

Touch Targets
All interactive elements meet the minimum 44x44 point touch target size recommended by Apple Human Interface Guidelines.

Reduce Motion
The App respects the Reduce Motion accessibility setting where applicable to minimize animations.

Color Contrast
Text and interactive elements maintain sufficient contrast ratios against their backgrounds in both light and dark modes.

Feedback
If you encounter any accessibility barriers while using MVM Fitness, please contact the developer through the App Store listing. We welcome feedback to improve accessibility.
"""

    static let risks = """
Risks

Physical training involves inherent risk. Please read the following carefully before using MVM Fitness.

Exercise Risk
Users should consult with a doctor or other qualified medical professional before starting any workout or exercise program. MVM Fitness is an accountability tracker and planning tool only. It does not determine whether a workout is appropriate for any individual.

Potential risks associated with physical exercise include but are not limited to:
• Muscle strains, sprains, and tears
• Joint injuries
• Overexertion and heat-related illness
• Cardiovascular complications
• Bone fractures or stress injuries
• Aggravation of pre-existing conditions

User Responsibility
Users are solely responsible for:
• Assessing their own fitness level and physical readiness
• Using proper form and technique during all exercises
• Following appropriate warm-up and cooldown procedures
• Staying within safe limits of exertion
• Following medical and command guidance regarding physical activity
• Stopping exercise immediately if experiencing pain, dizziness, or other warning signs

Not a Substitute for Professional Advice
The App is not a substitute for professional medical advice, military medical screening, or guidance from qualified fitness professionals. Always prioritize your health and safety over any workout plan or training goal.

By using MVM Fitness, you acknowledge that you understand these risks and accept full responsibility for your participation in any physical activity guided by or tracked within the App.
"""
}
