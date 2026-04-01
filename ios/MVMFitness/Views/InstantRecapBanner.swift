import SwiftUI

struct InstantRecapBanner: View {
    let recap: InstantRecap
    let onDismiss: () -> Void

    @State private var isVisible: Bool = false

    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: recap.icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(recap.isPositive ? MVMTheme.success : MVMTheme.warning)
                    .frame(width: 32, height: 32)
                    .background((recap.isPositive ? MVMTheme.success : MVMTheme.warning).opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(recap.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)

                    if let detail = recap.detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(MVMTheme.card)
                RoundedRectangle(cornerRadius: 16)
                    .stroke(MVMTheme.accent.opacity(0.2))
            }
            .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
            .padding(.horizontal, 20)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            onDismiss()
        }
    }

    func show() -> InstantRecapBanner {
        var copy = self
        copy._isVisible = State(initialValue: true)
        return copy
    }
}

struct InstantRecapOverlay: ViewModifier {
    @Binding var recap: InstantRecap?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let activeRecap = recap {
                    InstantRecapBanner(recap: activeRecap) {
                        recap = nil
                    }
                    .show()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                recap = nil
                            }
                        }
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: recap?.id)
    }
}

extension View {
    func instantRecapOverlay(recap: Binding<InstantRecap?>) -> some View {
        modifier(InstantRecapOverlay(recap: recap))
    }
}
