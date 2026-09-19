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

    var body: some View {
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
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
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
                    SuccessToastView(message: active)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        // Keyed by id so a second toast restarts the timer
                        // instead of inheriting the first one's countdown.
                        .task(id: active.id) {
                            try? await Task.sleep(for: visibleDuration)
                            guard !Task.isCancelled else { return }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                message = nil
                            }
                        }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: message?.id)
    }
}

extension View {
    /// Shows a self-dismissing confirmation banner at the top of the view.
    func successToast(_ message: Binding<ToastMessage?>) -> some View {
        modifier(SuccessToastOverlay(message: message))
    }
}
