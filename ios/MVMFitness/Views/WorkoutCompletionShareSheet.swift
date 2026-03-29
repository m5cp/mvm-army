import SwiftUI

struct WorkoutCompletionShareSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let exerciseCount: Int

    @State private var shareItems: [Any] = []
    @State private var showShareSheet: Bool = false
    @State private var checkScale: CGFloat = 0
    @State private var ringScale: CGFloat = 0.6
    @State private var contentOpacity: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    shareCardPreview
                        .padding(.horizontal, 20)

                    Spacer()

                    VStack(spacing: 12) {
                        Button {
                            let items = ShareCardRenderer.shareItems(
                                cardType: .completion(
                                    title: title,
                                    exerciseCount: exerciseCount,
                                    duration: ""
                                )
                            )
                            shareItems = items
                            showShareSheet = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.subheadline.weight(.bold))
                                Text("Share to Social")
                                    .font(.headline.weight(.bold))
                            }
                            .foregroundStyle(.white)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(MVMTheme.heroGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: MVMTheme.accent.opacity(0.3), radius: 16, y: 8)
                        }
                        .buttonStyle(PressScaleButtonStyle())

                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(MVMTheme.secondaryText)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Workout Complete")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if !shareItems.isEmpty {
                    ShareSheet(items: shareItems)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    ringScale = 1.0
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.55).delay(0.15)) {
                    checkScale = 1.0
                }
                withAnimation(.easeOut(duration: 0.4).delay(0.25)) {
                    contentOpacity = 1.0
                }
            }
        }
    }

    private var shareCardPreview: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#4F8CFF"), Color(hex: "#7C5CFF")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("MVM ARMY")
                        .font(.caption.weight(.heavy))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text(formattedDate)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.4))
                }

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [MVMTheme.success.opacity(0.2), MVMTheme.success.opacity(0.02)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)

                    Circle()
                        .stroke(MVMTheme.success.opacity(0.3), lineWidth: 3)
                        .frame(width: 80, height: 80)
                        .scaleEffect(ringScale)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(MVMTheme.success)
                        .scaleEffect(checkScale)
                }

                VStack(spacing: 6) {
                    Text("MISSION COMPLETE")
                        .font(.caption.weight(.heavy))
                        .tracking(2.0)
                        .foregroundStyle(MVMTheme.success)

                    Text(title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .opacity(contentOpacity)

                HStack(spacing: 0) {
                    VStack(spacing: 6) {
                        Image(systemName: "list.bullet")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(hex: "#4F8CFF"))
                        Text("\(exerciseCount)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Exercises")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 1, height: 36)

                    VStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                        Text("Done")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Status")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .opacity(contentOpacity)

                HStack {
                    Text("Me vs Me")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.3))
                    Spacer()
                    Text("#MVMArmy")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(hex: "#4F8CFF").opacity(0.5))
                }
                .opacity(contentOpacity)
            }
            .padding(24)
        }
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "#0D0D12"))

                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#4F8CFF").opacity(0.06),
                                Color(hex: "#7C5CFF").opacity(0.04),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: MVMTheme.accent.opacity(0.1), radius: 30, y: 20)
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: .now)
    }
}
