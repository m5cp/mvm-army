import SwiftUI

/// A transient confirmation banner.
///
/// Built to match `InstantRecapBanner` so the app has one visual language for
/// "something just happened", rather than a second competing style.
nonisolated struct ToastMessage: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let detail: String?
    let icon: String

    init(title: String, detail: String? = nil, icon: String = "checkmark.circle.fill") {
        self.title = title
        self.detail = detail
        self.icon = icon
    }
}

struct SuccessToastView: View {
    let message: ToastMessage
    let onDismiss: () -> Void

    var body: some View {
        Button(action: onDismiss) {
            banner
        }
        .buttonStyle(ToastDismissButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel([message.title, message.detail].compactMap { $0 }.joined(separator: ". "))
        .accessibilityHint("Double tap to dismiss")
    }

    private var banner: some View {
        HStack(spacing: 12) {
            Image(systemName: message.icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(MVMTheme.success)
                .frame(width: 32, height: 32)
                .background(MVMTheme.success.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(message.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                    // Confirmation copy must never be cut off, so it wraps.
                    .fixedSize(horizontal: false, vertical: true)

                if let detail = message.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "xmark")
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(MVMTheme.card)
            RoundedRectangle(cornerRadius: 16)
                .stroke(MVMTheme.success.opacity(0.25))
        }
        .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
        .padding(.horizontal, 20)
        // Whole banner is the hit target, including the padding around it.
        .contentShape(.rect)
    }
}

/// Presses inward slightly so the banner reads as tappable, without the default
/// button tint fighting the card styling.
private struct ToastDismissButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.75 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

private struct SuccessToastOverlay: ViewModifier {
    @Binding var message: ToastMessage?

    /// Long enough to read two lines without trapping the user behind it.
    private let visibleDuration: Duration = .seconds(3.5)

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let active = message {
                    SuccessToastView(message: active) { dismiss() }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        // Keyed by id so a second toast restarts the timer
                        // instead of inheriting the first one's countdown. A
                        // tap clears the message, which cancels this task, so
                        // a dismissed toast can never fire again later.
                        .task(id: active.id) {
                            try? await Task.sleep(for: visibleDuration)
                            guard !Task.isCancelled else { return }
                            dismiss()
                        }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: message?.id)
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            message = nil
        }
    }
}

extension View {
    /// Shows a self-dismissing confirmation banner at the top of the view.
    func successToast(_ message: Binding<ToastMessage?>) -> some View {
        modifier(SuccessToastOverlay(message: message))
    }
}
