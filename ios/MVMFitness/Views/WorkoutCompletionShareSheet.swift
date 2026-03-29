import SwiftUI
import UIKit

struct WorkoutCompletionShareSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let exerciseCount: Int

    @State private var renderedImage: UIImage?
    @State private var checkScale: CGFloat = 0
    @State private var ringScale: CGFloat = 0.6
    @State private var contentOpacity: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    if let image = renderedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                            .padding(.horizontal, 30)
                    } else {
                        shareCardPreview
                            .padding(.horizontal, 20)
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        Button {
                            if let image = renderedImage {
                                let text = "MVM Army — Completed: \(title)\n\(exerciseCount) exercises\n#MVMArmy"
                                let activityVC = UIActivityViewController(activityItems: [image, text], applicationActivities: nil)
                                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                      let rootVC = windowScene.windows.first?.rootViewController else { return }
                                var presenter = rootVC
                                while let presented = presenter.presentedViewController {
                                    presenter = presented
                                }
                                if let popover = activityVC.popoverPresentationController {
                                    popover.sourceView = presenter.view
                                    popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
                                    popover.permittedArrowDirections = []
                                }
                                presenter.present(activityVC, animated: true)
                            }
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
                        .disabled(renderedImage == nil)

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
            .task {
                renderedImage = CompletionCardCGRenderer.render(
                    title: title,
                    exerciseCount: exerciseCount,
                    duration: "",
                    date: .now
                )
            }
        }
    }

    private var shareCardPreview: some View {
        VStack(spacing: 24) {
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

            ProgressView()
                .tint(.white)
                .opacity(renderedImage == nil ? 1 : 0)
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(hex: "#0D0D12"))
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.08))
                }
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: .now)
    }
}
