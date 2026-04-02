import SwiftUI

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.15, dampingFraction: 0.7), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .medium, intensity: 0.6), trigger: configuration.isPressed)
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

    func adaptiveWidth() -> some View {
        self.frame(maxWidth: 700)
    }

    func adaptiveContainer() -> some View {
        self
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
    }
}
