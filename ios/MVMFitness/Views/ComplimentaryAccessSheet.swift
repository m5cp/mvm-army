import SwiftUI

/// Redeems a free-access code (or an allowlisted email) for full Pro.
///
/// One field takes either kind of credential, because the person holding a code
/// should not have to know which mechanism unlocked their access. The copy is
/// explicit that nothing leaves the device, since asking for anything that looks
/// like a login in an app that promises no account would otherwise read as a
/// dark pattern.
struct ComplimentaryAccessSheet: View {
    @Environment(\.dismiss) private var dismiss

    private var access = ComplimentaryAccessService.shared

    @State private var entry = ""
    @State private var errorMessage: String?
    @State private var grantTrigger = false
    @State private var toast: ToastMessage?
    @FocusState private var fieldFocused: Bool

    private var trimmedEntry: String {
        entry.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.screen.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        header

                        if let granted = access.grantLabel {
                            activeCard(granted)
                        } else {
                            entryCard
                        }

                        Text("Checked on this device and stored only here. Nothing is uploaded, and the app still works without an account.")
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
            .navigationTitle("Free Access")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .sensoryFeedback(.success, trigger: grantTrigger)
            .successToast($toast)
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: access.isActive ? "checkmark.seal.fill" : "ticket")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MVMTheme.heroAmber)

            Text(access.isActive ? "Full access unlocked" : "Enter your access code")
                .font(.headline.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .multilineTextAlignment(.center)

            Text(access.isActive
                 ? "Every Pro feature is open on this device, at no cost and with nothing to renew."
                 : "If your coach or unit gave you a code, enter it here to unlock every Pro feature at no cost.")
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
            Text("ACCESS CODE")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(MVMTheme.tertiaryText)

            TextField("", text: $entry, prompt: Text("Enter code").foregroundStyle(MVMTheme.tertiaryText))
                .textFieldStyle(.plain)
                // Codes are short and read aloud, so a wide tracked mono face
                // makes characters unambiguous while typing.
                .font(MVMTheme.mono(17))
                .textCase(.uppercase)
                .foregroundStyle(MVMTheme.primaryText)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .focused($fieldFocused)
                .onSubmit(redeem)
                .onChange(of: entry) { _, _ in errorMessage = nil }
                .padding(.horizontal, 14)
                .frame(minHeight: 52)
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
            .disabled(trimmedEntry.isEmpty)
            .opacity(trimmedEntry.isEmpty ? 0.5 : 1)

            Text("Have an approved email instead? Enter that here too.")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText)
                .frame(maxWidth: .infinity, alignment: .center)
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
                entry = ""
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
        switch access.redeem(entry) {
        case .granted(let label):
            errorMessage = nil
            entry = ""
            grantTrigger.toggle()
            // Confirm the unlock explicitly. The card behind the toast also
            // swaps to the active state, but the toast names what changed so
            // the user is not left inferring it from a layout shift.
            toast = ToastMessage(
                title: "MVM Pro unlocked",
                detail: "\(label) \u{00B7} every Pro feature is open, with nothing to renew."
            )
        case .expired(let date):
            errorMessage = "That code expired on \(date.formatted(date: .abbreviated, time: .omitted)). Ask for the current one."
        case .notRecognized:
            errorMessage = trimmedEntry.contains("@")
                ? "That email is not on the approved list. Check for typos, or use Upgrade to Pro to subscribe."
                : "That code is not valid. Check for typos, or use Upgrade to Pro to subscribe."
        }
    }
}
