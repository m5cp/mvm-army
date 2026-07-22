import SwiftUI

/// Onboarding step 6 — the system notification prompt fires ONLY if the user taps Enable.
struct NotificationPrimerView: View {
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
                    _ = await NotificationManager.requestPermission()
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
