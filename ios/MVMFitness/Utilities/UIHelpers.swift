import SwiftUI

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

extension View {
    func premiumCardStyle() -> some View {
        self
            .background(MVMTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(MVMTheme.border)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.25), radius: 18, y: 10)
    }

    func premiumCard() -> some View {
        self.premiumCardStyle()
    }
}
