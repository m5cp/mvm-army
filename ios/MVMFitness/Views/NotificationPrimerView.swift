import SwiftUI

/// Onboarding step 6 — the system notification prompt fires ONLY if the user taps Enable.
struct NotificationPrimerView: View {
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    // Must match ProfileView's keys, or onboarding schedules one time while the
    // Profile row displays — and later reschedules — a different one.
    @AppStorage("reminderHour") private var reminderHour = 6
    @AppStorage("reminderMinute") private var reminderMinute = 0
    let onFinished: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "flame.fill")
                .font(.system(size: 44))
                .foregroundStyle(MVMTheme.heroAmber)

            Text("Protect Your Streak")
                .font(.title2.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("Get a daily training reminder and a heads-up before your streak breaks. No spam — you control everything in Settings.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    // Permission was requested and nothing was ever scheduled —
                    // the user granted access during onboarding and then never
                    // received a single reminder, while the Profile toggle still
                    // read Off. Turn the preference on and schedule it.
                    let granted = await NotificationManager.requestPermission()
                    if granted {
                        dailyReminderEnabled = true
                        var comps = DateComponents()
                        comps.hour = reminderHour
                        comps.minute = reminderMinute
                        let when = Calendar.current.date(from: comps) ?? .now
                        await NotificationManager.scheduleDailyReminder(at: when)
                    }
                    AnalyticsService.track(.notificationPrimerEnabled)
                    onFinished()
                }
            } label: {
                Text("Enable Reminders")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Button("Not Now") {
                AnalyticsService.track(.notificationPrimerSkipped)
                onFinished()
            }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .padding(.horizontal, 4)
    }
}
