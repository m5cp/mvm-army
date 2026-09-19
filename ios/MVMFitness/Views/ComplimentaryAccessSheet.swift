import SwiftUI

/// Unlocks Pro for the people on the complimentary allowlist.
///
/// The app has no accounts, so this is the only place an email is ever entered.
/// The copy says plainly that the address stays on the device, because asking a
/// no-login app for an email otherwise looks like a dark pattern.
struct ComplimentaryAccessSheet: View {
    @Environment(\.dismiss) private var dismiss

    private var access = ComplimentaryAccessService.shared

    @State private var email = ""
    @State private var errorMessage: String?
    @State private var grantTrigger = false
    @FocusState private var fieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.screen.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        header

                        if let granted = access.grantedEmail {
                            activeCard(granted)
                        } else {
                            entryCard
                        }

                        Text("Your email is checked on this device and stored only here. It is never uploaded, and the app still requires no account.")
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.tertiaryText)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)
                    }
                    .padding(20)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Organization Access")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .sensoryFeedback(.success, trigger: grantTrigger)
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: access.isActive ? "checkmark.seal.fill" : "building.columns")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MVMTheme.heroAmber)

            Text(access.isActive ? "Full access unlocked" : "Free access for approved emails")
                .font(.headline.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .multilineTextAlignment(.center)

            Text(access.isActive
                 ? "Every Pro feature is open on this device, at no cost and with nothing to renew."
                 : "If your email is on the approved list, enter it here to unlock every Pro feature at no cost.")
                .font(.footnote)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var entryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("EMAIL ADDRESS")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(MVMTheme.tertiaryText)

            TextField("name@example.com", text: $email)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.primaryText)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .submitLabel(.go)
                .focused($fieldFocused)
                .onSubmit(redeem)
                .onChange(of: email) { _, _ in errorMessage = nil }
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.heroAmber)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: redeem) {
                Text("Unlock Access")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.onAmber)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                    .background(MVMTheme.amberButtonGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
        .padding(18)
        .background(MVMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func activeCard(_ granted: String) -> some View {
        VStack(spacing: 14) {
            VStack(spacing: 4) {
                Text("UNLOCKED WITH")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Text(granted)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)

            Divider().overlay(MVMTheme.border)

            Button(role: .destructive) {
                access.revoke()
                email = ""
            } label: {
                Text("Remove From This Device")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
            }
        }
        .padding(18)
        .background(MVMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func redeem() {
        fieldFocused = false
        switch access.redeem(email) {
        case .granted:
            errorMessage = nil
            grantTrigger.toggle()
        case .notEligible:
            errorMessage = "That email is not on the approved list. Check for typos, or use Upgrade to Pro to subscribe."
        case .malformed:
            errorMessage = "That does not look like an email address."
        }
    }
}
